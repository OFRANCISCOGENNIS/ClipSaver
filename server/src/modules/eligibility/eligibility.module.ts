/**
 * Eligibility module: exposes the pure domain engine to the rest of the
 * app and the adapter catalogue to the compliance page.
 */
import { Module } from '@nestjs/common';
import { EligibilityService } from './domain/eligibility.service.js';
import { EligibilityController } from './eligibility.controller.js';

@Module({
  controllers: [EligibilityController],
  providers: [{ provide: EligibilityService, useValue: new EligibilityService() }],
  exports: [EligibilityService],
})
export class EligibilityModule {}
