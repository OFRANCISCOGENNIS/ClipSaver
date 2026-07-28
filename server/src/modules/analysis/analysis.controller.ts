/**
 * HTTP surface of the analysis module.
 *
 * Responsibility: validate input (zod), delegate to the executor and
 * shape the OpenAPI contract. No business logic lives here.
 */
import { Body, Controller, HttpCode, Inject, Post } from '@nestjs/common';
import { ApiBody, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { z } from 'zod';
import { ZodValidationPipe } from '../../common/zod-validation.pipe.js';
import { ANALYSIS_EXECUTOR, type AnalysisExecutor } from './analysis-executor.js';
import type { AnalysisResponse } from './analysis.service.js';

const analyzeBodySchema = z.object({
  /** Client sends the raw URL; full SSRF validation happens server-side. */
  url: z.string().min(1).max(2048),
});

type AnalyzeBody = z.infer<typeof analyzeBodySchema>;

@ApiTags('analysis')
@Controller('analysis')
export class AnalysisController {
  constructor(@Inject(ANALYSIS_EXECUTOR) private readonly executor: AnalysisExecutor) {}

  @Post()
  @HttpCode(200)
  // Analysis triggers origin fetches — stricter than the global limit.
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @ApiOperation({
    summary: 'Analisa uma URL: metadados + decisão de elegibilidade',
    description:
      'Idempotente por 24h para a mesma URL (cache). Nunca busca conteúdo ' +
      'atrás de DRM, paywall ou autenticação de terceiros.',
  })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['url'],
      properties: {
        url: { type: 'string', maxLength: 2048, example: 'https://example.com/talk.mp4' },
      },
    },
  })
  @ApiOkResponse({ description: 'Veredicto de elegibilidade com metadados.' })
  analyze(@Body(new ZodValidationPipe(analyzeBodySchema)) body: AnalyzeBody): Promise<AnalysisResponse> {
    return this.executor.execute(body.url);
  }
}
