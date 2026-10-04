import express from "express";

import { errorHandler, notFoundHandler } from "./errors";
import { authRouter } from "./routes/auth";
import { healthRouter } from "./routes/health";
import { meRouter } from "./routes/me";

/// Assembles the app without listening — tests bind their own ephemeral port.
export function createApp(): express.Express {
  const app = express();

  app.disable("x-powered-by");
  app.use(express.json());

  app.use("/health", healthRouter);
  app.use("/api/v1/auth", authRouter);
  app.use("/api/v1", meRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
