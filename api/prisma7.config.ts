import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    // Placeholder lets `prisma generate` run without env (CI typecheck etc.);
    // migrations always run with the real DATABASE_URL from .env / workflow.
    url:
      process.env["DATABASE_URL"] ??
      "postgresql://postgres:postgres@127.0.0.1:5432/postgres",
  },
});
