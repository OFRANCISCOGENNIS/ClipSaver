/**
 * Health check port (section 17: probes de liveness e readiness).
 *
 * Responsibility: describe one dependency that readiness depends on,
 * without saying how it is reached. The service composes indicators; the
 * controller only translates the aggregate into a status code.
 */

/** Outcome of a single dependency check. */
export interface IndicatorResult {
  /** Stable identifier used as the key in the JSON payload. */
  readonly name: string;
  /** True when the dependency answered correctly within the deadline. */
  readonly healthy: boolean;
  /** Round-trip time in milliseconds, including a timed-out attempt. */
  readonly durationMs: number;
  /** Present only when unhealthy; a short, non-sensitive reason. */
  readonly error?: string;
}

/** One checkable dependency. */
export interface HealthIndicator {
  /** Key this indicator reports under. */
  readonly name: string;

  /**
   * Performs the check. Implementations should do the smallest possible
   * round trip — readiness runs on every probe interval, so an expensive
   * check turns into steady load against the very dependency it guards.
   */
  check(): Promise<void>;
}

/** Nest injection token for the readiness indicator list. */
export const HEALTH_INDICATORS = Symbol('HEALTH_INDICATORS');

/** Redis reachability via `PING`. */
export class RedisIndicator implements HealthIndicator {
  readonly name = 'redis';

  constructor(private readonly redis: { ping(): Promise<string> }) {}

  async check(): Promise<void> {
    const reply = await this.redis.ping();
    // A connection that answers something other than PONG is a proxy or a
    // wrong port, not Redis — treating it as healthy would route traffic
    // to a pod whose queue writes will fail.
    if (reply !== 'PONG') throw new Error(`resposta inesperada do PING: ${reply}`);
  }
}

/** The slice of a Prisma client the database indicator needs. */
export interface QueryablePrisma {
  $queryRaw(strings: TemplateStringsArray, ...values: unknown[]): Promise<unknown>;
}

/** Postgres reachability via `SELECT 1`. */
export class PrismaIndicator implements HealthIndicator {
  readonly name = 'database';

  constructor(private readonly prisma: QueryablePrisma) {}

  async check(): Promise<void> {
    await this.prisma.$queryRaw`SELECT 1`;
  }
}
