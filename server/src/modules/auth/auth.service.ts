/**
 * Authentication service (section 13): bcrypt password hashing, access
 * JWT of 15 minutes, refresh tokens with rotation, and family-wide
 * revocation on logout or reuse detection.
 *
 * Responsibility: all credential and token lifecycle rules. HTTP concerns
 * (status codes, cookies vs body) stay in the controller; persistence
 * stays behind the ports.
 */
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import {
  ConflictException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import bcrypt from 'bcryptjs';
import { ENV, type Env } from '../../config/env.js';
import {
  REFRESH_TOKENS_REPOSITORY,
  USERS_REPOSITORY,
  type RefreshTokensRepository,
  type UsersRepository,
} from './ports.js';

/** Token pair returned by login/refresh. */
export interface TokenPair {
  accessToken: string;
  /** Opaque, single-use value; rotation invalidates it after one refresh. */
  refreshToken: string;
  /** Access token lifetime in seconds, for client-side scheduling. */
  expiresIn: number;
}

/** Claims carried by the access JWT. */
export interface AccessClaims {
  sub: string;
  email: string;
}

const BCRYPT_ROUNDS = 12;

@Injectable()
export class AuthService {
  constructor(
    @Inject(USERS_REPOSITORY) private readonly users: UsersRepository,
    @Inject(REFRESH_TOKENS_REPOSITORY) private readonly refreshTokens: RefreshTokensRepository,
    @Inject(ENV) private readonly env: Env,
    private readonly jwt: JwtService,
  ) {}

  /** Creates an account; e-mails are unique. */
  async register(email: string, password: string): Promise<{ id: string; email: string }> {
    const existing = await this.users.findByEmail(email);
    if (existing) {
      throw new ConflictException('E-mail já cadastrado.');
    }
    const user = await this.users.create({
      id: randomUUID(),
      email,
      passwordHash: await bcrypt.hash(password, BCRYPT_ROUNDS),
      createdAt: new Date(),
    });
    return { id: user.id, email: user.email };
  }

  /** Verifies credentials and issues a fresh token family. */
  async login(email: string, password: string): Promise<TokenPair> {
    const user = await this.users.findByEmail(email);
    // Hash comparison runs even for unknown users (constant-shape timing).
    const hash = user?.passwordHash ?? (await bcrypt.hash(randomUUID(), 4));
    const valid = await bcrypt.compare(password, hash);
    if (!user || !valid) {
      throw new UnauthorizedException('Credenciais inválidas.');
    }
    return this.issuePair(user.id, user.email, randomUUID());
  }

  /**
   * Rotates a refresh token. Reuse of an already-rotated token is treated
   * as theft: the entire family is revoked and the caller must log in
   * again.
   */
  async refresh(refreshToken: string): Promise<TokenPair> {
    const record = await this.refreshTokens.findByHash(sha256(refreshToken));
    if (!record) {
      throw new UnauthorizedException('Sessão inválida. Faça login novamente.');
    }
    const now = new Date();
    if (record.revokedAt !== null) {
      // Reuse detected — kill the family.
      await this.refreshTokens.revokeFamily(record.familyId, now);
      throw new UnauthorizedException('Sessão revogada por segurança. Faça login novamente.');
    }
    if (record.expiresAt <= now) {
      throw new UnauthorizedException('Sessão expirada. Faça login novamente.');
    }
    const user = await this.users.findById(record.userId);
    if (!user) {
      throw new UnauthorizedException('Sessão inválida. Faça login novamente.');
    }
    await this.refreshTokens.revoke(record.id, now);
    return this.issuePair(user.id, user.email, record.familyId);
  }

  /** Revokes the whole family of [refreshToken] (logout everywhere). */
  async logout(refreshToken: string): Promise<void> {
    const record = await this.refreshTokens.findByHash(sha256(refreshToken));
    // Unknown token: nothing to do — logout is idempotent.
    if (record) {
      await this.refreshTokens.revokeFamily(record.familyId, new Date());
    }
  }

  /** Verifies an access JWT, returning its claims. */
  async verifyAccessToken(token: string): Promise<AccessClaims> {
    try {
      return await this.jwt.verifyAsync<AccessClaims>(token, { secret: this.env.JWT_SECRET });
    } catch {
      throw new UnauthorizedException('Token inválido ou expirado.');
    }
  }

  private async issuePair(userId: string, email: string, familyId: string): Promise<TokenPair> {
    const refreshToken = randomBytes(48).toString('base64url');
    await this.refreshTokens.create({
      id: randomUUID(),
      userId,
      familyId,
      tokenHash: sha256(refreshToken),
      expiresAt: new Date(Date.now() + this.env.REFRESH_TTL_SECONDS * 1000),
      revokedAt: null,
    });
    const accessToken = await this.jwt.signAsync(
      { sub: userId, email } satisfies AccessClaims,
      { secret: this.env.JWT_SECRET, expiresIn: this.env.JWT_ACCESS_TTL_SECONDS },
    );
    return { accessToken, refreshToken, expiresIn: this.env.JWT_ACCESS_TTL_SECONDS };
  }
}

function sha256(value: string): string {
  return createHash('sha256').update(value).digest('hex');
}
