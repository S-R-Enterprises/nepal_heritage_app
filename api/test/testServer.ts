import type { Server } from "node:http";

import { createApp } from "../src/app";
import { disconnectDb } from "../src/db";

export interface TestServer {
  baseUrl: string;
  close: () => Promise<void>;
}

/// Boots the app on an ephemeral port so tests talk to it over real HTTP.
export async function startTestServer(): Promise<TestServer> {
  const app = createApp();
  const server: Server = await new Promise((resolve) => {
    const s = app.listen(0, "127.0.0.1", () => resolve(s));
  });

  const address = server.address();
  if (address === null || typeof address === "string") {
    throw new Error("test server has no port");
  }

  return {
    baseUrl: `http://127.0.0.1:${address.port}`,
    close: async () => {
      await new Promise<void>((resolve, reject) => {
        server.close((err) => (err === undefined ? resolve() : reject(err)));
      });
      await disconnectDb();
    },
  };
}

let uniqueCounter = 0;

export function uniqueEmail(): string {
  uniqueCounter += 1;
  return `t${Date.now()}${uniqueCounter}@example.com`;
}

/// 10-digit Nepali mobile shape that differs per call — the shared test
/// database must never see the same phone from two tests.
export function uniquePhone(): string {
  uniqueCounter += 1;
  return `98${(Date.now() % 100000000).toString().padStart(8, "0")}${uniqueCounter % 10}`;
}

/// A registration body shaped exactly like the Flutter client sends.
export function registerPayload(overrides: Record<string, unknown> = {}) {
  return {
    fullName: "Test Traveller",
    address: "Pokhara, Kaski",
    gender: "female",
    nationalId: `NID-${Date.now()}-${uniqueCounter}`,
    passportNumber: `PSP-${Date.now()}-${uniqueCounter + 1}`,
    dialCode: "+977",
    phone: uniquePhone(),
    email: uniqueEmail(),
    password: "secret1",
    country: "NP",
    audioGuideLanguage: "ne",
    ...overrides,
  };
}
