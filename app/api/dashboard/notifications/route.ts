import { NextRequest, NextResponse } from "next/server";

import { getAuthenticatedUser } from "@/lib/auth";
import { getDashboardNotifications } from "@/lib/dashboard";

export async function GET(request: NextRequest) {
  try {
    const user = await getAuthenticatedUser(request);

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const data = await getDashboardNotifications(user);
    return NextResponse.json({ notifications: data });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unable to load notifications.";

    return NextResponse.json(
      { error: message },
      {
        status: message.includes("DATABASE_URL") ? 503 : 500,
      },
    );
  }
}
