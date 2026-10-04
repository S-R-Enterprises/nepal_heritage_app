import { Router } from "express";
import { z } from "zod";

import { db } from "../db";
import { ApiError } from "../errors";
import { requireAuth } from "../middleware/auth";
import { toAuthUser } from "../services/users";

export const meRouter = Router();

async function requireUser(sub: string) {
  const user = await db().user.findUnique({ where: { id: sub } });
  if (user === null) {
    throw new ApiError(401, "invalid_token", "Your session is invalid or has expired.");
  }
  return user;
}

/// Session restore for the Flutter client: who am I, given a bearer token.
meRouter.get("/me", requireAuth, async (req, res) => {
  const payload = req.auth;
  if (payload === undefined) {
    throw new ApiError(401, "missing_token", "Sign in to continue.");
  }

  const user = await requireUser(payload.sub);
  res.json({ user: toAuthUser(user) });
});

const mePatchBody = z.object({
  completedOnboarding: z.boolean(),
});

/// The intro carousel reports back here so later logins skip it. Only fields
/// the client is allowed to self-edit belong in this body.
meRouter.patch("/me", requireAuth, async (req, res) => {
  const payload = req.auth;
  if (payload === undefined) {
    throw new ApiError(401, "missing_token", "Sign in to continue.");
  }

  const data = mePatchBody.parse(req.body);
  await requireUser(payload.sub);

  const user = await db().user.update({
    where: { id: payload.sub },
    data: { completedOnboarding: data.completedOnboarding },
  });
  res.json({ user: toAuthUser(user) });
});
