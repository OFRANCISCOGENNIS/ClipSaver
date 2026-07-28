/**
 * Prisma-backed auth repositories (Postgres, section 5).
 *
 * Responsibility: persistence of users and refresh-token families. The
 * Prisma client is loaded lazily and typed structurally so the codebase
 * compiles and tests run without `prisma generate` (the in-memory
 * repositories cover DATABASE_URL-less environments).
 */
import type {
  RefreshTokenRecord,
  RefreshTokensRepository,
  UserRecord,
  UsersRepository,
} from './ports.js';

/** The slice of the generated PrismaClient these repositories use. */
export interface PrismaLike {
  user: {
    findUnique(args: { where: { email?: string; id?: string } }): Promise<UserRecord | null>;
    create(args: { data: UserRecord }): Promise<UserRecord>;
  };
  refreshToken: {
    create(args: { data: RefreshTokenRecord }): Promise<unknown>;
    findUnique(args: { where: { tokenHash: string } }): Promise<RefreshTokenRecord | null>;
    update(args: {
      where: { id: string };
      data: { revokedAt: Date };
    }): Promise<unknown>;
    updateMany(args: {
      where: { familyId: string; revokedAt: null };
      data: { revokedAt: Date };
    }): Promise<unknown>;
  };
}

const clients = new Map<string, Promise<PrismaLike>>();

/**
 * Lazily constructs (and memoizes per URL) the generated Prisma client.
 * Throws a clear error when `prisma generate` has not run yet.
 */
export function createPrismaClient(databaseUrl: string): Promise<PrismaLike> {
  let client = clients.get(databaseUrl);
  if (!client) {
    client = import('@prisma/client').then((mod) => {
      const PrismaClient = (mod as { PrismaClient?: new (args: object) => PrismaLike })
        .PrismaClient;
      if (!PrismaClient) {
        throw new Error('Prisma client não gerado — rode `npx prisma generate`.');
      }
      return new PrismaClient({ datasources: { db: { url: databaseUrl } } });
    });
    clients.set(databaseUrl, client);
  }
  return client;
}

export class PrismaUsersRepository implements UsersRepository {
  constructor(private readonly prisma: PrismaLike) {}

  findByEmail(email: string): Promise<UserRecord | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  findById(id: string): Promise<UserRecord | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  create(user: UserRecord): Promise<UserRecord> {
    return this.prisma.user.create({ data: user });
  }
}

export class PrismaRefreshTokensRepository implements RefreshTokensRepository {
  constructor(private readonly prisma: PrismaLike) {}

  async create(record: RefreshTokenRecord): Promise<void> {
    await this.prisma.refreshToken.create({ data: record });
  }

  findByHash(tokenHash: string): Promise<RefreshTokenRecord | null> {
    return this.prisma.refreshToken.findUnique({ where: { tokenHash } });
  }

  async revoke(id: string, at: Date): Promise<void> {
    await this.prisma.refreshToken.update({ where: { id }, data: { revokedAt: at } });
  }

  async revokeFamily(familyId: string, at: Date): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: at },
    });
  }
}
