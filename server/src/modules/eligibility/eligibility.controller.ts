/**
 * Public catalogue of platform adapters (section 2.2: registro de
 * adaptadores com base legal documentada).
 *
 * Responsibility: expose the audit trail that feeds the app's
 * "Política de uso responsável" page.
 */
import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { EligibilityService } from './domain/eligibility.service.js';

/** Wire shape of one catalogue entry. */
export interface AdapterCatalogueEntry {
  id: string;
  legalBasis: string;
  officialEndpoint: string;
  tosUrl?: string;
}

@ApiTags('eligibility')
@Controller('eligibility')
export class EligibilityController {
  constructor(private readonly service: EligibilityService) {}

  @Get('adapters')
  @ApiOperation({ summary: 'Catálogo de adaptadores com base legal (auditoria)' })
  @ApiOkResponse({ description: 'Lista de adaptadores registrados.' })
  adapters(): AdapterCatalogueEntry[] {
    return this.service.adapters.map((adapter) => {
      const entry: AdapterCatalogueEntry = {
        id: adapter.id,
        legalBasis: adapter.legalBasis,
        officialEndpoint: adapter.officialEndpoint,
      };
      if (adapter.tosUrl !== undefined) entry.tosUrl = adapter.tosUrl;
      return entry;
    });
  }
}
