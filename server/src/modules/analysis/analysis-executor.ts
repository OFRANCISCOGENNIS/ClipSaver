/**
 * Analysis execution port (section 4.3: "BullMQ + Redis para filas de
 * análise de URL").
 *
 * Responsibility: decouple the HTTP controller from *where* the analysis
 * runs. In production the BullMQ executor pushes the job to Redis and
 * dedicated workers do the fetching (keeping request threads free); in
 * tests and Redis-less dev the inline executor runs it in-process. Both
 * honor the same await-the-result contract the controller needs for the
 * synchronous UX of section 7.2 (10s timeout with retry on the client).
 */
import { Inject, Injectable } from '@nestjs/common';
import { AnalysisService, type AnalysisResponse } from './analysis.service.js';

/** Executes one analysis and resolves with its response. */
export interface AnalysisExecutor {
  execute(url: string): Promise<AnalysisResponse>;
}

/** Nest injection token for the executor. */
export const ANALYSIS_EXECUTOR = Symbol('ANALYSIS_EXECUTOR');

/** Runs the analysis in-process (tests / dev without Redis). */
@Injectable()
export class InlineAnalysisExecutor implements AnalysisExecutor {
  constructor(private readonly service: AnalysisService) {}

  execute(url: string): Promise<AnalysisResponse> {
    return this.service.analyze(url);
  }
}
