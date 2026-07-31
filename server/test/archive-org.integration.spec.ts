/**
 * From an archive.org link to a verdict, through the real pipeline.
 *
 * The unit tests cover the parsing; this covers the wiring, which is
 * where a working parser still ends in the wrong answer: the probe has to
 * consult the Archive's API instead of scraping the item page, and the
 * engine has to reach `official_api` — not `direct_file`, not a refusal.
 */

import { describe, expect, it } from 'vitest';

import { HttpMetadataProbe, type FetchLike } from '../src/modules/analysis/http-metadata-probe.js';
import { toAnalysisContext } from '../src/modules/analysis/metadata-probe.js';
import { EligibilityService } from '../src/modules/eligibility/domain/eligibility.service.js';

/** Records every URL requested, and answers the metadata endpoint. */
function archiveFetch(payload: unknown, status = 200) {
  const requested: string[] = [];
  const fetchImpl: FetchLike = async (url) => {
    requested.push(url);
    return {
      status,
      headers: { get: () => 'application/json' },
      text: async () => JSON.stringify(payload),
    };
  };
  return { fetchImpl, requested };
}

const ITEM = {
  metadata: { identifier: 'aula_aberta' },
  files: [{ name: 'aula.mp4', format: 'h.264', size: '2097152', height: '720' }],
};

describe('archive.org de ponta a ponta', () => {
  const engine = new EligibilityService();

  it('um item público chega a um veredito de API oficial', async () => {
    const { fetchImpl, requested } = archiveFetch(ITEM);
    const url = new URL('https://archive.org/details/aula_aberta');

    const probed = await new HttpMetadataProbe(fetchImpl).probe(url);
    const verdict = engine.evaluate(toAnalysisContext(url, probed));

    expect(verdict.eligible).toBe(true);
    expect(verdict.source).toBe('official_api');
    expect(verdict.availableFormats[0]?.url).toBe(
      'https://archive.org/download/aula_aberta/aula.mp4',
    );
    // A API oficial foi consultada, e a página do item não foi raspada.
    expect(requested).toEqual(['https://archive.org/metadata/aula_aberta']);
  });

  it('um item com empréstimo restrito é recusado, com a explicação do motor',
    async () => {
      const { fetchImpl } = archiveFetch({
        metadata: { 'access-restricted-item': 'true' },
        files: [{ name: 'livro.mp4', format: 'h.264' }],
      });
      const url = new URL('https://archive.org/details/livro');

      const probed = await new HttpMetadataProbe(fetchImpl).probe(url);
      const verdict = engine.evaluate(toAnalysisContext(url, probed));

      expect(verdict.eligible).toBe(false);
      expect(verdict.source).toBe('none');
      expect(verdict.availableFormats).toEqual([]);
      // A recusa é a do motor, não uma inventada pelo probe: o texto
      // educativo é o mesmo para toda plataforma, de propósito.
      expect(verdict.reason).toContain('não permite download');
    });

  it('a API fora do ar recusa em vez de liberar', async () => {
    // Falha fechada: um erro de rede nunca vira permissão.
    const { fetchImpl } = archiveFetch({}, 503);
    const url = new URL('https://archive.org/details/qualquer');

    const probed = await new HttpMetadataProbe(fetchImpl).probe(url);
    const verdict = engine.evaluate(toAnalysisContext(url, probed));

    expect(verdict.eligible).toBe(false);
  });

  it('um link que não é do Archive não consulta a API do Archive', async () => {
    const { fetchImpl, requested } = archiveFetch({});
    const url = new URL('https://exemplo.org/pagina');

    await new HttpMetadataProbe(fetchImpl).probe(url);

    expect(requested.some((entry) => entry.includes('archive.org'))).toBe(false);
  });
});
