# Vidora — Modelo de autorização e conformidade

> Documento vivo. Fase 1 cobre o motor de elegibilidade; seções de
> distribuição por loja e LGPD/GDPR são detalhadas nas fases 5–6.

## Princípio

O Vidora **não é um downloader genérico**: é um gerenciador de downloads de
**fontes autorizadas**. Quando funcionalidade e conformidade conflitam, a
conformidade vence — essa regra está codificada no pipeline de decisão, não
apenas escrita aqui.

## O que autoriza um download

Uma URL só é elegível se atender a pelo menos um critério (seção 2.1 do
produto), cada um implementado como um adaptador com base legal explícita:

| Fonte (`source`) | Critério | Adaptador | Base legal resumida |
|---|---|---|---|
| `user_owned` | Conteúdo do próprio usuário | `user_owned_oauth` | Titularidade verificada via OAuth na plataforma de origem |
| `official_api` | API oficial com endpoint de download | `official_api` | A própria plataforma fornece o arquivo por endpoint público e documentado |
| `open_license` | Licença aberta declarada | `open_license` | CC/domínio público detectados em metadados (oEmbed, schema.org, rel=license) |
| `direct_file` | Arquivo de acesso direto | `direct_file` | Mídia servida publicamente por link direto, sem barreira técnica |

### Plataformas reconhecidas por nome

Um adaptador diz *qual base legal* autoriza; um **probe de plataforma**
diz o que uma plataforma específica realmente oferece. A separação
importa: o motor de elegibilidade decide e nunca busca nada, então quem
consulta a API oficial é a camada de análise.

| Plataforma | Endpoint oficial consultado | Recusa quando |
|---|---|---|
| Internet Archive | `https://archive.org/metadata/<id>` | o item é `is_dark` ou tem `access-restricted-item` (empréstimo controlado) |

O Archive publica esse endpoint justamente para que clientes enumerem e
busquem itens — baixar por ele é o uso previsto, não um contorno. A
recusa de itens em empréstimo restrito é o ponto que exige cuidado: são
livros e discos que a instituição gateia de propósito, e ignorar a marca
seria baixar exatamente o que ela protege. Uma falha ao alcançar a API
também recusa: erro de rede nunca vira permissão.

O catálogo de adaptadores é exposto programaticamente
(`EligibilityService.adapters`) com `legalBasis`, `officialEndpoint` e
`tosUrl` por adaptador, servindo de trilha de auditoria e alimentando a
página "Política de uso responsável" do app.

## O que nunca é feito

- **DRM** (Widevine, FairPlay, PlayReady ou qualquer outro): bloqueio
  absoluto, anterior a qualquer adaptador — inclusive para o dono do
  conteúdo. Não existe código de contorno no repositório.
- **Paywalls e autenticação de terceiros**: conteúdo pago ou restrito a
  login de terceiros é recusado com mensagem educativa. A única exceção é
  o próprio dono acessando o próprio conteúdo, provado por OAuth — nunca
  por cookies ou sessões emprestadas.
- **Scraping que burle proteções técnicas ou tokens de sessão.**
- **SSRF**: URLs para localhost, redes privadas (RFC 1918), link-local,
  metadados de nuvem (169.254.169.254), CGNAT e equivalentes IPv6 são
  recusadas antes de qualquer fetch (checagem em `url-safety.ts`, com
  validação espelhada no cliente em `MediaUrl`).

## Fail closed

Ambiguidade nunca vira permissão:

- Licença ausente ou não reconhecida → "todos os direitos reservados"
  (não baixável por licença).
- `CC-BY-NC-ND` e variantes não mapeadas → recusadas.
- Resultado elegível é estruturalmente obrigado a nomear sua fonte de
  autorização e oferecer ao menos um formato real; inelegível nunca
  carrega formatos. Essas invariantes valem no backend (tipos + testes) e
  no app (validação em construção da entidade).

## Transparência para o usuário

- Cada item analisado exibe o **selo da origem da autorização**
  ("Seu conteúdo", "Download oficial", "Licença CC-BY", "Arquivo direto").
- Restrições da licença (ex.: "atribuição obrigatória", "uso não
  comercial") aparecem no cartão de resultado e acompanham o item na
  biblioteca.
- Recusas trazem explicação educativa e, quando possível, o caminho
  legítimo ("Você pode salvá-lo na sua conta da plataforma de origem.").
- Logs não registram URLs completas de conteúdo do usuário — apenas hash
  e domínio (higiene verificada por teste em `url-safety.spec.ts`).

## Verificação contínua

Os 10 casos negativos e 10 positivos do Definition of Done estão em
`server/test/eligibility.service.spec.ts` (N1–N10, P1–P10) e rodam no CI.
Qualquer mudança que aprove um caso negativo quebra o build.
