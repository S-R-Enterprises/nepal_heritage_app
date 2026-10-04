import type { NextFunction, Request, Response } from "express";

import { ApiError } from "../errors";
import { verifyToken } from "../services/tokens";

/// Bearer-token guard. Attaches the verified payload to `req.auth` or fails
/// with 401 before the handler runs.
export async function requireAuth(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  const header = req.header("authorization") ?? "";
  const [scheme, token] = header.split(" ");

  if (scheme !== "Bearer" || token === undefined || token === "") {
    next(new ApiError(401, "missing_token", "Sign in to continue."));
    return;
  }

  try {
    req.auth = await verifyToken(token);
    next();
  } catch (err) {
    next(err);
  }
}
