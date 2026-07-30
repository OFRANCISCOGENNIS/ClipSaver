/**
 * Billing endpoints (section 14).
 *
 * Responsibility: HTTP in, HTTP out. Both routes require a valid access
 * token — an entitlement belongs to an account, never to a device.
 */
import { Body, Controller, Get, Post, Req, UseGuards, UsePipes } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { z } from 'zod';
import { ZodValidationPipe } from '../../common/zod-validation.pipe.js';
import { JwtAuthGuard, type AuthenticatedRequest } from '../auth/jwt-auth.guard.js';
import type { EntitlementStatus } from './domain/entitlement.js';
import { BillingService } from './billing.service.js';

const redeemSchema = z.object({
  provider: z.enum(['apple', 'google', 'stripe']),
  // Receipts vary wildly by store; the cap only keeps a multi-megabyte
  // body from reaching the verifier.
  receipt: z.string().min(8).max(16_384),
});

/** Wire shape of the redeem request. */
export type RedeemRequest = z.infer<typeof redeemSchema>;

@ApiTags('billing')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('billing')
export class BillingController {
  constructor(private readonly billing: BillingService) {}

  @Post('redeem')
  @UsePipes(new ZodValidationPipe(redeemSchema))
  @ApiOperation({
    summary: 'Valida um recibo de compra com a loja e ativa o plano',
  })
  @ApiOkResponse({ description: 'Plano vigente após a validação.' })
  redeem(
    @Req() request: AuthenticatedRequest,
    @Body() body: RedeemRequest,
  ): Promise<EntitlementStatus> {
    return this.billing.redeem(request.user.sub, body.provider, body.receipt);
  }

  @Get('status')
  @ApiOperation({ summary: 'Plano vigente do usuário autenticado' })
  @ApiOkResponse({ description: 'free ou premium, com expiração e carência.' })
  status(@Req() request: AuthenticatedRequest): Promise<EntitlementStatus> {
    return this.billing.status(request.user.sub);
  }
}
