import "dotenv/config";
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    env: {
      // Local .env (gitignored) carries the real URL/secret; CI falls back to
      // the workflow's postgres service credentials.
      DATABASE_URL:
        process.env["DATABASE_URL"] ??
        "postgresql://postgres:postgres@127.0.0.1:5432/nepal_heritage_test",
      JWT_SECRET:
        process.env["JWT_SECRET"] ?? "vitest-fallback-secret-0123456789",
      ENV: "test",
    },
    include: ["test/**/*.test.ts"],
  },
});
