/// Payload embedded in every access token.
export interface TokenPayload {
  sub: string;
  email: string;
}

declare global {
  namespace Express {
    interface Request {
      /// Set by `requireAuth`; absent on public routes and after a 401.
      auth?: TokenPayload;
    }
  }
}

export {};
