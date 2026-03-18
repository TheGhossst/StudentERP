import { NextRequest, NextResponse } from "next/server";

import { getAuthenticatedUser, userHasAnyRole, userHasBaseRole } from "@/lib/auth";
import { getDashboardStats } from "@/lib/dashboard";

export async function GET(request: NextRequest) {
  try {
    const user = await getAuthenticatedUser(request);

    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const canAccessDashboard =
      userHasBaseRole(user, ["admin", "faculty"]) ||
      userHasAnyRole(user, ["advisor", "HoD", "placement_coordinator"]);

    if (!canAccessDashboard) {
      return NextResponse.json({ error: "Forbidden" }, { status: 403 });
    }

    const data = await getDashboardStats();
    return NextResponse.json(data);
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unable to load dashboard data.";

    return NextResponse.json(
      { error: message },
      {
        status: message.includes("DATABASE_URL") ? 503 : 500,
      },
    );
  }
}
