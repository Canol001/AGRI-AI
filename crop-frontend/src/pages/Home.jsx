import { Leaf, Camera, ShieldCheck, BarChart3, Download, ChevronRight, Star, Users, Award, HelpCircle } from 'lucide-react';

export default function Home() {
  return (
    <div className="min-h-screen bg-[radial-gradient(circle_at_30%_70%,rgba(16,185,129,0.12),transparent_50%)] font-sans antialiased">
      {/* Navbar - Glassmorphism + subtle shadow */}
      <nav className="sticky top-0 z-50 bg-white/70 backdrop-blur-xl border-b border-green-100/50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16 md:h-20">
            <div className="flex items-center gap-3">
              <div className="bg-gradient-to-br from-green-600 to-emerald-600 p-2 rounded-xl shadow-md">
                <Leaf className="h-7 w-7 text-white" />
              </div>
              <span className="text-2xl md:text-3xl font-extrabold bg-gradient-to-r from-green-700 to-emerald-700 bg-clip-text text-transparent">
                CropGuard
              </span>
            </div>

            <div className="hidden md:flex items-center gap-8">
              <a href="#features" className="text-green-800 hover:text-emerald-700 font-medium transition">Features</a>
              <a href="#how" className="text-green-800 hover:text-emerald-700 font-medium transition">How it Works</a>
              <a href="#impact" className="text-green-800 hover:text-emerald-700 font-medium transition">Impact</a>
              <a href="#faq" className="text-green-800 hover:text-emerald-700 font-medium transition">FAQ</a>
            </div>

            <a
              href="#download"
              className="md:hidden bg-emerald-600 text-white px-5 py-2.5 rounded-full font-semibold shadow-md hover:bg-emerald-700 transition text-sm"
            >
              Download
            </a>
          </div>
        </div>
      </nav>

      {/* Hero - Asymmetric, mobile-first, strong CTA */}
      <section className="relative pt-16 pb-24 md:pt-28 md:pb-40 overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_70%,rgba(16,185,129,0.12),transparent_50%)]" />
        
        <div className="max-w-7xl mx-auto px-5 sm:px-8 lg:px-10">
          <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
            <div>
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold leading-tight text-green-900 tracking-tight">
                Catch Crop Diseases <span className="text-emerald-600">Before</span> They Spread
              </h1>
              <p className="mt-6 text-xl text-gray-700 leading-relaxed max-w-xl">
                Snap a photo of your plants — our AI gives you instant diagnosis, severity level, and practical treatment steps. Save your harvest, reduce losses.
              </p>

              <div className="mt-10 flex flex-col sm:flex-row gap-4">
                <a
                  href="/app-release.apk"
                  className="inline-flex items-center justify-center gap-2 bg-gradient-to-r from-emerald-600 to-green-600 text-white px-8 py-4 rounded-xl font-semibold text-lg shadow-lg hover:shadow-xl hover:scale-[1.02] transition duration-300"
                >
                  <Download className="h-5 w-5" />
                  Download Free
                </a>
                <a
                  href="#how"
                  className="inline-flex items-center justify-center gap-2 bg-white/80 backdrop-blur-sm border border-emerald-200 text-emerald-800 px-8 py-4 rounded-xl font-semibold hover:bg-white transition"
                >
                  See how it works <ChevronRight className="h-5 w-5" />
                </a>
              </div>

              <div className="mt-8 flex items-center gap-6 text-sm text-gray-600">
                <div className="flex -space-x-2">
                  <img src="https://randomuser.me/api/portraits/women/44.jpg" alt="" className="w-10 h-10 rounded-full border-2 border-white shadow" />
                  <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="" className="w-10 h-10 rounded-full border-2 border-white shadow" />
                  <img src="https://randomuser.me/api/portraits/women/68.jpg" alt="" className="w-10 h-10 rounded-full border-2 border-white shadow" />
                </div>
                <span>Joined by <strong className="text-green-700">12,000+</strong> farmers</span>
              </div>
            </div>

            <div className="relative mt-12 lg:mt-0">
              <div className="relative z-10 rounded-3xl overflow-hidden shadow-2xl border border-emerald-100/50 bg-white/30 backdrop-blur-sm">
                <img
                  src="https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&q=80&w=1200"
                  alt="Farmer using CropGuard app in field"
                  className="w-full h-auto object-cover"
                />
              </div>
              {/* Floating badge */}
              <div className="absolute -bottom-6 -right-6 md:-bottom-10 md:-right-10 bg-white rounded-2xl p-5 shadow-xl border border-emerald-100">
                <div className="text-center">
                  <div className="text-3xl font-bold text-emerald-600">98%</div>
                  <div className="text-sm text-gray-600 mt-1">Accuracy</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-20 md:py-28 bg-white/60 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-5 sm:px-8 lg:px-10">
          <h2 className="text-4xl md:text-5xl font-bold text-center text-green-900 mb-16">
            Simple. Powerful. Built for Farmers.
          </h2>

          <div className="grid md:grid-cols-3 gap-8 lg:gap-12">
            {[
              { icon: Camera, title: "Snap & Scan", desc: "Take a photo — AI analyzes leaf patterns in seconds." },
              { icon: BarChart3, title: "Precise Results", desc: "Detects 100+ diseases with severity score and confidence level." },
              { icon: ShieldCheck, title: "Actionable Advice", desc: "Organic & chemical treatment options + prevention tips." },
            ].map((item, i) => (
              <div
                key={i}
                className="group bg-white rounded-2xl p-8 shadow-md hover:shadow-xl border border-emerald-50 hover:border-emerald-200 transition duration-300"
              >
                <div className="w-16 h-16 rounded-xl bg-emerald-100 flex items-center justify-center mb-6 group-hover:bg-emerald-200 transition">
                  <item.icon className="h-8 w-8 text-emerald-600" />
                </div>
                <h3 className="text-2xl font-semibold text-green-800 mb-3">{item.title}</h3>
                <p className="text-gray-600 leading-relaxed">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section id="how" className="py-20 md:py-28 bg-gradient-to-b from-white to-emerald-50">
        <div className="max-w-6xl mx-auto px-5 sm:px-8 lg:px-10">
          <h2 className="text-4xl md:text-5xl font-bold text-center text-green-900 mb-16">Just 3 Steps</h2>

          <div className="grid md:grid-cols-3 gap-12 md:gap-16">
            {[
              { num: "1", title: "Take Photo", desc: "Use your phone camera — no special equipment needed." },
              { num: "2", title: "Upload", desc: "Send image to CropGuard — works offline too (queued sync)." },
              { num: "3", title: "Get Help", desc: "Instant result + treatment plan in your language." },
            ].map((step, i) => (
              <div key={i} className="relative">
                <div className="absolute -top-6 left-1/2 -translate-x-1/2 w-14 h-14 rounded-full bg-emerald-600 text-white flex items-center justify-center text-2xl font-bold shadow-lg">
                  {step.num}
                </div>
                <div className="pt-12 bg-white rounded-2xl p-8 shadow-md border border-emerald-50 text-center">
                  <h3 className="text-2xl font-semibold text-green-800 mb-4">{step.title}</h3>
                  <p className="text-gray-600">{step.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Impact / Stats */}
      <section id="impact" className="py-20 md:py-28 bg-emerald-800 text-white">
        <div className="max-w-7xl mx-auto px-5 sm:px-8 lg:px-10">
          <h2 className="text-4xl md:text-5xl font-bold text-center mb-16">Real Impact in the Field</h2>

          <div className="grid md:grid-cols-3 gap-12 text-center">
            <div>
              <div className="text-5xl md:text-6xl font-extrabold mb-4">42%</div>
              <p className="text-xl text-emerald-100">Average yield loss prevented</p>
            </div>
            <div>
              <div className="text-5xl md:text-6xl font-extrabold mb-4">190k+</div>
              <p className="text-xl text-emerald-100">Photos analyzed monthly</p>
            </div>
            <div>
              <div className="text-5xl md:text-6xl font-extrabold mb-4">4.9</div>
              <p className="text-xl text-emerald-100">App Store rating</p>
            </div>
          </div>
        </div>
      </section>

      {/* Download CTA */}
      <section id="download" className="py-24 md:py-32 bg-gradient-to-br from-emerald-600 to-green-700 text-white text-center">
        <div className="max-w-5xl mx-auto px-5">
          <h2 className="text-4xl md:text-6xl font-extrabold mb-8">Protect Your Harvest Today</h2>
          <p className="text-xl md:text-2xl mb-12 max-w-3xl mx-auto opacity-90">
            Download CropGuard now — free, no ads, no subscription. Available on iOS & Android.
          </p>

          <div className="flex flex-col sm:flex-row justify-center gap-6">
            <a href="https://apps.apple.com/" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-3 bg-black text-white px-8 py-5 rounded-2xl font-semibold shadow-2xl hover:scale-105 transition">
              <svg className="h-10 w-10" viewBox="0 0 24 24" fill="currentColor"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.35.03-1.78-.79-3.29-.79-1.51 0-1.99.77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.06 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.19 2.76zM13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/></svg>
              App Store
            </a>
            <a href="https://play.google.com/" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-3 bg-black text-white px-8 py-5 rounded-2xl font-semibold shadow-2xl hover:scale-105 transition">
              <svg className="h-10 w-10" viewBox="0 0 24 24" fill="currentColor"><path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.5,12.92 20.16,13.19L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/></svg>
              Google Play
            </a>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section id="faq" className="py-20 md:py-28 bg-white">
        <div className="max-w-4xl mx-auto px-5">
          <h2 className="text-4xl md:text-5xl font-bold text-center text-green-900 mb-16">Common Questions</h2>

          <div className="space-y-8">
            {[
              { q: "Is CropGuard really free?", a: "Yes — core detection is 100% free. No hidden fees or subscriptions." },
              { q: "Does it work offline?", a: "Basic models work offline after first download. Full accuracy needs internet." },
              { q: "Which crops are supported?", a: "Maize, rice, tomatoes, potatoes, beans, cassava, wheat, and 20+ more — expanding monthly." },
              { q: "How accurate is the AI?", a: "Up to 98% on common diseases (tested on 500k+ images). Always verify critical cases." },
            ].map((item, i) => (
              <div key={i} className="bg-emerald-50 rounded-2xl p-6 md:p-8">
                <h3 className="text-xl md:text-2xl font-semibold text-green-800 flex items-start gap-4">
                  <HelpCircle className="h-7 w-7 text-emerald-600 flex-shrink-0 mt-1" />
                  {item.q}
                </h3>
                <p className="mt-4 text-gray-700 leading-relaxed">{item.a}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gradient-to-b from-emerald-900 to-green-950 text-emerald-100 py-12">
        <div className="max-w-7xl mx-auto px-5 text-center">
          <div className="flex justify-center mb-6">
            <div className="bg-emerald-700 p-3 rounded-xl">
              <Leaf className="h-8 w-8 text-white" />
            </div>
          </div>
          <p className="text-lg">CropGuard © {new Date().getFullYear()}. Helping farmers grow healthier crops.</p>
          <div className="mt-6 flex justify-center gap-8 text-sm">
            <a href="/privacy" className="hover:text-white transition">Privacy</a>
            <a href="/terms" className="hover:text-white transition">Terms</a>
            <a href="/contact" className="hover:text-white transition">Contact</a>
          </div>
        </div>
      </footer>
    </div>
  );
}