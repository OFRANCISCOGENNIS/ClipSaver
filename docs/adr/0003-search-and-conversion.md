# ADR-0003 — Busca FTS5 e execução de conversões

- **Status**: aceito
- **Data**: 2026-07-29
- **Fase**: 4

## Contexto

A seção 10 pede busca local em menos de 50ms para 10.000 itens, com
tolerância a erro de digitação e filtros combináveis. A seção 11 pede um
conversor FFmpeg com presets, modo avançado e fila própria. As duas
esbarraram em limitações de ferramentas que exigiram decisão explícita.

## Decisões

1. **O índice FTS5 é criado e consultado com SQL direto, não via drift.**
   O `drift_dev` 2.28 falha ao serializar tabelas virtuais FTS5: ele nunca
   as registra em `allSchemaEntities`, então `createAll()` as ignora em
   silêncio — a busca compilaria e falharia só em tempo de execução.
   Consultas FTS5 exigem SQL bruto de qualquer forma, então declarar a
   tabela em `search_index.dart` não custa nada e mantém o schema sob
   nosso controle.

2. **O índice é mantido na mesma transação da linha da biblioteca**, e não
   por triggers. Um trigger seria invisível do lado Dart; o repositório,
   sim, é testável — e os testes provam que renomear, editar etiquetas,
   mandar para a lixeira e purgar mantêm índice e tabela em passo.

3. **`remove_diacritics 2` no tokenizer.** Sem isso, "musica" não encontra
   "música" — inaceitável na locale de lançamento.

4. **Toda entrada do usuário vira expressão FTS5 escapada.** Cada token é
   citado, o que neutraliza `OR`, `NEAR`, `*` e `-` digitados sem
   intenção. Sem isso, uma aspa solta viraria erro de sintaxe na cara do
   usuário.

5. **Tolerância a erro é um fallback, não o caminho principal.** A busca
   exata roda primeiro; só quando ela não retorna nada é que a distância
   de edição 1 entra, e o resultado é marcado para a UI poder dizer que os
   resultados são aproximados.

6. **O construtor de comando FFmpeg é código puro e testado.**
   As decisões sutis — `-ss` antes do `-i` (busca por keyframe, ordens de
   magnitude mais rápida), `-c copy` quando o pedido é só um corte,
   nunca passar `-b:a` para codecs sem perdas, `scale=-2:altura` para
   largura par — vivem em um lugar com testes, não dentro de uma chamada
   de processo.

7. **A fila de conversão não é persistida.** Diferente dos downloads, que
   a seção 18 exige que sobrevivam a um reinício, uma conversão
   interrompida não tem saída parcial aproveitável: o FFmpeg escreve em
   arquivo temporário descartado no aborto. Persistir a fila só
   ressuscitaria trabalho já jogado fora.

8. **Concorrência de conversão é 1 por padrão.** O FFmpeg satura CPU;
   rodar várias deixaria todas mais lentas e disputaria o frame budget da
   UI.

9. **Nenhuma implementação concreta de `MediaConverter` nesta fase.**
   O `ffmpeg_kit_flutter`, nomeado na tabela de tecnologias original, foi
   descontinuado pelo mantenedor e teve os binários pré-compilados
   retirados. Escolher o substituto (binário embarcado por plataforma,
   platform channel, ou FFmpeg.wasm no Web) é uma decisão deliberada, não
   algo em que se cai por inércia. Tudo acima do port está pronto e
   testado; o provider falha com mensagem clara até que a escolha seja
   feita.

## Consequências

- A busca é exercitada contra SQLite real nos testes (29 casos), incluindo
  acentuação, prefixo, erro de digitação e manutenção do índice.
- O conversor tem 55 testes sem executar FFmpeg uma única vez.
- A troca do backend de conversão não toca em nenhuma linha da fila, dos
  presets ou da UI.
