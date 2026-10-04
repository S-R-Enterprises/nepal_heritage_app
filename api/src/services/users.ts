import type { User } from "../../generated/prisma/client";

/// The user shape the Flutter client's `AuthUser` maps onto — the only fields
/// that ever cross the wire. Everything else (hash, IDs) stays server-side.
export interface AuthUserDto {
  id: string;
  fullName: string;
  email: string;
  completedOnboarding: boolean;
}

export function toAuthUser(user: User): AuthUserDto {
  return {
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    completedOnboarding: user.completedOnboarding,
  };
}

/// Phone digits without spaces, as typed on the form.
export function normalizePhone(phone: string): string {
  return phone.replace(/[\s-]/g, "");
}

/// `dialCode + phone` — e.g. `+9779801234567`; what a user would dial abroad.
export function phoneE164(dialCode: string, phone: string): string {
  const dial = normalizePhone(dialCode);
  const local = normalizePhone(phone);
  return dial.startsWith("+") ? `${dial}${local}` : `+${dial}${local}`;
}
