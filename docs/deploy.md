# Deploy

Como o Vidora vai para produção: o site estático, a API no Kubernetes e os
segredos que cada um exige.

## O site

O workflow `.github/workflows/pages.yml` monta e publica duas coisas no
mesmo domínio a cada push em `main` que toque `app/` ou `prototype/`:

```
/ClipSaver/            prototype/index.html — protótipo navegável, sem backend
/ClipSaver/app/        build Flutter web, com --base-href /ClipSaver/app/
/ClipSaver/404.html    despachante: devolve um deep link para quem é dono dele
```

O Pages serve um único `404.html` para o site inteiro, e as duas aplicações
usam caminhos reais (`/downloads`, `/library`…). Sem o despachante, um deep
link ou um F5 numa rota interna cai em 404.

**Não há passo manual.** O `configure-pages` roda com `enablement: true`, o
que liga o Pages no repositório e fixa a origem em **GitHub Actions** usando
o `GITHUB_TOKEN`. Num repositório que nunca teve Pages, sem isso o workflow
monta o site inteiro e só então falha, com um 404 do endpoint de Pages — foi
exatamente o que aconteceu na primeira execução.

Se a organização restringir o Pages por política, aí sim a habilitação pelo
token é recusada e alguém com acesso a Settings → Pages precisa escolher
**GitHub Actions** como origem uma vez.

### O protótipo

`prototype/index.html` é um arquivo só, sem build e sem dependências: tokens
CSS com tema claro e escuro, as seis telas, o onboarding de conformidade e
um service worker. Os vereditos vêm de um catálogo local, e a faixa fixa no
topo diz isso — um protótipo que "baixasse" qualquer link daria a impressão
errada justamente sobre a parte do produto que mais importa. Ele demonstra
as quatro bases de autorização e as quatro recusas (DRM, paywall, login de
terceiros, endereço interno).

Para mexer nele localmente:

```bash
python3 -m http.server 8099 --directory prototype
```

### O app

O que funciona num host estático: biblioteca, fila de conversão,
configurações e o onboarding de conformidade, porque o banco do app é local
(SQLite compilado para WASM, rodando no navegador).

O que **não** funciona sem API: a tela Analyze. Elegibilidade é decidida no
servidor de propósito — o cliente nunca é a autoridade sobre o que pode ser
baixado (seção 2.2) — então sem backend alcançável ela reporta erro de
conexão em vez de fingir um veredito. Para ligar as duas pontas, defina a
variável de repositório `VIDORA_API_BASE_URL` (Settings → Secrets and
variables → Actions → Variables) apontando para a API publicada.

## A API

### Local

```bash
cd server && docker compose up --build      # API + Postgres + Redis
# Swagger em http://localhost:3000/docs
```

Sem `DATABASE_URL` e `REDIS_URL` a API sobe com as portas em memória, o que
é suficiente para desenvolver o app e é o modo em que os testes rodam.

### Kubernetes

Os manifestos estão em `deploy/k8s`, em base + overlays:

```
deploy/k8s/base/                  Deployment, Service, HPA, PDB,
                                  NetworkPolicy, Ingress, ConfigMap gerado
deploy/k8s/overlays/staging/      namespace vidora-staging, 1–3 réplicas
deploy/k8s/overlays/production/   namespace vidora,         3–20 réplicas
```

Renderize antes de aplicar — o CI faz isso em todo push:

```bash
kubectl kustomize deploy/k8s/overlays/staging
```

O `Deployment` traz `IMAGE_PLACEHOLDER` no lugar da imagem. O workflow de
deploy substitui isso pela imagem **fixada por digest**, não por tag: uma
tag pode ser movida depois da aprovação, e então produção rodaria algo que
ninguém revisou.

### Segredos da API

O `Deployment` monta um Secret chamado `vidora-api-secrets` com `envFrom`,
então as chaves são exatamente as variáveis que a aplicação valida no boot.
`deploy/k8s/base/secret.example.yaml` é **um modelo**: não aplique como
está e não versione valores reais. Crie o Secret fora do fluxo do Git
(sealed-secrets, SOPS, ou o operador de segredos externos do cluster).

| Chave | Obrigatória | Observação |
|---|---|---|
| `JWT_SECRET` | sim em produção | mínimo 16 bytes; a API **recusa subir** se ainda começar com `dev-only` |
| `DATABASE_URL` | não | ausente ⇒ repositórios em memória |
| `REDIS_URL` | não | ausente ⇒ cache e fila em memória |

### Segredos do pipeline

Configurados em Settings → Secrets and variables → Actions:

| Nome | Usado por | Para quê |
|---|---|---|
| `KUBE_CONFIG_STAGING` | `deploy.yml` | kubeconfig em base64 do cluster de staging |
| `KUBE_CONFIG_PRODUCTION` | `deploy.yml` | idem, produção |
| `ANDROID_KEYSTORE_BASE64` | `release.yml` | keystore de release em base64 |
| `ANDROID_KEYSTORE_PASSWORD` | `release.yml` | senha do keystore |
| `ANDROID_KEY_ALIAS` | `release.yml` | alias da chave |
| `ANDROID_KEY_PASSWORD` | `release.yml` | senha da chave |

Ausência de um `KUBE_CONFIG` **falha o job com mensagem própria** em vez de
seguir e aplicar em lugar nenhum.

### Aprovação manual

A promoção para produção depende das regras de proteção do environment
`production` (Settings → Environments → production → Required reviewers).
Isso mora ali, e não no YAML, porque uma lista de revisores dentro do
workflow é editável pelo mesmo pull request que quer pular a revisão.

### Credenciais das lojas (billing)

A verificação de recibo é feita no servidor — um recibo é entrada
controlada pelo atacante. Cada verificador recebe seu token de
autorização **injetado**, então a rotação de credenciais fica fora do
código:

| Provedor | O que a implantação precisa fornecer |
|---|---|
| Google Play | token OAuth 2.0 de uma service account com acesso ao Android Publisher API, e o `packageName` |
| App Store | JWT ES256 assinado com a chave do App Store Connect |
| Stripe | chave secreta (`sk_...`) |

Um provedor que ninguém configurou é **recusado**, não liberado: o registro
de verificadores falha fechado.

## Rollback

O smoke test roda depois do rollout. Se reprovar em produção, o workflow
executa `kubectl rollout undo` e falha o job — desfazer é o caminho mais
rápido de volta a uma versão que funcionava.

Manualmente:

```bash
kubectl -n vidora rollout undo deployment/vidora-api
kubectl -n vidora rollout status deployment/vidora-api
```

## O que ainda não foi exercitado

Honestidade sobre o estado: os manifestos e o pipeline são renderizados e
validados no CI a cada push, mas **nunca foram aplicados a um cluster
real** — faltam um cluster e os `KUBE_CONFIG`. O que já foi verificado de
ponta a ponta é a imagem: ela é construída no CI, o container é levantado e
os probes respondem 200, e o `deploy/smoke-test.sh` foi executado contra o
binário compilado.
