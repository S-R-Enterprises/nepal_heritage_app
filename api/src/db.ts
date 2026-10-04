import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../generated/prisma/client";

let client: PrismaClient | undefined;

/// Shared Prisma client (lazy so importing a module never requires a live
/// database — e.g. during `tsc --noEmit` in CI).
export function db(): PrismaClient {
  if (client === undefined) {
    const url = process.env["DATABASE_URL"];
    if (url === undefined || url === "") {
      throw new Error("DATABASE_URL is not set");
    }
    client = new PrismaClient({ adapter: new PrismaPg({ connectionString: url }) });
  }
  return client;
}

export async function disconnectDb(): Promise<void> {
  await client?.$disconnect();
  client = undefined;
}
