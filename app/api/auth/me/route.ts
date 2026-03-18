import { NextRequest, NextResponse } from "next/server";

import { getAuthenticatedUser } from "@/lib/auth";

export async function GET(request: NextRequest) {
  try {
    const user = await getAuthenticatedUser(request);

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    return NextResponse.json({ user });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unable to validate session.";

    return NextResponse.json(
      { error: message },
      {
        status: message.includes("JWT_SECRET") ? 503 : 500,
      },
    );
  }
}