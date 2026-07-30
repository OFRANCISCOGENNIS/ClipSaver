# Release

Builds das seis plataformas da seção 3, o que é assinado e o que ainda não
é.

## Disparo

```bash
git tag v0.6.0 && git push origin v0.6.0
```

Um `workflow_dispatch` em `.github/workflows/release.yml` faz o mesmo sem
publicar nada — útil para provar que as seis toolchains ainda compilam.

Cada plataforma é um job independente: uma toolchain quebrada não esconde
as outras cinco, e o job `publish` só junta o que realmente foi produzido.

## Estado por plataforma

| Alvo | Artefato | Assinatura |
|---|---|---|
| Android | `.aab` + `.apk` por ABI | keystore dos secrets; sem eles, chave de debug e **não publicável** |
| iOS | `Runner.app` | **não assinado** — falta certificado e perfil |
| macOS | `vidora-macos.zip` | não notarizado |
| Windows | pasta do runner | não assinado |
| Linux | `vidora-linux-x64.tar.gz` | n/a |
| Web | `vidora-web.tar.gz` | n/a |

Os binários saem acompanhados de `SHA256SUMS.txt`. Sem os checksums não há
como distinguir um espelho de um artefato adulterado.

## Android

`android/app/build.gradle.kts` lê `android/key.properties`, que é
gitignorado e escrito pelo CI a partir dos secrets. Ausente o keystore, o
build **ainda passa** com a chave de debug para que `flutter run --release`
funcione localmente — e o workflow avisa em alto e bom som que o artefato
não serve para publicação. O keystore é apagado com `if: always()`, para não
sobreviver ao job nem quando um passo posterior falha.

Gerar um keystore e alimentar os secrets:

```bash
keytool -genkey -v -keystore vidora-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias vidora
base64 -w0 vidora-release.jks    # → secret ANDROID_KEYSTORE_BASE64
```

R8 está ligado no release, com as regras em
`android/app/proguard-rules.pro`.

## iOS e macOS — o que falta

O job de iOS roda `flutter build ios --release --no-codesign`. Isso prova
que o alvo compila; **não** produz nada instalável. Para assinar de verdade
o pipeline precisa de:

1. Certificado de distribuição (`.p12`) e sua senha, em secrets.
2. Perfil de provisionamento (`.mobileprovision`).
3. Importação para um keychain temporário no runner, com o keychain
   destruído no fim do job.
4. `xcodebuild -exportArchive` com um `ExportOptions.plist`.

Para macOS, acrescente notarização (`xcrun notarytool`) com um App Store
Connect API key — sem isso o Gatekeeper recusa o app em qualquer máquina
que não seja a que compilou.

Isso está fora do que se pode escrever sem uma conta Apple: as etapas
existem, as credenciais não. Preferi um build honestamente não assinado a
um passo que finge assinar.

## Permissões declaradas

Verificadas em cada plataforma porque a omissão só aparece depois do
release:

- **Android**: `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`,
  `POST_NOTIFICATIONS`. O manifesto de debug concede rede
  implicitamente — sem declarar, só o build de release fica sem rede.
- **macOS**: `com.apple.security.network.client` nas entitlements de
  **release** também, não só de debug. O template do Flutter omite, e o
  app sandboxed sai sem rede alguma depois de publicado.
- **iOS**: `CFBundleLocalizations` com `pt-BR`, `en` e `es`. Sem a lista, o
  locale do aparelho nunca chega ao Flutter e a interface fica travada no
  idioma de desenvolvimento.

## Versionamento

`app/pubspec.yaml` carrega `version: <nome>+<código>`. O
`versionCode`/`CFBundleVersion` vem daí via `flutter.versionCode`. A tag
Git e o `version` do pubspec devem casar antes do push da tag — nada no
pipeline concilia os dois hoje.

## Antes de marcar uma tag

O CI já cobre tudo isto em cada push, mas vale rodar localmente:

```bash
cd app && flutter analyze && flutter test --coverage \
  && dart run tool/check_coverage.dart
cd ../server && npm run typecheck && npm run test:coverage
```
