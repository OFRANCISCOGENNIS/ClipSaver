# Vidora (ClipSaver)

Gerenciador multiplataforma de downloads **autorizados** — baixa, organiza e
converte mídia exclusivamente quando a plataforma de origem ou o titular dos
direitos permite (API oficial, licença aberta, conteúdo do próprio usuário ou
arquivo público de acesso direto). O modelo de autorização é o núcleo do
produto: veja [`docs/compliance.md`](docs/compliance.md) e
[`docs/adr/0001-authorization-model.md`](docs/adr/0001-authorization-model.md).

## Estrutura do monorepo

```
app/     Aplicativo Flutter (domínio, infraestrutura e as telas
         Analyze e Downloads em MVVM + Riverpod)
server/  Backend NestJS (eligibility + analysis + auth, Prisma, BullMQ)
docs/    ADRs e documentação de conformidade
```

## Quickstart

```bash
# App Flutter (Flutter >= 3.24)
cd app && flutter pub get && dart run build_runner build && flutter test

# Backend: API NestJS (Node >= 20)
cd server && npm install && npm test

# Stack completa de dev (API + Postgres + Redis)
cd server && docker compose up --build   # Swagger em http://localhost:3000/docs

# Rodar o app apontando para a API local
cd app && flutter run --dart-define=VIDORA_API_BASE_URL=http://localhost:3000
```

`flutter analyze` (zero issues) e `npm run typecheck` também devem passar.

Para o alvo Web, `tool/fetch_web_assets.sh` baixa os binários de runtime do
SQLite/WASM antes de `flutter build web` — são artefatos de build, não
código-fonte, por isso não são versionados.

## Estado das fases

| Fase | Escopo | Estado |
|---|---|---|
| 1 | Domínio + modelo de autorização + testes | ✅ concluída |
| 2 | Backend (eligibility + analysis) + infraestrutura local do app | ✅ concluída |
| 3 | Telas Analyze e Downloads | ✅ concluída |
| 4 | Library, Search e Converter | ⏳ |
| 5 | Premium, IA, Settings e polimento | ⏳ |
| 6 | CI/CD, builds de release e documentação final | ⏳ |
