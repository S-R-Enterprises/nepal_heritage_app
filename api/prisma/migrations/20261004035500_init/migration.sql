-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "address" TEXT NOT NULL DEFAULT '',
    "gender" TEXT NOT NULL,
    "nationalId" TEXT NOT NULL DEFAULT '',
    "passportNumber" TEXT NOT NULL DEFAULT '',
    "dialCode" TEXT NOT NULL DEFAULT '',
    "phone" TEXT NOT NULL DEFAULT '',
    "phoneE164" TEXT,
    "country" TEXT NOT NULL DEFAULT 'NP',
    "audioGuideLanguage" TEXT NOT NULL DEFAULT 'en',
    "passwordHash" TEXT NOT NULL,
    "completedOnboarding" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_dialCode_phone_idx" ON "User"("dialCode", "phone");

-- CreateIndex
CREATE INDEX "User_phoneE164_idx" ON "User"("phoneE164");
