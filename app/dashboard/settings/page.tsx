"use client";

import { useRouter } from "next/navigation";

export default function SettingsPage() {
  const router = useRouter();

  return (
    <main className="min-h-dvh bg-slate-50 p-6 text-slate-900">
      <div className="mx-auto max-w-3xl space-y-4 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-bold text-slate-900">Settings</h1>
        <p className="text-sm text-slate-600">
          Settings screen is ready. Add account and preferences controls here.
        </p>

        <button
          type="button"
          onClick={() => router.push("/dashboard")}
          className="inline-flex rounded-md bg-slate-900 px-4 py-2 text-sm font-medium text-white transition hover:bg-slate-700"
        >
          Back to Dashboard
        </button>
      </div>
    </main>
  );
}
