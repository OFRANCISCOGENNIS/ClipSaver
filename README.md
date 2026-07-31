# Vidora (ClipSaver)

Gerenciador multiplataforma de downloads **autorizados** — baixa, organiza e
converte mídia exclusivamente quando a plataforma de origem ou o titular dos
direitos permite (API oficial, licença aberta, conteúdo do próprio usuário ou
arquivo público de acesso direto). O modelo de autorização é o núcleo do
produto: veja [`docs/compliance.md`](docs/compliance.md) e
[`docs/adr/0001-authorization-model.md`](docs/adr/0001-authorization-model.md).

## Estrutura do monorepo

```
app/       Aplicativo Flutter (domínio, infraestrutura e as seis telas em
           MVVM + Riverpod), em pt-BR, en e es
server/    Backend NestJS (eligibility, analysis, auth, billing, health)
prototype/ Protótipo HTML autocontido, publicado na raiz do site
deploy/    Manifestos Kubernetes e o smoke test de pós-deploy
docs/      ADRs e documentação de conformidade
```

## Quickstart

```bash
# App Flutter (Flutter >= 3.24; o CI fixa 3.44.8)
cd app && flutter pub get && dart run build_runner build && flutter test

# Backend: API NestJS (Node >= 20)
cd server && npm install && npm test

# Stack completa de dev (API + Postgres + Redis)
cd server && docker compose up --build   # Swagger em http://localhost:3000/docs

# Rodar o app apontando para a API local
cd app && flutter run --dart-define=VIDORA_API_BASE_URL=http://localhost:3000
```

Verificações que o CI impõe e que vale rodar antes de um push:

```bash
cd app    && flutter analyze \
          && dart format --output=none --set-exit-if-changed lib test tool \
          && flutter test --coverage && dart run tool/check_coverage.dart
cd server && npm run typecheck && npm run test:coverage
```

Para o alvo Web, `app/tool/fetch_web_assets.sh` baixa os binários de runtime
do SQLite/WASM antes de `flutter build web` — são artefatos de build, não
código-fonte, por isso não são versionados.

## Site

Publicado no GitHub Pages pelo workflow `pages.yml`, em duas partes no mesmo
domínio:

| Endereço | O que é |
|---|---|
| `https://<owner>.github.io/ClipSaver/` | protótipo navegável — abre e funciona, sem backend |
| `https://<owner>.github.io/ClipSaver/app/` | o PWA Flutter de verdade, compilado deste repositório |

Exige uma habilitação única, feita por quem administra o repositório:
Settings → Pages → Source: **GitHub Actions**. O workflow tenta ligar
sozinho (`enablement: true`), mas criar um site do Pages pede permissão de
administração, que o `GITHUB_TOKEN` não tem — detalhes em
[`docs/deploy.md`](docs/deploy.md). Feito isso, todo push em `main` publica
sem intervenção.

**O protótipo** (`prototype/index.html`) é um arquivo só, sem dependências,
com as seis telas e o onboarding de conformidade. Os vereditos de
elegibilidade são resolvidos contra um catálogo local — ele demonstra tanto
as quatro bases de autorização quanto as recusas (DRM, paywall, login de
terceiros, endereço interno), e avisa isso numa faixa fixa no topo. Um
protótipo que "baixasse" qualquer link daria a impressão errada justamente
sobre a parte do produto que mais importa.

**O app** roda biblioteca, conversor, configurações e onboarding direto do
navegador, porque o banco é local (SQLite compilado para WASM). A tela
Analyze depende de API: elegibilidade é decidida no servidor de propósito,
então sem backend alcançável ela reporta erro de conexão em vez de fingir um
veredito. Aponte a variável de repositório `VIDORA_API_BASE_URL` para uma API
publicada para ligar as duas pontas. Detalhes em
[`docs/deploy.md`](docs/deploy.md).

## Qualidade

| Métrica | Valor | Mínimo |
|---|---|---|
| Testes | 516 (app) + 136 (servidor) + 7 (navegador) | — |
| Cobertura domínio/aplicação (app) | 97,4% | 95% |
| Cobertura total (app) | 89,6% | 80% |
| Cobertura de linhas (servidor) | 98,4% | 95% |
| Cobertura de branches (servidor) | 94,1% | 90% |

Os gates são por camada, não globais: um número único esconderia uma
interface bem testada flutuando sobre uma máquina de estados sem teste.

Os sete testes de navegador (`e2e/`) rodam contra a árvore `site/` montada
— o mesmo artefato que o Pages publica. Eles cobrem o que a suíte de
widget estruturalmente não vê, porque roda sem navegador nenhum: os
binários de SQLite/WASM carregando, o `base-href`, um deep link, e para
onde o app faz requisição. Duas chamadas a terceiros já foram encontradas
assim, depois de publicadas.

## Pipeline

| Workflow | Quando | O que faz |
|---|---|---|
| `ci.yml` | push e PR | lint, testes, gates de cobertura, testes de navegador sobre o site montado, build da imagem com smoke, render dos manifestos |
| `pages.yml` | push em `main` que toque `app/` ou `prototype/` | publica o protótipo e o PWA no GitHub Pages |
| `release.yml` | tag `v*` | builds das 6 plataformas + checksums |
| `deploy.yml` | push em `main` que toque `server/` | imagem por digest → staging → smoke → produção com aprovação |

## Documentação

- [`docs/compliance.md`](docs/compliance.md) — o que o app baixa e o que recusa
- [`docs/deploy.md`](docs/deploy.md) — site, Kubernetes, segredos, rollback
- [`docs/release.md`](docs/release.md) — builds por plataforma e assinatura
- ADRs: [autorização](docs/adr/0001-authorization-model.md) ·
  [motor de download](docs/adr/0002-download-engine-and-scheduler.md) ·
  [busca e conversão](docs/adr/0003-search-and-conversion.md) ·
  [plano e IA local](docs/adr/0004-premium-and-local-intelligence.md) ·
  [CI/CD, release e i18n](docs/adr/0005-cicd-release-and-i18n.md)

## Estado das fases

| Fase | Escopo | Estado |
|---|---|---|
| 1 | Domínio + modelo de autorização + testes | ✅ concluída |
| 2 | Backend (eligibility + analysis) + infraestrutura local do app | ✅ concluída |
| 3 | Telas Analyze e Downloads | ✅ concluída |
| 4 | Library, Search e Converter | ✅ concluída |
| 5 | Premium, IA, Settings e polimento | ✅ concluída |
| 6 | CI/CD, builds de release e documentação final | ✅ concluída |
| 7 | Acessibilidade, notificações, link compartilhado e testes de navegador | ✅ concluída |

### O que fica pendente, explicitamente

- **Fila em segundo plano**: sair do app no Android ou no iOS suspende os
  downloads. Falta um foreground service e um `BGTaskScheduler`. Para um
  gerenciador de downloads isso não é um extra, e é a maior lacuna aberta.
- **Ponte do compartilhamento no iOS**: o Android já entrega o link
  compartilhado à tela Analyze (`MainActivity.kt` + canal de plataforma).
  O iOS precisa de uma Share Extension, que exige mexer no projeto Xcode.
- **Código nativo não executado**: o `MainActivity.kt` do compartilhamento
  e o adapter de notificações do `flutter_local_notifications` compilam e
  têm o lado Dart testado, mas nunca rodaram num aparelho — não há
  emulador nem dispositivo neste ambiente. O que está provado é o
  contrato, não a entrega.
- **Fonte de fallback do motor web**: o app não busca mais o CanvasKit nem
  as próprias fontes em servidores da Google, mas o motor do Flutter ainda
  pede a Roboto de fallback em `fonts.gstatic.com`. Há um teste de
  navegador que trava exatamente essa exceção, então uma segunda chamada a
  terceiro quebra o CI. Resolver exige decidir o que fazer com o conjunto
  Noto inteiro, grande demais para entrar sem decisão.

- **Assinatura de iOS/macOS**: exige certificado, perfil de provisionamento
  e notarização. O build de iOS sai sem assinatura — compila, não é
  publicável. Os passos estão em [`docs/release.md`](docs/release.md).
- **Deploy da API a um cluster**: manifestos e pipeline são renderizados e
  validados no CI a cada push, mas nunca foram aplicados a um cluster real
  (faltam cluster e `KUBE_CONFIG`). A imagem, essa sim, é construída e
  levantada no CI com os probes respondendo.
- **Idioma nas mensagens do servidor**: o texto educativo de recusa e as
  condições de licença vêm do backend e aparecem em português em qualquer
  locale. O contrato correto é `Accept-Language` na requisição de análise.
- **Credenciais das lojas**: os três verificadores de recibo estão
  implementados e testados, mas cada um precisa do seu token injetado pela
  implantação. Sem configuração, o provedor é recusado — falha fechado.
