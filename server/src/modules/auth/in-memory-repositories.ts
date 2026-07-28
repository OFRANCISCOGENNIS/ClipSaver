/**
 * In-memory auth repositories for tests and Postgres-less development.
 * Same contract as the Prisma implementations, no persistence.
 */
import type {
  RefreshTokenRecord,
  RefreshTokensRepository,
  UserRecord,
  UsersRepository,
} from './ports.js';

export class InMemoryUsersRepository implements UsersRepository {
  private readonly users = new Map<string, UserRecord>();

  async findByEmail(email: string): Promise<UserRecord | null> {
    for (const user of this.users.values()) {
      if (user.email === email) return user;
    }
    return null;
  }

  async findById(id: string): Promise<UserRecord | null> {
    return this.users.get(id) ?? null;
  }

  async create(user: UserRecord): Promise<UserRecord> {
    this.users.set(user.id, user);
    return user;
  }
}

export class InMemoryRefreshTokensRepository implements RefreshTokensRepository {
  private readonly tokens = new Map<string, RefreshTokenRecord>();

  async create(record: RefreshTokenRecord): Promise<void> {
    this.tokens.set(record.id, { ...record });
  }

  async findByHash(tokenHash: string): Promise<RefreshTokenRecord | null> {
    for (const token of this.tokens.values()) {
      if (token.tokenHash === tokenHash) return { ...token };
    }
    return null;
  }

  async revoke(id: string, at: Date): Promise<void> {
    const token = this.tokens.get(id);
    if (token && token.revokedAt === null) token.revokedAt = at;
  }

  async revokeFamily(familyId: string, at: Date): Promise<void> {
    for (const token of this.tokens.values()) {
      if (token.familyId === familyId && token.revokedAt === null) {
        token.revokedAt = at;
      }
    }
  }
}
