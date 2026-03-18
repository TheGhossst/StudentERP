import { NextResponse } from "next/server";

import { getSessionCookieName } from "@/lib/auth";

export async function POST() {
  const response = NextResponse.json({ message: "Logged out." });

  response.cookies.set({
    name: getSessionCookieName(),
    value: "",
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 0,
  });

  return response;
}