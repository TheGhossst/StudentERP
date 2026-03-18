'use client'

interface BrandHeaderProps {
  onRegisterElement: (element: HTMLDivElement | null) => void;
};

export function BrandHeader({ onRegisterElement }: BrandHeaderProps) {
  return (
    <div
      className="mb-8 text-center flex flex-col items-center gap-1"
      ref={onRegisterElement}
    >
      <div className="h-10 w-10 bg-[#0A1128] rounded flex items-center justify-center mb-2">
        <span
          className="text-[#F4F4F5] font-bold text-xl tracking-tighter"
          style={{ fontFamily: '"Space Grotesk", sans-serif' }}
        >
          N
        </span>
      </div>
      <h1
        className="text-2xl font-semibold tracking-tight text-[#0A1128]"
        style={{ fontFamily: '"Space Grotesk", sans-serif' }}
      >
        NIT GOA
      </h1>
      <p className="text-xs uppercase tracking-widest text-[#1E293B]/70">
        Enterprise Resource Planning
      </p>
    </div>
  );
}
