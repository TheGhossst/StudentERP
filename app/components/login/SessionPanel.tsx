'use client'

import { AuthUser } from "./types";

interface SessionPanelProps {
  user: AuthUser;
}

export function SessionPanel({ user }: SessionPanelProps) {
  return (
    <div className="p-4 bg-[#F4F4F5] border-l-4 border-[#0A1128] rounded-r-md">
      <p className="text-sm font-semibold text-[#0A1128] mb-2">
        Secure Session Established
      </p>
      <pre className="text-[10px] bg-[#0A1128] text-[#F4F4F5] p-3 rounded overflow-x-auto font-mono">
        {JSON.stringify(user, null, 2)}
      </pre>
    </div>
  );
}
