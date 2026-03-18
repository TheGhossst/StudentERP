import { NextRequest, NextResponse } from "next/server";

import {
  getClientIp,
  getSessionCookieName,
  getSessionDurationSeconds,
  loginWithEmailAndPassword,
} from "@/lib/auth";

type LoginBody = {
  email?: string;
  password?: string;
};

export async function POST(request: NextRequest) {
  try {
    const body = (await request.json()) as LoginBody;
    const email = body.email?.trim();
    const password = body.password;

    if (!email || !password) {
      return NextResponse.json(
        { error: "Email and password are required." },
        { status: 400 },
      );
    }

    const result = await loginWithEmailAndPassword({
      email,
      password,
      ipAddress: getClientIp(request),
    });

    if (!result.ok || !result.user || !result.token) {
      return NextResponse.json(
        {
          error: result.message,
        },
        {
          status: result.statusCode,
        },
      );
    }

    const response = NextResponse.json({
      message: result.message,
      user: result.user,
    });

    response.cookies.set({
      name: getSessionCookieName(),
      value: result.token,
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      path: "/",
      maxAge: getSessionDurationSeconds(),
    });

    return response;
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unable to complete login.";

    return NextResponse.json(
      { error: message },
      {
        status: message.includes("JWT_SECRET") ? 503 : 500,
      },
    );
  }
}
