import { afterAll, beforeAll, describe, expect, it } from "vitest";

import { startTestServer, type TestServer } from "./testServer";

let ts: TestServer;

beforeAll(async () => {
  ts = await startTestServer();
});

afterAll(async () => {
  await ts.close();
});

describe("GET /health", () => {
  it("reports ok", async () => {
    const res = await fetch(`${ts.baseUrl}/health`);
    expect(res.status).toBe(200);
    expect(await res.json()).toMatchObject({ status: "ok", service: "nepal-heritage-api" });
  });

  it("404s unknown endpoints in the shared error shape", async () => {
    const res = await fetch(`${ts.baseUrl}/nope`);
    expect(res.status).toBe(404);
    expect(await res.json()).toMatchObject({ error: "not_found" });
  });
});
