import { SignJWT, jwtVerify } from "jose";

import { config } from "../config";
import { ApiError } from "../errors";
import type { TokenPayload } from "../express";

const SECRET = new TextEncoder().encode(config.JWT_SECRET);

/// Access-token lifetime. Long-lived by design: the Flutter client keeps the
/// session across launches and has no refresh flow yet.
const TOKEN_TTL = "30d";

export async function signToken(payload: TokenPayload): Promise<string> {
  return new SignJWT({ email: payload.email })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(payload.sub)
    .setIssuedAt()
    .setExpirationTime(TOKEN_TTL)
    .sign(SECRET);
}

export async function verifyToken(token: string): Promise<TokenPayload> {
  try {
    const { payload } = await jwtVerify(token, SECRET, { algorithms: ["HS256"] });
    if (typeof payload.sub !== "string" || typeof payload.email !== "string") {
      throw new Error("token is missing claims");
    }
    return { sub: payload.sub, email: payload.email };
  } catch {
    throw new ApiError(401, "invalid_token", "Your session is invalid or has expired.");
  }
}
