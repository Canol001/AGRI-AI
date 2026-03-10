import { Leaf, Camera, ShieldCheck, BarChart3, Download, ChevronRight, HelpCircle } from 'lucide-react';

export default function Home() {
  // You can also fetch this dynamically later if needed
  const apkDownloadUrl = "/app-release.apk"; // assuming it's in /public/app-release.apk
  const apkFileName = "app-release.apk";
  const version = "1.0.0"; // change this when you update the app

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50 font-sans antialiased">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 bg-white/70 backdrop-blur-xl border-b border-green-100/50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16 md:h-20">
            <div className="flex items-center gap-3">
              <div className="bg-gradient-to-br from-green-600 to-emerald-600 p-2 rounded-xl shadow-md">
                <Leaf className="h-7 w-7 text-white" />
              </div>
              <span className="text-2xl md:text-3xl font-extrabold bg-gradient-to-r from-green-700 to-emerald-700 bg-clip-text text-transparent">
                Agri AI
              </span>
            </div>

            <div className="hidden md:flex items-center gap-8">
              <a href="#features" className="text-green-800 hover:text-emerald-700 font-medium transition">Features</a>
              <a href="#how" className="text-green-800 hover:text-emerald-700 font-medium transition">How It Works</a>
              <a href="#impact" className="text-green-800 hover:text-emerald-700 font-medium transition">Impact</a>
              <a href="#faq" className="text-green-800 hover:text-emerald-700 font-medium transition">FAQ</a>
            </div>

            <a
              href={apkDownloadUrl}
              download={apkFileName}
              className="hidden md:inline-flex items-center gap-2 bg-emerald-600 text-white px-6 py-2.5 rounded-full font-semibold shadow-md hover:bg-emerald-700 transition text-sm"
            >
              <Download className="h-4 w-4" />
              Download APK
            </a>
          </div>
        </div>
      </nav>

      {/* Hero */}
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
                  href={apkDownloadUrl}
                  className="inline-flex items-center justify-center gap-2 bg-gradient-to-r from-emerald-600 to-green-600 text-white backdrop-blur-sm border border-emerald-200 text-emerald-800 px-8 py-4 rounded-xl font-semibold hover:bg-white transition"
                >
                  <Download className="h-5 w-5" />
                  Download APK v{version}
                </a>
                <a
                  href="#how"
                  className="inline-flex items-center justify-center gap-2 bg-white/80 backdrop-blur-sm border border-emerald-200 text-emerald-800 px-8 py-4 rounded-xl font-semibold hover:bg-white transition"
                >
                  See how it works <ChevronRight className="h-5 w-5" />
                </a>
              </div>

              <div className="mt-8 text-sm text-gray-600">
                <p>• Android only for now (APK ~49 MB)</p>
                <p>• No Google Play listing yet — direct install (allow unknown sources)</p>
              </div>

              <div className="mt-6 flex items-center gap-6 text-sm text-gray-600">
                <div className="flex -space-x-2">
                  <img src="https://randomuser.me/api/portraits/women/44.jpg" alt="" className="w-10 h-10 rounded-full border-2 border-white shadow" />
                  <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="" className="w-10 h-10 rounded-full border-2 border-white shadow" />
                  <img src="https://randomuser.me/api/portraits/women/68.jpg" alt="" className="w-10 h-10 rounded-full border-2 border-white shadow" />
                </div>
                <span>Joined by <strong className="text-green-700">120+</strong> farmers</span>
              </div>
            </div>

            <div className="relative mt-12 lg:mt-0">
              <div className="relative z-10 rounded-3xl overflow-hidden shadow-2xl border border-emerald-100/50 bg-white/30 backdrop-blur-sm">
                <img
                  src="https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&q=80&w=1200"
                  alt="Farmer using Agri AI app in field"
                  className="w-full h-auto object-cover"
                />
              </div>
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
              { num: "2", title: "Upload", desc: "Send image to Agri AI — works offline too (queued sync)." },
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
              <p className="text-xl text-emerald-100">User rating</p>
            </div>
          </div>
        </div>
      </section>

      {/* Download CTA - Main prominent section */}
      <section id="download" className="py-24 md:py-32 bg-gradient-to-br from-emerald-600 to-green-700 text-white text-center">
        <div className="max-w-5xl mx-auto px-5">
          <h2 className="text-4xl md:text-6xl font-extrabold mb-8">Get Agri AI Now</h2>
          <p className="text-xl md:text-2xl mb-10 max-w-3xl mx-auto opacity-90">
            Download the latest version directly — free, no registration, no ads.
          </p>

          <div className="flex flex-col sm:flex-row justify-center gap-6 md:gap-10">
            <a
              href={apkDownloadUrl}
              download={apkFileName}
              className="inline-flex items-center justify-center gap-3 bg-black/90 backdrop-blur-sm text-white px-10 py-6 rounded-2xl font-bold text-xl shadow-2xl hover:scale-105 hover:shadow-2xl transition duration-300 border border-white/20"
            >
              <Download className="h-7 w-7" />
              Download APK v{version}
            </a>

            <div className="text-sm opacity-80 mt-4 sm:mt-0 self-center">
              <p>~49 MB • Android 7.0+</p>
              <p className="mt-1">Allow "Install from unknown sources" in settings</p>
            </div>
          </div>

          <p className="mt-10 text-lg opacity-90">
            iOS version coming soon • Google Play listing in progress
          </p>
        </div>
      </section>

      {/* FAQ */}
      <section id="faq" className="py-20 md:py-28 bg-white">
        <div className="max-w-4xl mx-auto px-5">
          <h2 className="text-4xl md:text-5xl font-bold text-center text-green-900 mb-16">Common Questions</h2>

          <div className="space-y-8">
            {[
              { q: "Is Agri AI free?", a: "Yes — completely free with no in-app purchases or ads." },
              { q: "How do I install the APK?", a: "Download → open file → allow unknown sources → install. You may need to enable this in Settings → Apps → Special app access." },
              { q: "Does it work offline?", a: "Basic detection works offline after first use. Internet improves accuracy and updates models." },
              { q: "Which crops are supported?", a: "Maize, rice, tomatoes, potatoes, beans, cassava, wheat, coffee, bananas, and more — list grows monthly." },
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
          <p className="text-lg">Agri AI © {new Date().getFullYear()}. Helping farmers grow healthier crops.</p>
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