"use client";

import { FormEvent, useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { gsap } from "gsap";
import { BrandHeader } from "./components/login/BrandHeader";
import { LoginFooter } from "./components/login/LoginFooter";
import { LoginForm } from "./components/login/LoginForm";
import { LoginApiResponse } from "./components/login/types";

export default function Home() {
  const router = useRouter();
  const [email, setEmail] = useState("admin.erp@nitgoa.ac.in");
  const [password, setPassword] = useState("NitGoa@123");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);

  const containerRef = useRef<HTMLElement>(null);
  const formRef = useRef<HTMLFormElement>(null);
  const elementsRef = useRef<(HTMLElement | null)[]>([]);

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.fromTo(
        containerRef.current,
        { opacity: 0, y: 30 },
        { opacity: 1, y: 0, duration: 0.8, ease: "power3.out" },
      );

      gsap.fromTo(
        elementsRef.current,
        { opacity: 0, y: 15 },
        {
          opacity: 1,
          y: 0,
          duration: 0.5,
          stagger: 0.1,
          ease: "power2.out",
          delay: 0.2,
        },
      );
    });

    return () => ctx.revert();
  }, []);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);
    setErrorMessage(null);

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });

      const payload = (await response.json()) as LoginApiResponse;

      if (!response.ok) {
        setErrorMessage(payload.error ?? "Authentication failed.");
        gsap.fromTo(
          formRef.current,
          { x: -8 },
          {
            x: 8,
            duration: 0.05,
            yoyo: true,
            repeat: 5,
            onComplete: () => {
              gsap.set(formRef.current, { x: 0 });
            },
          },
        );
        return;
      }

      if (!payload.user) {
        setErrorMessage("Authentication did not return a valid session.");
        return;
      }

      router.push("/dashboard");
    } catch {
      setErrorMessage("System unreachable. Please verify network routing.");
      gsap.fromTo(
        formRef.current,
        { x: -8 },
        {
          x: 8,
          duration: 0.05,
          yoyo: true,
          repeat: 5,
          onComplete: () => {
            gsap.set(formRef.current, { x: 0 });
          },
        },
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="relative flex min-h-dvh w-full flex-col items-center justify-center text-[#F4F4F5] px-6 bg-[#1E293B] font-sans antialiased overflow-hidden">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(212, 213, 215, 0.07),transparent_45%),radial-gradient(circle_at_85%_15%,rgba(229, 221, 221, 0.06),transparent_42%),linear-gradient(145deg,#363839_0%,#EEF2F7_100%)]"></div>
      <div className="pointer-events-none absolute -left-24 top-16 h-72 w-72 rounded-full bg-[#d9d9de]/10 blur-3xl animate-[floatSoft_16s_ease-in-out_infinite]"></div>
      <div className="pointer-events-none absolute -right-24 bottom-12 h-80 w-80 rounded-full bg-[#D94838]/10 blur-3xl animate-[floatSoft_20s_ease-in-out_infinite_reverse]"></div>
      <div className="pointer-events-none absolute inset-0 opacity-[0.035] bg-[linear-gradient(to_right,#dbdcde_1px,transparent_1px),linear-gradient(to_bottom,#d6d7d9_1px,transparent_1px)] bg-size-[44px_44px]"></div>
      <div className="pointer-events-none absolute inset-0 mix-blend-overlay opacity-20 bg-[url('https://grainy-gradients.vercel.app/noise.svg')]"></div>

      <section
        ref={containerRef}
        className="relative z-10 w-full max-w-sm sm:max-w-md rounded-sm bg-white/90 p-10 shadow-2xl shadow-[#0A1128]/5 border border-black/5"
      >
        <BrandHeader
          onRegisterElement={(element) => {
            elementsRef.current[0] = element;
          }}
        />

        <LoginForm
          email={email}
          password={password}
          isSubmitting={isSubmitting}
          showPassword={showPassword}
          errorMessage={errorMessage}
          formRef={formRef}
          onSubmit={handleSubmit}
          onEmailChange={(event) => setEmail(event.target.value)}
          onPasswordChange={(event) => setPassword(event.target.value)}
          onTogglePassword={() => setShowPassword((prev) => !prev)}
          onRegisterEmailField={(element) => {
            elementsRef.current[1] = element;
          }}
          onRegisterPasswordField={(element) => {
            elementsRef.current[2] = element;
          }}
          onRegisterSubmitButton={(element) => {
            elementsRef.current[3] = element;
          }}
        />

        <LoginFooter
          onRegisterElement={(element) => {
            elementsRef.current[4] = element;
          }}
        />
      </section>

      <style
        dangerouslySetInnerHTML={{
          __html: `
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500;600&family=Space+Grotesk:wght@500;600;700&display=swap');

        @keyframes floatSoft {
          0%, 100% { transform: translate3d(0, 0, 0) scale(1); }
          50% { transform: translate3d(0, -14px, 0) scale(1.03); }
        }
        
        @keyframes shimmer {
          100% { transform: translateX(100%); }
        }
      `,
        }}
      />
    </main>
  );
}
