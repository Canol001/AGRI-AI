import { Leaf, Camera, BarChart2, ShieldCheck } from 'lucide-react'; // Assuming lucide-react is installed

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-emerald-50 font-sans">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 bg-white/90 backdrop-blur-md shadow-md">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center">
              <Leaf className="h-8 w-8 text-green-600" />
              <span className="ml-2 text-xl font-bold text-green-800">CropGuard</span>
            </div>
            <div className="hidden md:block">
              <div className="ml-10 flex items-baseline space-x-4">
                <a href="#features" className="text-green-700 hover:text-green-900 px-3 py-2 rounded-md text-sm font-medium">Features</a>
                <a href="#how-it-works" className="text-green-700 hover:text-green-900 px-3 py-2 rounded-md text-sm font-medium">How It Works</a>
                <a href="#about" className="text-green-700 hover:text-green-900 px-3 py-2 rounded-md text-sm font-medium">About</a>
                <a href="/login" className="bg-green-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-green-700 transition">Login</a>
                <a href="/register" className="bg-green-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-green-700 transition ml-4">Sign Up</a>
              </div>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative bg-gradient-to-r from-green-600 to-emerald-600 text-white py-20 md:py-32 overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="md:flex md:items-center md:justify-between">
            <div className="md:w-1/2">
              <h1 className="text-4xl md:text-6xl font-bold tracking-tight mb-6 animate-fade-in-up">
                Protect Your Crops with AI-Powered Disease Detection
              </h1>
              <p className="text-xl mb-8 animate-fade-in-up animation-delay-200">
                Early diagnosis saves harvests. Upload a photo and get instant insights on crop health.
              </p>
              <a 
                href="/login"
                className="inline-flex items-center bg-white text-green-600 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition shadow-md animate-fade-in-up animation-delay-400"
              >
                <Camera className="mr-2 h-5 w-5" />
                Start Detection
              </a>
            </div>
            <div className="md:w-1/2 mt-10 md:mt-0">
              <img 
                src="https://miro.medium.com/1*BND0zVNGrZrKL3EHA9gdYA.png" 
                alt="AI Crop Disease Detection" 
                className="rounded-xl shadow-2xl transform rotate-3 animate-float"
              />
            </div>
          </div>
        </div>
        {/* Subtle animation overlay */}
        <div className="absolute bottom-0 left-0 right-0 h-20 bg-gradient-to-t from-emerald-50 to-transparent"></div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center text-green-800 mb-12">Why Choose CropGuard?</h2>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="p-6 rounded-xl shadow-lg bg-green-50 hover:shadow-xl transition animate-fade-in">
              <Camera className="h-12 w-12 text-green-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">Instant Detection</h3>
              <p className="text-gray-600">Upload photos of your crops and get real-time disease identification using advanced AI.</p>
            </div>
            <div className="p-6 rounded-xl shadow-lg bg-green-50 hover:shadow-xl transition animate-fade-in animation-delay-200">
              <BarChart2 className="h-12 w-12 text-green-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">Accurate Diagnosis</h3>
              <p className="text-gray-600">High-precision models trained on thousands of crop images for reliable results.</p>
            </div>
            <div className="p-6 rounded-xl shadow-lg bg-green-50 hover:shadow-xl transition animate-fade-in animation-delay-400">
              <ShieldCheck className="h-12 w-12 text-green-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">Preventive Advice</h3>
              <p className="text-gray-600">Get tailored treatment recommendations to protect your yield.</p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="py-20 bg-emerald-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center text-green-800 mb-12">How It Works</h2>
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <img 
              src="https://www.gsma.com/solutions-and-impact/connectivity-for-good/mobile-for-development/wp-content/uploads/2025/02/Plantix-blog-image-1.png" 
              alt="Farmer detecting crop disease" 
              className="rounded-xl shadow-2xl animate-fade-in"
            />
            <div>
              <ol className="space-y-6">
                <li className="flex items-start">
                  <div className="flex-shrink-0 w-8 h-8 bg-green-600 text-white rounded-full flex items-center justify-center font-bold">1</div>
                  <p className="ml-4 text-lg">Capture a photo of the affected crop area.</p>
                </li>
                <li className="flex items-start">
                  <div className="flex-shrink-0 w-8 h-8 bg-green-600 text-white rounded-full flex items-center justify-center font-bold">2</div>
                  <p className="ml-4 text-lg">Upload to our AI-powered detector.</p>
                </li>
                <li className="flex items-start">
                  <div className="flex-shrink-0 w-8 h-8 bg-green-600 text-white rounded-full flex items-center justify-center font-bold">3</div>
                  <p className="ml-4 text-lg">Receive diagnosis and treatment tips instantly.</p>
                </li>
              </ol>
            </div>
          </div>
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="md:flex md:items-center md:justify-between">
            <div className="md:w-1/2">
              <img 
                src="https://www.cropin.com/wp-content/uploads/2021/12/Cropins-disease-early-warning-system.webp" 
                alt="Crop disease inspection" 
                className="rounded-xl shadow-2xl"
              />
            </div>
            <div className="md:w-1/2 mt-10 md:mt-0 md:pl-12">
              <h2 className="text-3xl font-bold text-green-800 mb-6">About CropGuard</h2>
              <p className="text-gray-600 mb-4">
                Our mission is to empower farmers with cutting-edge AI technology to detect and manage crop diseases early, reducing losses and increasing yields.
              </p>
              <p className="text-gray-600 mb-4">
                Using machine learning models, we analyze plant images to identify over 100 common diseases across major crops.
              </p>
              <a href="/learn-more" className="text-green-600 font-semibold hover:underline">Learn more about our technology →</a>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-green-600 text-white py-20 text-center">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold mb-6">Ready to Safeguard Your Crops?</h2>
          <p className="text-xl mb-8">Join thousands of farmers using CropGuard today.</p>
          <a 
            href="/register"
            className="bg-white text-green-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition shadow-md"
          >
            Get Started Free
          </a>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-green-800 text-white py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="md:flex md:justify-between">
            <div>
              <Leaf className="h-6 w-6 mb-2" />
              <p>CropGuard © 2026. All rights reserved.</p>
            </div>
            <div className="mt-4 md:mt-0">
              <a href="/privacy" className="block hover:underline">Privacy Policy</a>
              <a href="/terms" className="block hover:underline">Terms of Service</a>
              <a href="/contact" className="block hover:underline">Contact Us</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

// Add to your tailwind.config.js for animations:
// plugins: [require('tailwindcss-animate')],
// Then in CSS:
// .animate-fade-in { animation: fadeIn 1s ease-out; }
// @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
// .animate-float { animation: float 3s ease-in-out infinite; }
// @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }
// .animation-delay-200 { animation-delay: 0.2s; }
// etc.