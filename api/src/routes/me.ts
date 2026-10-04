import { Router } from "express";

import { db } from "../db";
import { ApiError } from "../errors";
import { requireAuth } from "../middleware/auth";
import { toAuthUser } from "../services/users";

export const meRouter = Router();

/// Session restore for the Flutter client: who am I, given a bearer token.
meRouter.get("/me", requireAuth, async (req, res) => {
  const payload = req.auth;
  if (payload === undefined) {
    throw new ApiError(401, "missing_token", "Sign in to continue.");
  }

  const user = await db().user.findUnique({ where: { id: payload.sub } });
  if (user === null) {
    throw new ApiError(401, "invalid_token", "Your session is invalid or has expired.");
  }

  res.json({ user: toAuthUser(user) });
});
