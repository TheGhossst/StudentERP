"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";

import { AuthUser } from "../components/login/types";
import { Loading } from "./components/Loading";
import Error from "./components/Error";
import Header from "./components/Header";

interface MeApiResponse {
  error?: string;
  user?: AuthUser;
}

export default function Dashboard() {
  const router = useRouter();
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function loadSession() {
      try {
        const response = await fetch("/api/auth/me", {
          method: "GET",
          cache: "no-store",
        });

        const payload = (await response.json()) as MeApiResponse;

        if (!isMounted) {
          return;
        }

        if (!response.ok || !payload.user) {
          if (response.status === 401) {
            router.replace("/");
            return;
          }

          setErrorMessage(
            payload.error ?? "Unable to load authenticated user.",
          );
          return;
        }

        setUser(payload.user);
      } catch {
        if (isMounted) {
          setErrorMessage("Unable to reach authentication service.");
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    void loadSession();

    return () => {
      isMounted = false;
    };
  }, [router]);

  if (isLoading) {
    return <Loading />;
  }

  if (errorMessage) {
    return <Error />;
  }

  return (
    <main className="min-h-dvh text-slate-50 p-6 bg-slate-900">
      <div className="mx-auto max-w-full space-y-6">
        {user ? <Header name={user.email.split("@")[0]} role={user.baseRole} /> : null}

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
            Auth Info
          </h2>
          <pre className="mt-4 overflow-x-auto rounded-lg bg-slate-900 p-4 text-xs text-slate-100">
            {JSON.stringify(user, null, 2)}
          </pre>
        </section>
      </div>
    </main>
  );
}
