/**
 * BullMQ-backed analysis executor (production path of section 4.3).
 *
 * Responsibility: enqueue analysis jobs on Redis and await their results,
 * so HTTP request handlers never block the event loop on origin fetches.
 * Job ids are the sha256 of the URL, which also deduplicates concurrent
 * requests for the same URL into a single job.
 */
import { createHash } from 'node:crypto';
import type { OnModuleDestroy } from '@nestjs/common';
import { Queue, QueueEvents, Worker } from 'bullmq';
import type { Redis } from 'ioredis';
import type { AnalysisExecutor } from './analysis-executor.js';
import type { AnalysisResponse, AnalysisService } from './analysis.service.js';

const QUEUE_NAME = 'analysis';
const JOB_TIMEOUT_MS = 15_000;

export class BullMqAnalysisExecutor implements AnalysisExecutor, OnModuleDestroy {
  private readonly queue: Queue;
  private readonly events: QueueEvents;
  private readonly worker: Worker;

  constructor(connection: Redis, service: AnalysisService) {
    // BullMQ requires maxRetriesPerRequest: null on its connections.
    const opts = { connection: connection.duplicate({ maxRetriesPerRequest: null }) };
    this.queue = new Queue(QUEUE_NAME, opts);
    this.events = new QueueEvents(QUEUE_NAME, opts);
    this.worker = new Worker<{ url: string }, AnalysisResponse>(
      QUEUE_NAME,
      (job) => service.analyze(job.data.url),
      { ...opts, concurrency: 8 },
    );
  }

  async execute(url: string): Promise<AnalysisResponse> {
    const jobId = createHash('sha256').update(url.trim()).digest('hex');
    const job = await this.queue.add(
      'analyze',
      { url },
      { jobId, removeOnComplete: { age: 3600 }, removeOnFail: { age: 3600 } },
    );
    return (await job.waitUntilFinished(this.events, JOB_TIMEOUT_MS)) as AnalysisResponse;
  }

  async onModuleDestroy(): Promise<void> {
    await Promise.allSettled([this.worker.close(), this.events.close(), this.queue.close()]);
  }
}
