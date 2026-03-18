'use client'

import { ChangeEventHandler, FormEventHandler, RefObject } from "react";
import { Eye, EyeOff, Loader2 } from "lucide-react";

interface LoginFormProps {
  email: string;
  password: string;
  isSubmitting: boolean;
  showPassword: boolean;
  errorMessage: string | null;
  formRef: RefObject<HTMLFormElement | null>;
  onSubmit: FormEventHandler<HTMLFormElement>;
  onEmailChange: ChangeEventHandler<HTMLInputElement>;
  onPasswordChange: ChangeEventHandler<HTMLInputElement>;
  onTogglePassword: () => void;
  onRegisterEmailField: (element: HTMLDivElement | null) => void;
  onRegisterPasswordField: (element: HTMLDivElement | null) => void;
  onRegisterSubmitButton: (element: HTMLButtonElement | null) => void;
}

export function LoginForm({
  email,
  password,
  isSubmitting,
  showPassword,
  errorMessage,
  formRef,
  onSubmit,
  onEmailChange,
  onPasswordChange,
  onTogglePassword,
  onRegisterEmailField,
  onRegisterPasswordField,
  onRegisterSubmitButton,
}: LoginFormProps) {
  return (
    <form ref={formRef} className="space-y-6" onSubmit={onSubmit}>
      <div className="relative group" ref={onRegisterEmailField}>
        <input
          id="email"
          type="text"
          value={email}
          onChange={onEmailChange}
          disabled={isSubmitting}
          className="peer w-full border-b-[1.5px] border-[#1E293B]/20 bg-transparent px-0 py-3 text-sm text-[#0A1128] font-mono outline-none transition-colors focus:border-[#D94838] disabled:opacity-50"
          placeholder=" "
          required
        />
        <label
          htmlFor="email"
          className="pointer-events-none absolute left-0 top-3 origin-left -translate-y-6 scale-75 text-xs text-[#1E293B]/60 transition-transform peer-placeholder-shown:translate-y-0 peer-placeholder-shown:scale-100 peer-focus:-translate-y-6 peer-focus:scale-75 peer-focus:text-[#D94838]"
        >
          Roll Number / Institute ID
        </label>
      </div>

      <div className="relative group" ref={onRegisterPasswordField}>
        <input
          id="password"
          type={showPassword ? "text" : "password"}
          value={password}
          onChange={onPasswordChange}
          disabled={isSubmitting}
          className="peer w-full border-b-[1.5px] border-[#1E293B]/20 bg-transparent pr-8 pl-0 py-3 text-sm text-[#0A1128] font-mono outline-none transition-colors focus:border-[#D94838] disabled:opacity-50"
          placeholder=" "
          required
        />
        <label
          htmlFor="password"
          className="pointer-events-none absolute left-0 top-3 origin-left -translate-y-6 scale-75 text-xs text-[#1E293B]/60 transition-transform peer-placeholder-shown:translate-y-0 peer-placeholder-shown:scale-100 peer-focus:-translate-y-6 peer-focus:scale-75 peer-focus:text-[#D94838]"
        >
          Secure Passphrase
        </label>
        <button
          type="button"
          tabIndex={-1}
          onClick={onTogglePassword}
          className="absolute right-0 top-3 text-[#1E293B]/60 hover:text-[#0A1128] transition-colors focus:outline-none"
          aria-label={showPassword ? "Hide password" : "Show password"}
        >
          {showPassword ? (
            <EyeOff className="h-4 w-4" />
          ) : (
            <Eye className="h-4 w-4" />
          )}
        </button>
      </div>

      {errorMessage ? (
        <p className="text-xs text-[#D94838] font-mono bg-[#D94838]/10 p-2 border-l-2 border-[#D94838]">
          {errorMessage}
        </p>
      ) : null}

      <button
        ref={onRegisterSubmitButton}
        type="submit"
        disabled={isSubmitting}
        className="relative w-full overflow-hidden bg-[#0A1128] py-3.5 text-xs font-semibold uppercase tracking-wider text-white transition-all hover:bg-[#0A1128]/90 hover:shadow-lg hover:shadow-[#0A1128]/20 focus:outline-none focus:ring-2 focus:ring-[#D94838] focus:ring-offset-2 active:scale-[0.98] disabled:pointer-events-none disabled:opacity-70 group"
      >
        <div className="absolute inset-0 -translate-x-full bg-linear-to-r from-transparent via-white/10 to-transparent group-hover:animate-[shimmer_1.5s_infinite]"></div>
        {isSubmitting ? (
          <span className="flex items-center justify-center gap-2">
            <Loader2 className="h-4 w-4 animate-spin" />
            Authenticating...
          </span>
        ) : (
          "Authenticate Session"
        )}
      </button>
    </form>
  );
}
