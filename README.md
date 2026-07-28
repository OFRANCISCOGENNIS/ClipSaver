# Vidora (ClipSaver)

Gerenciador multiplataforma de downloads **autorizados** — baixa, organiza e
converte mídia exclusivamente quando a plataforma de origem ou o titular dos
direitos permite (API oficial, licença aberta, conteúdo do próprio usuário ou
arquivo público de acesso direto). O modelo de autorização é o núcleo do
produto: veja [`docs/compliance.md`](docs/compliance.md) e
[`docs/adr/0001-authorization-model.md`](docs/adr/0001-authorization-model.md).

## Estrutura do monorepo

```
app/     Flutter (Fases 1–2: domínio + infraestrutura em Dart puro;
         rede dio, banco local drift, repositórios)
server/  Backend NestJS (eligibility + analysis + auth, Prisma, BullMQ)
docs/    ADRs e documentação de conformidade
```

## Quickstart

```bash
# App: domínio + infraestrutura (Dart >= 3.6)
cd app && dart pub get && dart run build_runner build && dart test

# Backend: API NestJS (Node >= 20)
cd server && npm install && npm test

# Stack completa de dev (API + Postgres + Redis)
cd server && docker compose up --build   # Swagger em http://localhost:3000/docs
```

`dart analyze` (zero issues) e `npm run typecheck` também devem passar.

## Estado das fases

| Fase | Escopo | Estado |
|---|---|---|
| 1 | Domínio + modelo de autorização + testes | ✅ concluída |
| 2 | Backend (eligibility + analysis) + infraestrutura local do app | ✅ concluída |
| 3 | Telas Analyze e Downloads | ⏳ |
| 4 | Library, Search e Converter | ⏳ |
| 5 | Premium, IA, Settings e polimento | ⏳ |
| 6 | CI/CD, builds de release e documentação final | ⏳ |
