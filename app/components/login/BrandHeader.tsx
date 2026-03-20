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
      <h1
        className="text-2xl font-semibold tracking-tight text-[#0A1128]"
        style={{ fontFamily: '"Space Grotesk", sans-serif' }}
      >
        NIT GOA Login
      </h1>
    </div>
  );
}
