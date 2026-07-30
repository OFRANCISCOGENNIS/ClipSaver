/**
 * Billing module wiring.
 *
 * Responsibility: register one verifier per store the deployment is
 * actually configured for. A provider without credentials simply is not
 * in the list — `selectVerifier` then refuses it, which is the fail-closed
 * behaviour a paywall needs. Verification never runs on the client's word.
 */
import { Module } from '@nestjs/common';
import { ENV, type Env } from '../../config/env.js';
import { AuthModule } from '../auth/auth.module.js';
import { AppleVerifier } from './apple-verifier.js';
import { BillingController } from './billing.controller.js';
import { BillingService } from './billing.service.js';
import { RECEIPT_VERIFIERS, type ReceiptVerifier } from './domain/receipt-verifier.js';
import { GooglePlayVerifier, type HttpGet } from './google-play-verifier.js';
import { ENTITLEMENTS_REPOSITORY, InMemoryEntitlementsRepository } from './ports.js';
import { StripeVerifier } from './stripe-verifier.js';

/** Node 20+ global fetch, narrowed to what the verifiers call. */
const httpGet: HttpGet = (url, init) => fetch(url, init);

@Module({
  imports: [AuthModule],
  controllers: [BillingController],
  providers: [
    BillingService,
    {
      provide: ENTITLEMENTS_REPOSITORY,
      // Entitlements are re-derivable by re-verifying with the store, so
      // in-memory is acceptable for dev; production persistence follows
      // the auth module's Prisma pattern when the billing tables land.
      useClass: InMemoryEntitlementsRepository,
    },
    {
      provide: RECEIPT_VERIFIERS,
      inject: [ENV],
      useFactory: (env: Env): ReceiptVerifier[] => {
        const verifiers: ReceiptVerifier[] = [];
        if (env.STRIPE_SECRET_KEY) {
          verifiers.push(new StripeVerifier(env.STRIPE_SECRET_KEY, httpGet));
        }
        if (env.GOOGLE_PLAY_PACKAGE && env.GOOGLE_PLAY_ACCESS_TOKEN) {
          // A static token from the environment keeps the wiring honest in
          // staging; production swaps the provider for one that mints
          // tokens via workload identity.
          const token = env.GOOGLE_PLAY_ACCESS_TOKEN;
          verifiers.push(
            new GooglePlayVerifier(env.GOOGLE_PLAY_PACKAGE, async () => token, httpGet),
          );
        }
        if (env.APPLE_API_TOKEN) {
          const token = env.APPLE_API_TOKEN;
          verifiers.push(new AppleVerifier(async () => token, httpGet));
        }
        return verifiers;
      },
    },
  ],
  exports: [BillingService],
})
export class BillingModule {}
