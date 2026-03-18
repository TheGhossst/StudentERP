"use client";

import { FormEvent, useState } from "react";

type AuthUser = {
  id: string;
  email: string;
  baseRole: "student" | "faculty" | "admin";
  status: "active" | "suspended" | "deleted";
  roles: Array<{
    name: string;
    scopeType: "class" | "department" | "year" | null;
    scopeId: string | null;
  }>;
};

type LoginApiResponse = {
  message?: string;
  error?: string;
  user?: AuthUser;
};

export default function Home() {
  const [email, setEmail] = useState("admin.erp@nitgoa.ac.in");
  const [password, setPassword] = useState("NitGoa@123");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [user, setUser] = useState<AuthUser | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);
    setErrorMessage(null);
    setUser(null);

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      });

      const payload = (await response.json()) as LoginApiResponse;

      if (!response.ok) {
        setErrorMessage(payload.error ?? "Login failed.");
        return;
      }

      if (!payload.user) {
        setErrorMessage("Login did not return a user payload.");
        return;
      }

      setUser(payload.user);
    } catch {
      setErrorMessage("Request failed. Please check if the server is running.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl px-6 py-12">
      <section className="rounded-xl border border-black/10 bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-bold text-zinc-900">Student ERP Login</h1>
        <p className="mt-2 text-sm text-zinc-600">
          On successful login, authenticated user details are shown below as JSON.
        </p>

        <form className="mt-6 space-y-4" onSubmit={handleSubmit}>
          <div>
            <label className="mb-1 block text-sm font-medium text-zinc-700" htmlFor="email">
              Email
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              className="w-full rounded-md border border-zinc-300 px-3 py-2 text-zinc-900 outline-none focus:border-zinc-500"
              required
            />
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-zinc-700" htmlFor="password">
              Password
            </label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="w-full rounded-md border border-zinc-300 px-3 py-2 text-zinc-900 outline-none focus:border-zinc-500"
              required
            />
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="inline-flex rounded-md bg-zinc-900 px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:opacity-60"
          >
            {isSubmitting ? "Logging in..." : "Login"}
          </button>
        </form>
      </section>

      {errorMessage ? (
        <section className="mt-6 rounded-xl border border-red-300 bg-red-50 p-4 text-red-800">
          <p className="font-semibold">Login failed</p>
          <p className="mt-1 text-sm">{errorMessage}</p>
        </section>
      ) : null}

      {user ? (
        <section className="mt-6 rounded-xl border border-emerald-300 bg-emerald-50 p-4">
          <p className="font-semibold text-emerald-900">Login successful</p>
          <pre className="mt-3 overflow-auto rounded-md bg-zinc-900 p-4 text-xs text-zinc-100">
            {JSON.stringify(user, null, 2)}
          </pre>
        </section>
      ) : null}
    </main>
  );
}
