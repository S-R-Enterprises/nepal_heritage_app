import "dotenv/config";
import bcrypt from "bcryptjs";

import { db, disconnectDb } from "../src/db";

/// The demo account the Flutter app pre-fills on the login screen
/// (`AuthService.demoEmail` / `AuthService.demoPassword`).
const DEMO_EMAIL = "visitor@nepalheritage.app";
const DEMO_PASSWORD = "heritage123";

async function main(): Promise<void> {
  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);
  const user = await db().user.upsert({
    where: { email: DEMO_EMAIL },
    update: {},
    create: {
      fullName: "Demo Visitor",
      email: DEMO_EMAIL,
      address: "Thamel, Kathmandu",
      gender: "other",
      nationalId: "DEMO-NID-0001",
      passportNumber: "DEMO-PSP-0002",
      dialCode: "+977",
      phone: "9800000000",
      phoneE164: "+9779800000000",
      country: "NP",
      audioGuideLanguage: "en",
      passwordHash,
      completedOnboarding: true,
    },
  });
  console.log(`demo account ready: ${user.email}`);
  await disconnectDb();
}

main().catch((err: unknown) => {
  console.error(err);
  process.exit(1);
});
