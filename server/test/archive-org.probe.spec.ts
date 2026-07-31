/**
 * Internet Archive item recognition and download permission.
 *
 * The Archive is the first platform Vidora talks to by name, and it is a
 * good first one precisely because it holds both kinds of item: freely
 * downloadable public material, and lending-restricted or dark items that
 * must never be offered. Getting the second kind wrong is the failure
 * that matters — it would mean the app fetched something the Archive
 * deliberately gates.
 */

import { describe, expect, it } from 'vitest';

import {
  archiveFactsFrom,
  archiveIdentifierOf,
  type ArchiveMetadata,
} from '../src/modules/analysis/platform/archive-org.probe.js';

describe('archiveIdentifierOf', () => {
  it('reconhece a página de um item', () => {
    expect(archiveIdentifierOf(new URL('https://archive.org/details/night_of_the_living_dead')))
      .toBe('night_of_the_living_dead');
  });

  it('reconhece o caminho de download direto', () => {
    expect(
      archiveIdentifierOf(new URL('https://archive.org/download/aula_aberta/aula.mp4')),
    ).toBe('aula_aberta');
  });

  it('aceita o subdomínio www', () => {
    expect(archiveIdentifierOf(new URL('https://www.archive.org/details/item'))).toBe('item');
  });

  it('decodifica identificadores com escape', () => {
    expect(archiveIdentifierOf(new URL('https://archive.org/details/a%20b'))).toBe('a b');
  });

  it('devolve nulo para outro host, e o caminho genérico assume', () => {
    expect(archiveIdentifierOf(new URL('https://example.org/details/x'))).toBeNull();
    // Um host que apenas *contém* archive.org não é o Archive.
    expect(archiveIdentifierOf(new URL('https://archive.org.evil.com/details/x'))).toBeNull();
  });

  it('devolve nulo para caminhos que não são de item', () => {
    expect(archiveIdentifierOf(new URL('https://archive.org/'))).toBeNull();
    expect(archiveIdentifierOf(new URL('https://archive.org/search?query=x'))).toBeNull();
    expect(archiveIdentifierOf(new URL('https://archive.org/details/'))).toBeNull();
  });
});

describe('archiveFactsFrom', () => {
  const filme: ArchiveMetadata = {
    metadata: { identifier: 'filme' },
    files: [
      { name: 'filme.mp4', format: 'h.264', size: '1048576', height: '720' },
      { name: 'filme.ogv', format: 'Ogg Video', size: '524288' },
      { name: 'filme_meta.xml', format: 'Metadata', size: '512' },
      { name: 'filme.gif', format: 'Animated GIF', size: '2048' },
    ],
  };

  it('autoriza um item público e lista só o que é mídia', () => {
    const facts = archiveFactsFrom('filme', filme);

    expect(facts.id).toBe('archive_org');
    expect(facts.officialDownloadEnabled).toBe(true);
    // O XML de metadados e o GIF de miniatura não são renditions.
    expect(facts.formats.map((f) => f.id)).toEqual(['filme.mp4', 'filme.ogv']);
  });

  it('monta a URL oficial de download de cada arquivo', () => {
    const [primeiro] = archiveFactsFrom('filme', filme).formats;

    expect(primeiro?.url).toBe('https://archive.org/download/filme/filme.mp4');
    expect(primeiro?.container).toBe('mp4');
    expect(primeiro?.kind).toBe('video');
    expect(primeiro?.height).toBe(720);
    expect(primeiro?.estimatedSizeBytes).toBe(1048576);
  });

  it('escapa o nome do arquivo sem escapar as barras do caminho', () => {
    const facts = archiveFactsFrom('item', {
      files: [{ name: 'pasta/faixa 01.mp3', format: 'VBR MP3' }],
    });

    expect(facts.formats[0]?.url).toBe(
      'https://archive.org/download/item/pasta/faixa%2001.mp3',
    );
  });

  it('recusa um item com empréstimo restrito', () => {
    // Livros e discos em empréstimo controlado: o Archive marca a
    // restrição de propósito, e ignorá-la seria baixar o que ele gateia.
    const facts = archiveFactsFrom('livro', {
      metadata: { 'access-restricted-item': 'true' },
      files: [{ name: 'livro.mp4', format: 'h.264' }],
    });

    expect(facts.officialDownloadEnabled).toBe(false);
    expect(facts.formats).toEqual([]);
  });

  it('recusa também quando a restrição vem como booleano', () => {
    // O Archive responde a string "true" com muito mais frequência, mas as
    // duas grafias aparecem no acervo.
    const facts = archiveFactsFrom('livro', {
      metadata: { 'access-restricted-item': true },
      files: [{ name: 'livro.mp4', format: 'h.264' }],
    });

    expect(facts.officialDownloadEnabled).toBe(false);
  });

  it('recusa um item escurecido', () => {
    const facts = archiveFactsFrom('removido', {
      is_dark: true,
      files: [{ name: 'x.mp4', format: 'h.264' }],
    });

    expect(facts.officialDownloadEnabled).toBe(false);
  });

  it('não autoriza um item sem nenhum arquivo de mídia', () => {
    const facts = archiveFactsFrom('so_texto', {
      files: [{ name: 'livro.pdf', format: 'Text PDF' }],
    });

    expect(facts.officialDownloadEnabled).toBe(false);
    expect(facts.formats).toEqual([]);
  });

  it('sobrevive a um payload sem lista de arquivos', () => {
    expect(archiveFactsFrom('vazio', {}).officialDownloadEnabled).toBe(false);
  });

  it('ignora tamanho e altura inválidos em vez de propagar NaN', () => {
    const [formato] = archiveFactsFrom('item', {
      files: [{ name: 'a.mp3', format: 'VBR MP3', size: 'desconhecido', height: '' }],
    }).formats;

    expect(formato).toBeDefined();
    expect(formato?.estimatedSizeBytes).toBeUndefined();
    expect(formato?.height).toBeUndefined();
  });
});
