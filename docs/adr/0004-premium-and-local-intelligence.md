# ADR-0004 — Limites de plano e inteligência local

- **Status**: aceito
- **Data**: 2026-07-29
- **Fase**: 5

## Contexto

A seção 14 define limites por plano; a seção 15 pede recursos de IA com
princípio "local primeiro"; a seção 16 pede configurações com busca
interna. As três compartilham um risco: virarem `if` espalhados pelo
código, sem lugar único que responda "o que vale agora".

## Decisões

1. **`Entitlements` é o único lugar que responde o que o plano permite.**
   Espalhar `if (isPremium)` é como um paywall fica inconsistente — e como
   um usuário pagante acaba bloqueado. O ponto crítico é o clamp de
   simultaneidade: **o plano é o teto, a configuração é o pedido**. Uma
   assinatura expirada não pode deixar 8 downloads paralelos ativos porque
   o valor ficou salvo.

2. **Toda "IA" desta fase é determinística e explicável.**
   A seção 15 nomeia um modelo TFLite on-device. O que entrou é heurística
   por metadados atrás do port `MediaClassifier`: roda offline no dia um
   (satisfazendo "local primeiro" de verdade, sem download de modelo), é
   explicável para o usuário, e um classificador aprendido substitui a
   implementação sem tocar em nenhum chamador.

3. **Sugestões de título nunca são aplicadas sozinhas.**
   `TitleNormalizer` devolve original, sugestão *e* a lista do que mudaria,
   porque a seção 15 exige preview. Renomear arquivos do usuário sem
   mostrar o quê seria uma violação de confiança, não uma conveniência.

4. **Duplicados são detectados por metadados, não por hash perceptual.**
   Um hash perceptual de verdade exigiria decodificar a mídia — trabalho
   que pertence à camada de codecs por plataforma. Título normalizado mais
   duração próxima já pega o caso real ("baixei de novo em 1080p") sem ler
   um único byte. O tipo `exact` vs `sameMedia` deixa explícito qual
   evidência sustenta cada grupo.

5. **O relatório de armazenamento não conta duas vezes.**
   Sugestões se sobrepõem (um duplicado também pode estar sem reprodução
   há 90 dias). Somar os totais prometeria espaço que não existe, então
   `totalReclaimable` conta cada item uma vez. Prometer a mais é pior do
   que não sugerir.

6. **Configurações vivem no banco do app, não em `shared_preferences`.**
   Mesmo armazenamento de todo o resto: um backup, uma história de
   criptografia, e testes unitários sem platform channel. O objeto inteiro
   é um JSON numa linha — preferências mudam de forma com frequência, e uma
   migração de schema por toggle novo seria atrito puro. Dado corrompido ou
   de versão futura cai nos padrões em vez de travar o app.

7. **Analytics é opt-in, nunca opt-out.** Consentimento LGPD/GDPR precisa
   ser afirmativo; o padrão é desligado e o texto diz isso.

8. **O conversor FFmpeg roda em processo separado, não em isolate.**
   FFmpeg é código nativo, e matar um processo é a única forma confiável de
   abortar um transcode no meio de um frame. O erro do usuário vem
   traduzido da stderr do FFmpeg — "arquivo corrompido" em vez de
   "moov atom not found".

## Consequências

- 89 testes cobrem plano, IA e configurações sem tocar em rede, disco ou
  binário externo.
- Trocar a heurística por um modelo, ou o binário FFmpeg por outro
  backend, não altera nenhum chamador.
- Falta ainda: billing real (StoreKit 2 / Play Billing / Stripe) e
  extração de strings para i18n — ambos ficam na Fase 6 com o trabalho de
  release.
