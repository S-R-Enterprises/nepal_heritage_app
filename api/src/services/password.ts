import bcrypt from "bcryptjs";

/// Shortest password the API accepts — mirrors `minPasswordLength` in the
/// Flutter client so inline hints and server rejections cannot drift apart.
export const MIN_PASSWORD_LENGTH = 6;

const ROUNDS = 10;

export async function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, ROUNDS);
}

export async function verifyPassword(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}
