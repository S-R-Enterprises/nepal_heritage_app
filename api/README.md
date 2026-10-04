# Nepal Heritage API

Backend for the **Nepal Heritage** Flutter app, living in the same repo under
`api/`: accounts, sessions, and (next) bookings. The OpenAPI contract at
[`openapi.yaml`](./openapi.yaml) is the source of truth for every endpoint.
Run all commands below from this directory.

## Stack

- **Node 22+ / TypeScript** (strict) — Express 5, Zod validation
- **PostgreSQL 17** via Prisma 7 (`prisma-client` generator, `@prisma/adapter-pg`)
- **jose** (HS256 bearer tokens, 30 days) + **bcryptjs** password hashes
- **Vitest** over real HTTP (no supertest), `yaml-lint` for the contract

## Setup

```bash
# 1. Environment
cp .env.example .env        # then fill DATABASE_URL + JWT_SECRET

# 2. Install (runs `prisma generate` via postinstall)
npm install

# 3. Create the schema in your database
npm run db:migrate          # prisma migrate dev
npm run db:seed             # demo account (visitor@nepalheritage.app)

# 4. Run
npm run dev                 # http://127.0.0.1:3000
```

Local PostgreSQL on this machine: Windows service **`pg17`**
(`net start pg17`), databases `nepal_heritage_dev` / `nepal_heritage_test`.

## Gates (run before every push)

```bash
npm run typecheck           # tsc --noEmit
npm test                    # vitest run (needs the test DB + a migration)
npm run spec:lint           # yaml-lint openapi.yaml
```

Secrets: `gitleaks git --staged --no-banner --redact` (never commit `.env`).

## Endpoints

| Method | Path                     | Auth   | Purpose |
| ------ | ------------------------ | ------ | ------- |
| GET    | `/health`                | —      | Liveness |
| POST   | `/api/v1/auth/register`  | —      | Create account → `{user, token}` |
| POST   | `/api/v1/auth/login`     | —      | Email **or** phone → `{user, token}` |
| POST   | `/api/v1/auth/reset-password` | — | Always 202 (no enumeration) |
| GET    | `/api/v1/me`             | bearer | Session restore |

Error shape everywhere: `{ "error": "<code>", "message": "<UI-safe text>" }`.

## Conventions

- Contract-first: change `openapi.yaml` **with** the implementation in one commit.
- Emails are stored lowercase; phone is stored both split (`dialCode`/`phone`)
  and as `phoneE164` for lookup.
- Register validation mirrors the Flutter mock exactly (same messages), so the
  client's inline hints never drift from server rejections.
