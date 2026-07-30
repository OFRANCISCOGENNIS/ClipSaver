/**
 * EligibilityService — the Eligibility Engine (section 2.2).
 *
 * Responsibility: given an [AnalysisContext], decide whether the download
 * is authorized and by which legal basis. The decision pipeline is:
 *
 *   1. URL safety (SSRF) — hard refusal, nothing is ever fetched.
 *   2. DRM — hard refusal, no adapter can override it (golden rule:
 *      compliance beats functionality, always).
 *   3. Ownership (OAuth) — the owner may access their own gated content,
 *      so this runs *before* the paywall/authentication barriers.
 *   4. Paywall / third-party authentication — hard refusal for non-owners.
 *   5. Remaining adapters in priority order: official API → open license
 *      → direct file.
 *   6. No basis found → fail closed with an educational reason.
 *
 * The service is pure and deterministic: same context in, same verdict
 * out. That is what makes the 10 positive / 10 negative acceptance cases
 * (section 18) mechanically verifiable.
 */

import { DirectFileAdapter } from './adapters/direct-file.adapter.js';
import { OfficialApiAdapter } from './adapters/official-api.adapter.js';
import { OpenLicenseAdapter } from './adapters/open-license.adapter.js';
import { UserOwnedAdapter } from './adapters/user-owned.adapter.js';
import { PlatformAdapterRegistry } from './platform-adapter.js';
import type { AnalysisContext, EligibilityResult } from './types.js';
import { checkUrlSafety } from './url-safety.js';

/** Builds an ineligible verdict with a consistent shape. */
function refuse(reason: string): EligibilityResult {
  return {
    eligible: false,
    source: 'none',
    reason,
    availableFormats: [],
    restrictions: [],
  };
}

/** The Eligibility Engine. See module doc for the decision pipeline. */
export class EligibilityService {
  private readonly ownershipRegistry = new PlatformAdapterRegistry();
  private readonly generalRegistry = new PlatformAdapterRegistry();

  constructor() {
    // Ownership runs pre-barrier (step 3); everything else post-barrier.
    this.ownershipRegistry.register(new UserOwnedAdapter());
    this.generalRegistry.register(new OfficialApiAdapter());
    this.generalRegistry.register(new OpenLicenseAdapter());
    this.generalRegistry.register(new DirectFileAdapter());
  }

  /** All registered adapters, for the compliance catalogue endpoint. */
  get adapters() {
    return [...this.ownershipRegistry.list(), ...this.generalRegistry.list()];
  }

  /** Decides eligibility for one analyzed URL. Pure; never fetches. */
  evaluate(context: AnalysisContext): EligibilityResult {
    // 1. SSRF / scheme safety.
    const safety = checkUrlSafety(context.url.href);
    if (!safety.safe) {
      return refuse('Este link não pode ser analisado por segurança. Verifique o endereço.');
    }

    // 2. DRM is an absolute barrier — circumvention is never implemented.
    if (context.drm.detected) {
      return refuse(
        'Este conteúdo é protegido por DRM e não pode ser baixado. ' +
          'Você pode assisti-lo pelo aplicativo oficial da plataforma.',
      );
    }

    // 3. Ownership may authorize access to the user's own gated content.
    const owned = this.ownershipRegistry.evaluate(context);
    if (owned) return owned;

    // 4. Commercial/technical barriers block everyone else.
    if (context.accessControl.paywalled) {
      return refuse(
        'Este conteúdo está atrás de um paywall e não pode ser baixado. ' +
          'Assine o serviço de origem para acessá-lo.',
      );
    }
    if (context.accessControl.requiresAuthentication) {
      return refuse(
        'Este conteúdo exige login na plataforma de origem e não pertence a você. ' +
          'Você pode salvá-lo na sua conta da plataforma de origem.',
      );
    }

    // 5. Official API → open license → direct file.
    const verdict = this.generalRegistry.evaluate(context);
    if (verdict) return verdict;

    // 6. Fail closed, with education instead of a bare "no".
    return refuse(
      'Este conteúdo não permite download: a plataforma não oferece essa opção ' +
        'e não há licença aberta declarada. Você pode salvá-lo na sua conta da ' +
        'plataforma de origem.',
    );
  }
}
