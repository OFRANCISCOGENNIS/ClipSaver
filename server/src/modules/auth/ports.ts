/**
 * Persistence ports of the auth module.
 *
 * Responsibility: keep AuthService independent of Prisma so the token
 * rotation logic is unit/e2e-testable without Postgres. Prisma
 * implementations live in `prisma-repositories.ts`; in-memory ones in
 * `in-memory-repositories.ts`.
 */

/** A registered user. Passwords are stored only as bcrypt hashes. */
export interface UserRecord {
  id: string;
  email: string;
  passwordHash: string;
  createdAt: Date;
}

/**
 * One refresh token, stored hashed (sha256). Tokens belong to a family:
 * every rotation keeps the familyId, and reuse of a rotated token revokes
 * the whole family (section 13: "logout invalida a família de tokens").
 */
export interface RefreshTokenRecord {
  id: string;
  userId: string;
  familyId: string;
  tokenHash: string;
  expiresAt: Date;
  /** Set when rotated away or revoked; a used token must never work twice. */
  revokedAt: Date | null;
}

/** User persistence port. */
export interface UsersRepository {
  findByEmail(email: string): Promise<UserRecord | null>;
  findById(id: string): Promise<UserRecord | null>;
  create(user: UserRecord): Promise<UserRecord>;
}

/** Refresh-token persistence port. */
export interface RefreshTokensRepository {
  create(record: RefreshTokenRecord): Promise<void>;
  findByHash(tokenHash: string): Promise<RefreshTokenRecord | null>;
  /** Marks a single token revoked. */
  revoke(id: string, at: Date): Promise<void>;
  /** Revokes every token of a family (logout / reuse detection). */
  revokeFamily(familyId: string, at: Date): Promise<void>;
}

export const USERS_REPOSITORY = Symbol('USERS_REPOSITORY');
export const REFRESH_TOKENS_REPOSITORY = Symbol('REFRESH_TOKENS_REPOSITORY');
