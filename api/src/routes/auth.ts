import { Router } from "express";
import { z } from "zod";

import { db } from "../db";
import { ApiError } from "../errors";
import {
  MIN_PASSWORD_LENGTH,
  hashPassword,
  verifyPassword,
} from "../services/password";
import { signToken } from "../services/tokens";
import { normalizePhone, phoneE164, toAuthUser } from "../services/users";

export const authRouter = Router();

const passwordField = z
  .string()
  .min(MIN_PASSWORD_LENGTH, `Password must be at least ${MIN_PASSWORD_LENGTH} characters.`);

/// Exactly the fields `RegistrationRequest.toJson()` sends from Flutter.
const registerBody = z.object({
  fullName: z.string().trim().min(1, "Enter your full name."),
  address: z.string().default(""),
  gender: z.enum(["male", "female", "other"]),
  nationalId: z.string().default(""),
  passportNumber: z.string().default(""),
  dialCode: z.string().min(1, "Enter your country dial code."),
  phone: z.string().min(1, "Enter your phone number."),
  email: z.email("Enter a valid email address."),
  password: passwordField,
  country: z.string().length(2, "Country must be an ISO 3166-1 alpha-2 code.").default("NP"),
  audioGuideLanguage: z.string().min(2).default("en"),
});

authRouter.post("/register", async (req, res) => {
  const data = registerBody.parse(req.body);

  // Parity with the Flutter mock: the two IDs must differ — including when
  // both are blank, so the form can never submit without one of them.
  if (data.nationalId.trim().toLowerCase() === data.passportNumber.trim().toLowerCase()) {
    throw new ApiError(
      400,
      "validation_error",
      "National ID and passport number must be different.",
    );
  }

  const email = data.email.trim().toLowerCase();
  if ((await db().user.findUnique({ where: { email } })) !== null) {
    throw new ApiError(409, "email_exists", "An account with this email already exists.");
  }

  const user = await db().user.create({
    data: {
      fullName: data.fullName,
      email,
      address: data.address.trim(),
      gender: data.gender,
      nationalId: data.nationalId.trim(),
      passportNumber: data.passportNumber.trim(),
      dialCode: normalizePhone(data.dialCode),
      phone: normalizePhone(data.phone),
      phoneE164: phoneE164(data.dialCode, data.phone),
      country: data.country,
      audioGuideLanguage: data.audioGuideLanguage,
      passwordHash: await hashPassword(data.password),
    },
  });

  res.status(201).json({
    user: toAuthUser(user),
    token: await signToken({ sub: user.id, email: user.email }),
  });
});

const loginBody = z.object({
  identifier: z.string().trim().min(1, "Enter your email or phone number."),
  password: passwordField,
  rememberMe: z.boolean().default(false),
});

/// Email (case-insensitive) or phone — as local digits, with or without the
/// country prefix, or exactly as stored in `phoneE164`.
async function findByIdentifier(identifier: string) {
  if (identifier.includes("@")) {
    return db().user.findUnique({ where: { email: identifier.toLowerCase() } });
  }
  const prefixed = identifier.startsWith("+") ? identifier : `+${identifier}`;
  return db().user.findFirst({
    where: {
      OR: [{ phoneE164: identifier }, { phoneE164: prefixed }, { phone: identifier }],
    },
  });
}

authRouter.post("/login", async (req, res) => {
  const { identifier, password } = loginBody.parse(req.body);

  const user = await findByIdentifier(identifier);
  // One message for both failure modes — never reveal which identifiers exist.
  if (user === null || !(await verifyPassword(password, user.passwordHash))) {
    throw new ApiError(401, "invalid_credentials", "Incorrect email/phone or password.");
  }

  res.json({
    user: toAuthUser(user),
    token: await signToken({ sub: user.id, email: user.email }),
  });
});

const resetBody = z.object({
  identifier: z.string().trim().min(1, "Enter your email or phone number."),
});

authRouter.post("/reset-password", async (req, res) => {
  resetBody.parse(req.body);

  // Always the same answer: whether an account exists must not leak here.
  // Link delivery (email/SMS) is a later slice; the mock behaves identically.
  res.status(202).json({ message: "If an account exists, a reset link has been sent." });
});
