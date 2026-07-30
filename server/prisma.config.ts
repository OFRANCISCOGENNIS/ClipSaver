/**
 * Prisma 7 configuration.
 *
 * Prisma 7 removed `url` from the schema's `datasource` block: a
 * connection string is a deployment concern, and keeping it in the file
 * that also describes the tables made the schema unusable without an
 * environment. The CLI reads it from here; the client receives it through
 * a driver adapter (see `createPrismaClient`).
 */
import { defineConfig } from 'prisma/config';

// Read directly rather than through Prisma's `env()`, which throws when
// the variable is absent. `prisma generate` never connects to anything —
// demanding a live connection string just to emit types would make the
// container image build depend on a database that does not exist yet.
const url = process.env.DATABASE_URL;

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  ...(url ? { datasource: { url } } : {}),
});
