import { HeroSection } from '@/components/sections/HeroSection';
import { UrlInputSection } from '@/components/sections/UrlInputSection';
import { TrustStatementsSection } from '@/components/sections/TrustStatementsSection';

export function Landing() {
  return (
    <main className="min-h-[calc(100vh-80px)] flex items-center justify-center">
      <div className="max-w-6xl mx-auto px-6 lg:px-8 py-16 lg:py-24 space-y-12 w-full">
        <HeroSection />
        <UrlInputSection />
        <TrustStatementsSection />
      </div>
    </main>
  );
}
