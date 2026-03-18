'use client'

import { HelpCircle, KeyRound } from "lucide-react";

interface LoginFooterProps {
  onRegisterElement: (element: HTMLDivElement | null) => void;
}

export function LoginFooter({ onRegisterElement }: LoginFooterProps) {
  return (
    <div
      className="mt-8 flex items-center justify-between border-t border-[#1E293B]/10 pt-6 text-[10px] font-mono text-[#1E293B]/60 uppercase tracking-wide"
      ref={onRegisterElement}
    >
      <button className="flex items-center gap-1.5 hover:text-[#0A1128] transition-colors">
        <KeyRound className="h-3 w-3" /> Recovery
      </button>
      <div className="flex items-center gap-4">
        <button className="flex items-center gap-1.5 hover:text-[#0A1128] transition-colors">
          <HelpCircle className="h-3 w-3" /> Helpdesk
        </button>
        <span className="flex items-center gap-1.5 text-emerald-600 font-semibold">
          <span className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
          </span>
          System Online
        </span>
      </div>
    </div>
  );
}
