import type { NextFunction, Request, Response } from "express";
import { ZodError } from "zod";

/// Error body shape shared by every failure response:
export interface ErrorBody {
  error: string;
  message: string;
}

/// Application error carrying the HTTP status and a stable machine-readable
/// code; the message is what the Flutter client surfaces to the user.
export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export function notFoundHandler(_req: Request, _res: Response, next: NextFunction): void {
  next(new ApiError(404, "not_found", "No such endpoint."));
}

/// Terminal error handler. Must be registered after all routes.
export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof ApiError) {
    res.status(err.status).json({ error: err.code, message: err.message } satisfies ErrorBody);
    return;
  }
  if (err instanceof ZodError) {
    const first = err.issues[0];
    res.status(400).json({
      error: "validation_error",
      message: first?.message ?? "Invalid request body.",
    } satisfies ErrorBody);
    return;
  }
  // Malformed JSON body — body-parser rejects with a 400-status SyntaxError.
  if (
    err instanceof SyntaxError &&
    "status" in err &&
    (err as SyntaxError & { status?: number }).status === 400
  ) {
    res.status(400).json({
      error: "invalid_json",
      message: "Request body is not valid JSON.",
    } satisfies ErrorBody);
    return;
  }
  // Unexpected failure — log it, never leak internals to the client.
  console.error("unhandled error:", err);
  res.status(500).json({
    error: "internal_error",
    message: "Something went wrong. Please try again.",
  } satisfies ErrorBody);
}
