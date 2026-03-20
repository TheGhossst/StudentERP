"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";

interface HeaderProps {
    name: string;
    role: string;
    unreadCount?: number;
}

export default function Header({ name, role, unreadCount = 0 }: HeaderProps) {
    const router = useRouter();
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [isLoggingOut, setIsLoggingOut] = useState(false);
    const menuRef = useRef<HTMLDivElement>(null);

    const initials = name
        ? name.split(" ").map((n) => n[0]).join("").substring(0, 2).toUpperCase()
        : "U";

    useEffect(() => {
        function handleOutsideClick(event: MouseEvent) {
            if (!menuRef.current) return;
            if (!menuRef.current.contains(event.target as Node)) {
                setIsMenuOpen(false);
            }
        }
        document.addEventListener("mousedown", handleOutsideClick);
        return () => document.removeEventListener("mousedown", handleOutsideClick);
    }, []);

    async function handleLogout() {
        setIsLoggingOut(true);
        try {
            await fetch("/api/auth/logout", { method: "POST" });
        } finally {
            router.replace("/");
            router.refresh();
            setIsLoggingOut(false);
        }
    }

    function handleSettings() {
        setIsMenuOpen(false);
        router.push("/dashboard/settings");
    }

    return (
        <header className="sticky top-0 z-30 flex w-full items-center justify-between  rounded-lg border-slate-200  px-6 pb-4 backdrop-blur-md transition-all">
            <div className="flex items-center gap-2">
                <h1 className="text-lg font-bold tracking-tight text-slate-50 hidden sm:block">Dashboard</h1>
            </div>

            <div className="flex items-center gap-4 sm:gap-6">
                
                <button className="relative text-slate-100 transition-colors hover:text-slate-400 focus:outline-none" aria-label="Notifications">
                    {unreadCount > 0 ? (
                        <span className="absolute -right-2 -top-2 inline-flex min-h-5 min-w-5 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-semibold leading-none text-white ring-2 ring-slate-900">
                            {unreadCount > 99 ? "99+" : unreadCount}
                        </span>
                    ) : null}
                    <svg className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="1.5">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0" />
                    </svg>
                </button>

                <div className="h-8 w-px bg-slate-200"></div>

                <div className="relative" ref={menuRef}>
                    <button
                        type="button"
                        onClick={() => setIsMenuOpen((prev) => !prev)}
                        className="flex items-center gap-3 focus:outline-none"
                        aria-expanded={isMenuOpen}
                    >
                        <div className="hidden text-right sm:block">
                            <p className="text-sm font-semibold text-slate-100 leading-none">{name}</p>
                            <p className="mt-1 text-xs font-medium uppercase tracking-wider text-slate-50">{role}</p>
                        </div>
                        
                        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-linear-to-tr from-indigo-500 to-purple-500 text-sm font-bold text-white shadow-md ring-2 ring-white transition-transform hover:scale-105">
                            {initials}
                        </div>

                        <svg className={`h-4 w-4 text-slate-400 transition-transform duration-200 ${isMenuOpen ? "rotate-180" : ""}`} fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
                        </svg>
                    </button>
                    <div
                        className={`absolute right-0 mt-3 w-56 origin-top-right rounded-xl border border-slate-100 bg-black/40 p-1.5 shadow-lg ring-1 ring-black ring-opacity-5 transition-all duration-200 ease-out ${
                            isMenuOpen ? "scale-100 opacity-100 visible" : "scale-95 opacity-0 invisible"
                        }`}
                    >
                        <div className="mb-1 block border-b border-slate-100 px-3 pb-3 pt-2 sm:hidden">
                            <p className="text-sm font-semibold text-slate-100">{name}</p>
                            <p className="text-xs font-medium text-slate-500">{role}</p>
                        </div>

                        <button
                            type="button"
                            onClick={handleSettings}
                            className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-slate-100 transition-colors hover:bg-slate-50 hover:text-indigo-600"
                        >
                            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                                <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                            </svg>
                            Settings
                        </button>
                        
                        <button
                            type="button"
                            onClick={handleLogout}
                            disabled={isLoggingOut}
                            className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-rose-600 transition-colors hover:bg-rose-50 disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth="2">
                                <path strokeLinecap="round" strokeLinejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                            </svg>
                            {isLoggingOut ? "Logging out..." : "Logout"}
                        </button>
                    </div>
                </div>
            </div>
        </header>
    );
}