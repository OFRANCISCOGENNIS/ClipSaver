# ADR-0002 — Separação entre motor de download e scheduler da fila

- **Status**: aceito
- **Data**: 2026-07-29
- **Fase**: 3

## Contexto

A seção 8 pede muita coisa de uma vez: máquina de estados por download,
retomada por HTTP Range, verificação de integridade, fila com prioridade e
simultaneidade configurável, e retry automático com backoff exponencial.
Colocar tudo em uma classe produziria um objeto impossível de testar sem
rede e sem disco.

## Decisão

1. **`DownloadEngine` move bytes; `DownloadManager` decide o que roda.**
   O motor executa **uma** tentativa de transferência e dirige a entidade
   pela máquina de estados, emitindo cada mudança. Ele não persiste nada e
   **não tenta de novo** — um motor com retry próprio brigaria com o
   orçamento de backoff da fila.

2. **Dois ports isolam plataforma e rede.**
   `DownloadTransport` (stream de bytes, flag `resumed`, tamanho total) e
   `DownloadFileSystem` (append, rename atômico, leitura em blocos). Isso
   torna cenários como "servidor ignorou o Range", "conexão caiu no meio"
   e "checksum não confere" testáveis de forma determinística.

3. **Caminhos de entrada distintos para novo e retomado.**
   `queued → connecting → downloading` para uma tarefa nova;
   `paused → downloading` para uma retomada, porque `paused` não tem aresta
   para `connecting` na seção 8.1. Mover de estado antes de conectar também
   garante que uma falha de reconexão tenha uma aresta legal para `failed`.

4. **Integridade antes de publicar o arquivo.**
   O checksum é calculado sobre o arquivo `.vidora-part` completo (não
   incrementalmente durante o stream), porque uma retomada quebraria o hash
   incremental. Sem checksum publicado, cai para verificação de tamanho.
   Só depois de passar é que ocorre o `rename` atômico — o arquivo final
   aparece inteiro ou não aparece.

5. **A URL de origem vive na tarefa.**
   Uma fila que sobrevive ao fechamento do app precisa retomar sem
   reanalisar; portanto `DownloadTask.sourceUrl` é obrigatório e persistido.

6. **`restoreQueue()` trata estados órfãos na inicialização.**
   Nenhuma transferência está rodando quando o app abre, então linhas em
   `downloading` viram `paused` (mantendo os bytes) e linhas em
   `connecting` viram `failed` com motivo visível — `connecting` não tem
   aresta para `paused`.

## Consequências

- O motor é testado com fakes em memória: 20 casos cobrem retomada,
  pausa, cancelamento, integridade e falhas de rede, sem tocar em disco ou
  socket.
- A política de fila (simultaneidade 1–8, backoff 1s→2s→4s→8s→16s,
  ações em massa) é testada contra o motor real sobre ports falsos, o que
  exercita a pilha inteira sem I/O.
- Trocar dio por outro cliente, ou `dart:io` pela File System Access API
  no Web, não toca em nenhuma linha da lógica de transferência.
