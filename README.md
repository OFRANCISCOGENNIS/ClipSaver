# Vidora (ClipSaver)

Gerenciador multiplataforma de downloads **autorizados** — baixa, organiza e
converte mídia exclusivamente quando a plataforma de origem ou o titular dos
direitos permite (API oficial, licença aberta, conteúdo do próprio usuário ou
arquivo público de acesso direto). O modelo de autorização é o núcleo do
produto: veja [`docs/compliance.md`](docs/compliance.md) e
[`docs/adr/0001-authorization-model.md`](docs/adr/0001-authorization-model.md).

## Estrutura do monorepo

```
app/     Flutter (Fase 1: pacote Dart puro com a camada de domínio)
server/  Backend (Fase 1: domínio do motor de elegibilidade em TypeScript)
docs/    ADRs e documentação de conformidade
```

## Quickstart

```bash
# Domínio do app (Dart >= 3.6)
cd app && dart pub get && dart test

# Motor de elegibilidade (Node >= 20)
cd server && npm install && npm test
```

`dart analyze` (zero issues) e `npm run typecheck` também devem passar.

## Estado das fases

| Fase | Escopo | Estado |
|---|---|---|
| 1 | Domínio + modelo de autorização + testes | ✅ concluída |
| 2 | Backend (eligibility + analysis) + infraestrutura local do app | ⏳ |
| 3 | Telas Analyze e Downloads | ⏳ |
| 4 | Library, Search e Converter | ⏳ |
| 5 | Premium, IA, Settings e polimento | ⏳ |
| 6 | CI/CD, builds de release e documentação final | ⏳ |
