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

interface DashboardNotification {
  id: string;
  title: string;
  message: string;
  createdAt: string;
  isRead: boolean;
  readAt: string | null;
  deliveries: {
    channel: "push" | "email" | "sms";
    status: "pending" | "delivered" | "failed";
    deliveredAt: string | null;
  }[];
}

interface NotificationsApiResponse {
  error?: string;
  notifications?: DashboardNotification[];
}

function formatTimestamp(value: string) {
  return new Date(value).toLocaleString();
}

export default function Dashboard() {
  const router = useRouter();
  const [user, setUser] = useState<AuthUser | null>(null);
  const [notifications, setNotifications] = useState<DashboardNotification[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [notificationsError, setNotificationsError] = useState<string | null>(null);

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

        const notificationsResponse = await fetch("/api/dashboard/notifications", {
          method: "GET",
          cache: "no-store",
        });

        const notificationsPayload =
          (await notificationsResponse.json()) as NotificationsApiResponse;

        if (!isMounted) {
          return;
        }

        if (!notificationsResponse.ok) {
          if (notificationsResponse.status === 401) {
            router.replace("/");
            return;
          }

          setNotificationsError(
            notificationsPayload.error ?? "Unable to load notifications.",
          );
          return;
        }

        setNotifications(notificationsPayload.notifications ?? []);
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

  const unreadCount = notifications.filter((notification) => !notification.isRead).length;

  return (
    <main className="min-h-dvh text-slate-50 p-6 bg-slate-900">
      <div className="mx-auto max-w-full space-y-6">
        {user ? (
          <Header
            name={user.email.split("@")[0]}
            role={user.baseRole}
            unreadCount={unreadCount}
          />
        ) : null}

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
            Auth Info
          </h2>
          <pre className="mt-4 overflow-x-auto rounded-lg bg-slate-900 p-4 text-xs text-slate-100">
            {JSON.stringify(user, null, 2)}
          </pre>
        </section>

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm text-slate-900">
          <div className="flex items-center justify-between gap-2">
            <h2 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
              Notifications
            </h2>
            <span className="rounded-full bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-700">
              {unreadCount} unread
            </span>
          </div>

          {notificationsError ? (
            <p className="mt-4 text-sm text-rose-600">{notificationsError}</p>
          ) : null}

          {!notificationsError && notifications.length === 0 ? (
            <p className="mt-4 text-sm text-slate-600">No notifications available.</p>
          ) : null}

          {notifications.length > 0 ? (
            <ul className="mt-4 space-y-3">
              {notifications.map((notification) => (
                <li
                  key={notification.id}
                  className={`rounded-lg border p-4 ${
                    notification.isRead
                      ? "border-slate-200 bg-slate-50"
                      : "border-indigo-200 bg-indigo-50"
                  }`}
                >
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <p className="text-sm font-semibold text-slate-900">
                        {notification.title}
                      </p>
                      <p className="mt-1 text-sm text-slate-700">{notification.message}</p>
                    </div>
                    <span className="shrink-0 text-xs text-slate-500">
                      {formatTimestamp(notification.createdAt)}
                    </span>
                  </div>

                  <div className="mt-3 flex flex-wrap items-center gap-2 text-xs">
                    <span
                      className={`rounded-full px-2 py-0.5 font-medium ${
                        notification.isRead
                          ? "bg-emerald-100 text-emerald-700"
                          : "bg-amber-100 text-amber-700"
                      }`}
                    >
                      {notification.isRead ? "Read" : "Unread"}
                    </span>

                    {notification.deliveries.map((delivery) => (
                      <span
                        key={`${notification.id}-${delivery.channel}`}
                        className="rounded-full bg-slate-200 px-2 py-0.5 font-medium text-slate-700"
                      >
                        {delivery.channel}: {delivery.status}
                      </span>
                    ))}
                  </div>
                </li>
              ))}
            </ul>
          ) : null}
        </section>
      </div>
    </main>
  );
}
