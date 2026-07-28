# ADR-0001 — Modelo de autorização como núcleo do produto

- **Status**: aceito
- **Data**: 2026-07-28
- **Fase**: 1

## Contexto

O Vidora baixa, organiza e converte mídia. O risco central do produto é
jurídico, não técnico: um downloader genérico infringe direitos autorais e
Termos de Serviço das plataformas. A especificação define a regra de ouro:
**quando funcionalidade e conformidade conflitam, a conformidade vence**.

## Decisão

1. **Elegibilidade é uma decisão de domínio, pura e determinística.**
   O `EligibilityService` (backend) recebe um `AnalysisContext` já coletado
   pelo módulo de análise e devolve um `EligibilityResult`. Ele nunca faz
   fetch — separar "coletar fatos" de "decidir" torna as 20 casos de aceite
   (10 negativos, 10 positivos) verificáveis mecanicamente em testes
   unitários.

2. **Pipeline com barreiras absolutas antes dos adaptadores.**
   Ordem fixa: segurança de URL (SSRF) → DRM (bloqueio absoluto,
   inclusive para o dono do conteúdo) → titularidade via OAuth →
   paywall/autenticação de terceiros → adaptadores (`official_api` →
   `open_license` → `direct_file`) → recusa educativa (fail closed).
   A titularidade roda antes do paywall porque o dono acessa o próprio
   conteúdo via OAuth — nunca por sessão emprestada.

3. **Toda via de acesso é um `PlatformAdapter` com base legal documentada.**
   Cada adaptador declara `legalBasis`, `officialEndpoint` e `tosUrl`.
   O catálogo é exposto para a página de conformidade e serve de trilha de
   auditoria. Adaptadores só retornam veredictos elegíveis; a recusa (e seu
   texto educativo) é centralizada no serviço para manter consistência.

4. **Fail closed em todos os pontos ambíguos.**
   Licença desconhecida → "todos os direitos reservados". Fonte de
   autorização desconhecida no wire → `none`. Resultado elegível sem
   formato real → inválido (invariante de construção nas duas pontas,
   Dart e TypeScript).

5. **O domínio Dart espelha o contrato e valida invariantes localmente.**
   `EligibilityResult` (Dart) recusa, em construção: elegível sem fonte,
   inelegível com fonte ou formatos, motivo vazio. A UI nunca consegue
   renderizar um estado juridicamente inconsistente.

## Consequências

- Plataformas novas entram pelo registro de adaptadores, cada uma com sua
  base legal revisada — nunca por scraping ad hoc.
- Nenhum código de contorno de DRM, tokens de sessão de terceiros ou
  paywall existirá no repositório; o pipeline recusa antes de qualquer
  adaptador rodar.
- Os 10 casos negativos e 10 positivos do Definition of Done vivem em
  `server/test/eligibility.service.spec.ts` e rodam no CI; qualquer
  regressão de conformidade quebra o build.

## Decisões relacionadas de estrutura (Fase 1)

- Monorepo: `app/` (Flutter — na Fase 1, pacote Dart puro com o domínio)
  e `server/` (backend — na Fase 1, domínio TypeScript framework-agnostic).
- O domínio de ambos os lados não depende de framework algum (sem Flutter,
  sem NestJS), garantindo a regra de dependência da Clean Architecture e
  testes rápidos; camadas externas chegam nas Fases 2–3 apontando para
  dentro.
