import { afterAll, beforeAll, describe, expect, it } from "vitest";

import {
  registerPayload,
  startTestServer,
  uniqueEmail,
  type TestServer,
} from "./testServer";

let ts: TestServer;

beforeAll(async () => {
  ts = await startTestServer();
});

afterAll(async () => {
  await ts.close();
});

function post(path: string, body: unknown, token?: string) {
  return fetch(`${ts.baseUrl}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(token === undefined ? {} : { Authorization: `Bearer ${token}` }),
    },
    body: JSON.stringify(body),
  });
}

interface AuthResponse {
  user: {
    id: string;
    fullName: string;
    email: string;
    completedOnboarding: boolean;
  };
  token: string;
}

describe("POST /api/v1/auth/register", () => {
  it("creates an account and returns a token", async () => {
    const payload = registerPayload({ fullName: "Sita Sharma" });
    const res = await post("/api/v1/auth/register", payload);

    expect(res.status).toBe(201);
    const body = (await res.json()) as AuthResponse;
    expect(body.user.fullName).toBe("Sita Sharma");
    expect(body.user.email).toBe(String(payload.email).toLowerCase());
    expect(body.user.completedOnboarding).toBe(false);
    expect(body.token).toBeTruthy();
  });

  it("rejects a duplicate email with 409, ignoring case", async () => {
    const email = uniqueEmail();
    expect((await post("/api/v1/auth/register", registerPayload({ email }))).status).toBe(201);

    const res = await post(
      "/api/v1/auth/register",
      registerPayload({ email: email.toUpperCase() }),
    );
    expect(res.status).toBe(409);
    expect(await res.json()).toMatchObject({ error: "email_exists" });
  });

  it("keeps the client's password message verbatim", async () => {
    const res = await post("/api/v1/auth/register", registerPayload({ password: "abc" }));
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({
      error: "validation_error",
      message: "Password must be at least 6 characters.",
    });
  });

  it("rejects equal national ID and passport number", async () => {
    const res = await post(
      "/api/v1/auth/register",
      registerPayload({ nationalId: "SAME123", passportNumber: "  same123 " }),
    );
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({
      message: "National ID and passport number must be different.",
    });
  });

  it("rejects a missing gender", async () => {
    const payload = registerPayload();
    delete (payload as Record<string, unknown>)["gender"];
    const res = await post("/api/v1/auth/register", payload);
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({ error: "validation_error" });
  });
});

describe("POST /api/v1/auth/login", () => {
  it("signs in with email and the registered password", async () => {
    const payload = registerPayload();
    await post("/api/v1/auth/register", payload);

    const res = await post("/api/v1/auth/login", {
      identifier: String(payload.email).toUpperCase(),
      password: payload.password,
      rememberMe: true,
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as AuthResponse;
    expect(body.user.email).toBe(String(payload.email).toLowerCase());
    expect(body.token).toBeTruthy();
  });

  it("signs in with the phone number as typed on the form", async () => {
    const payload = registerPayload();
    await post("/api/v1/auth/register", payload);

    const res = await post("/api/v1/auth/login", {
      identifier: payload.phone,
      password: payload.password,
      rememberMe: false,
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as AuthResponse;
    expect(body.user.email).toBe(String(payload.email).toLowerCase());
  });

  it("answers 401 for a wrong password", async () => {
    const payload = registerPayload();
    await post("/api/v1/auth/register", payload);

    const res = await post("/api/v1/auth/login", {
      identifier: payload.email,
      password: "wrong-password",
      rememberMe: false,
    });
    expect(res.status).toBe(401);
    expect(await res.json()).toMatchObject({ error: "invalid_credentials" });
  });

  it("answers 401 for an unknown identifier with the same message", async () => {
    const unknown = await post("/api/v1/auth/login", {
      identifier: uniqueEmail(),
      password: "whatever1",
      rememberMe: false,
    });
    expect(unknown.status).toBe(401);
    expect(await unknown.json()).toMatchObject({ error: "invalid_credentials" });
  });

  it("keeps the client's short-password message on login too", async () => {
    const res = await post("/api/v1/auth/login", {
      identifier: uniqueEmail(),
      password: "abc",
      rememberMe: false,
    });
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({
      message: "Password must be at least 6 characters.",
    });
  });
});

describe("POST /api/v1/auth/reset-password", () => {
  it("answers 202 for a known account", async () => {
    const payload = registerPayload();
    await post("/api/v1/auth/register", payload);

    const res = await post("/api/v1/auth/reset-password", { identifier: payload.email });
    expect(res.status).toBe(202);
    expect(await res.json()).toMatchObject({ message: expect.any(String) });
  });

  it("answers identically for an unknown identifier (no enumeration)", async () => {
    const known = await post("/api/v1/auth/reset-password", {
      identifier: uniqueEmail(),
    });
    expect(known.status).toBe(202);
    const body = (await known.json()) as { message: string };

    const payload = registerPayload();
    await post("/api/v1/auth/register", payload);
    const unknown = await post("/api/v1/auth/reset-password", {
      identifier: payload.email,
    });
    expect(unknown.status).toBe(202);
    expect(await unknown.json()).toStrictEqual(body);
  });

  it("rejects an empty identifier", async () => {
    const res = await post("/api/v1/auth/reset-password", { identifier: "" });
    expect(res.status).toBe(400);
    expect(await res.json()).toMatchObject({ error: "validation_error" });
  });
});

describe("GET /api/v1/me", () => {
  it("returns the signed-in user", async () => {
    const payload = registerPayload({ fullName: "Aarav Gurung" });
    const registered = (await (
      await post("/api/v1/auth/register", payload)
    ).json()) as AuthResponse;

    const res = await fetch(`${ts.baseUrl}/api/v1/me`, {
      headers: { Authorization: `Bearer ${registered.token}` },
    });
    expect(res.status).toBe(200);
    const body = (await res.json()) as { user: AuthResponse["user"] };
    expect(body.user.id).toBe(registered.user.id);
    expect(body.user.fullName).toBe("Aarav Gurung");
  });

  it("401s without a token", async () => {
    const res = await fetch(`${ts.baseUrl}/api/v1/me`);
    expect(res.status).toBe(401);
    expect(await res.json()).toMatchObject({ error: "missing_token" });
  });

  it("401s on a garbage token", async () => {
    const res = await fetch(`${ts.baseUrl}/api/v1/me`, {
      headers: { Authorization: "Bearer not.a.jwt" },
    });
    expect(res.status).toBe(401);
    expect(await res.json()).toMatchObject({ error: "invalid_token" });
  });
});
