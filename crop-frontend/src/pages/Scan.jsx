// Scan.jsx
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import API from "../api/api";

export default function Scan() {
  const navigate = useNavigate();

  const [sidebarOpen, setSidebarOpen] = useState(false);
  //const [userName] = useState("Dr. Elena Fisher"); // Replace with real data from auth
   const [userName, setUserName] = useState("User");

  // Upload + Prediction states
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [predicting, setPredicting] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const handleFileChange = (e) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) {
      setFile(selectedFile);
      setPreview(URL.createObjectURL(selectedFile));
      setResult(null);
      setError(null);
    }
  };

  const handlePredict = async () => {
    if (!file) {
      setError("Please select an image first.");
      return;
    }

    setPredicting(true);
    setError(null);

    const formData = new FormData();
    formData.append("image", file);

    try {
      const res = await API.post("/predict/", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });

      setResult(res.data);
    } catch (err) {
      console.error("Scan error:", err);
      setError("Failed to analyze the image. Please try again.");
    } finally {
      setPredicting(false);
    }
  };

  const handleLogout = () => {
    if (window.confirm("Are you sure you want to log out?")) {
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      navigate("/login");
    }
  };

  const clearUpload = () => {
    setFile(null);
    setPreview(null);
    setResult(null);
    setError(null);
  };

  return (
    <div className="relative flex h-screen w-full overflow-hidden font-['Inter'] bg-[#f6f8f6] dark:bg-[#141e14] text-slate-900 dark:text-slate-100">
      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 w-64 transform transition-transform duration-300 lg:relative lg:translate-x-0
          ${sidebarOpen ? "translate-x-0" : "-translate-x-full"}
          border-r border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 flex flex-col`}
      >
        <div className="flex flex-col gap-8 p-6">
          {/* Logo + close on mobile */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[#3cbe45] text-white">
                <span className="material-symbols-outlined">psychiatry</span>
              </div>
              <div className="flex flex-col">
                <h1 className="text-base font-bold leading-tight">AgriScan AI</h1>
                <p className="text-xs text-[#3cbe45] font-medium">Precision Farming</p>
              </div>
            </div>
            <button className="lg:hidden text-slate-600 dark:text-slate-400" onClick={() => setSidebarOpen(false)}>
              <span className="material-symbols-outlined text-2xl">close</span>
            </button>
          </div>

          {/* Navigation */}
          <nav className="flex flex-col gap-2">
            <a
              href="/dashboard"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
            >
              <span className="material-symbols-outlined">dashboard</span>
              <span className="text-sm font-medium">Dashboard</span>
            </a>
            <a
              href="/scan"
              className="flex items-center gap-3 rounded-lg bg-[#3cbe45]/10 px-3 py-2 text-[#3cbe45]"
            >
              <span className="material-symbols-outlined">document_scanner</span>
              <span className="text-sm font-medium">Scan Crop</span>
            </a>
            <a
              href="/history"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
            >
              <span className="material-symbols-outlined">history</span>
              <span className="text-sm font-medium">History</span>
            </a>
            <a
              href="#"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
            >
              <span className="material-symbols-outlined">analytics</span>
              <span className="text-sm font-medium">Reports</span>
            </a>
            <a
              href="#"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
            >
              <span className="material-symbols-outlined">settings</span>
              <span className="text-sm font-medium">Settings</span>
            </a>
          </nav>
        </div>

        {/* Storage Usage (optional on this page) */}
        <div className="mt-auto p-6">
          <div className="rounded-xl bg-[#3cbe45]/5 p-4 opacity-70">
            <p className="text-xs font-semibold text-[#3cbe45] uppercase tracking-wider">Storage Usage</p>
            <div className="mt-2 h-1.5 w-full rounded-full bg-[#3cbe45]/20">
              <div className="h-1.5 rounded-full bg-[#3cbe45]" style={{ width: "75%" }} />
            </div>
            <p className="mt-2 text-[10px] text-slate-500">75% of 1,000 scans used</p>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex flex-1 flex-col overflow-y-auto">
        {/* Top Bar */}
        <header className="flex h-16 items-center justify-between border-b border-[#3cbe45]/10 bg-white/80 dark:bg-[#141e14]/80 px-4 sm:px-6 lg:px-8 backdrop-blur-md">
          <div className="flex items-center gap-3 lg:hidden">
            <button onClick={() => setSidebarOpen(true)}>
              <span className="material-symbols-outlined text-2xl text-slate-600 dark:text-slate-400">menu</span>
            </button>
            <h2 className="text-lg font-bold">Scan Crop</h2>
          </div>

          <div className="hidden lg:block">
            <h2 className="text-lg font-bold">Scan Crop</h2>
          </div>

          <div className="flex items-center gap-3 sm:gap-6">
            <div className="relative w-48 sm:w-64">
              <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">
                search
              </span>
              <input
                className="w-full rounded-lg border-none bg-slate-100 dark:bg-slate-800 py-1.5 pl-10 pr-4 text-sm focus:ring-2 focus:ring-[#3cbe45]/20"
                placeholder="Search scans..."
                type="text"
              />
            </div>

            <button className="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/10 hover:text-[#3cbe45] transition-colors">
              <span className="material-symbols-outlined">notifications</span>
            </button>

            <div className="flex items-center gap-2 sm:gap-3">
              <div className="text-right hidden sm:block">
                <p className="text-xs font-bold">{userName}</p>
                <p className="text-[10px] text-slate-500">Agronomist</p>
              </div>
              <img
                alt="Profile"
                className="h-8 w-8 sm:h-9 sm:w-9 rounded-full object-cover ring-2 ring-[#3cbe45]/20"
                src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80"
              />
            </div>

            <button
              onClick={handleLogout}
              className="text-sm text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
            >
              Logout
            </button>
          </div>
        </header>

        {/* Scan Content */}
        <div className="p-4 sm:p-6 lg:p-8 max-w-5xl mx-auto">
          <h3 className="mb-6 text-xl sm:text-2xl font-bold">Scan Your Crop</h3>

          <div className="rounded-2xl border-2 border-dashed border-[#3cbe45]/30 bg-[#3cbe45]/5 p-6 sm:p-10 text-center">
            {/* Upload Area */}
            <div className="mb-6">
              {preview ? (
                <div className="relative inline-block">
                  <img
                    src={preview}
                    alt="Crop preview"
                    className="max-h-64 sm:max-h-80 mx-auto rounded-xl shadow-lg object-contain border border-[#3cbe45]/20"
                  />
                  <button
                    onClick={() => {
                      setFile(null);
                      setPreview(null);
                      setResult(null);
                      setError(null);
                    }}
                    className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-2 hover:bg-red-600 transition"
                  >
                    <span className="material-symbols-outlined text-sm">close</span>
                  </button>
                </div>
              ) : (
                <div className="py-12">
                  <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-[#3cbe45]/10 text-[#3cbe45]">
                    <span className="material-symbols-outlined text-4xl">add_a_photo</span>
                  </div>
                  <p className="mt-4 text-lg font-medium text-slate-700 dark:text-slate-300">
                    Drop your crop image here or click to upload
                  </p>
                  <p className="mt-2 text-sm text-slate-500">
                    Supports JPG, PNG, HEIC • Max 10MB
                  </p>
                </div>
              )}
            </div>

            {/* Upload Button */}
            <label className="cursor-pointer inline-block">
              <div className="flex items-center justify-center gap-2 rounded-lg bg-[#3cbe45] px-6 py-3 text-sm font-bold text-white shadow-lg shadow-[#3cbe45]/30 hover:bg-[#35a93d] transition-all">
                <span className="material-symbols-outlined">upload_file</span>
                Select Image
              </div>
              <input
                type="file"
                accept="image/*"
                onChange={handleFileChange}
                className="hidden"
              />
            </label>

            {/* Analyze Button */}
            {file && (
              <button
                onClick={handlePredict}
                disabled={predicting}
                className={`mt-6 px-10 py-3 rounded-lg font-bold text-white transition-all shadow-lg ${
                  predicting
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-[#3cbe45] hover:bg-[#35a93d] shadow-[#3cbe45]/40"
                }`}
              >
                {predicting ? (
                  <span className="flex items-center gap-2">
                    <span className="material-symbols-outlined animate-spin">hourglass_top</span>
                    Analyzing...
                  </span>
                ) : (
                  "Analyze Image"
                )}
              </button>
            )}

            {/* Error Message */}
            {error && (
              <div className="mt-6 p-4 bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-800 rounded-lg text-red-700 dark:text-red-300 text-sm">
                {error}
              </div>
            )}
          </div>

          {/* Prediction Result */}
          {result && (
            <div className="mt-10">
              <h3 className="mb-5 text-xl font-bold text-center sm:text-left">Diagnosis Result</h3>

              <div className="rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 shadow-sm overflow-hidden">
                <div className="flex flex-col md:flex-row">
                  {/* Result Image */}
                  <div className="h-64 md:h-auto md:w-96 lg:w-[500px] bg-slate-50 dark:bg-slate-900">
                    <img
                      src={preview}
                      alt="Scanned crop"
                      className="h-full w-full object-contain p-4"
                    />
                  </div>

                  {/* Result Details */}
                  <div className="flex-1 p-6">
                    <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                      <div>
                        <h4 className="text-2xl sm:text-3xl font-bold">
                          {result.disease || result.disease_name || "Unknown Condition"}
                        </h4>
                        <p className="mt-2 text-sm text-slate-500">
                          Detected just now • Pathogen: <span className="italic">{result.pathogen || "N/A"}</span>
                        </p>
                      </div>

                      <div className="text-right">
                        <p className="text-4xl sm:text-5xl font-bold text-[#3cbe45]">
                          {(result.confidence * 100 || result.confidence || 0).toFixed(1)}%
                        </p>
                        <p className="text-xs text-slate-500 mt-1">Confidence Score</p>
                      </div>
                    </div>

                    {/* Advice */}
                    <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="rounded-lg bg-[#3cbe45]/5 p-5">
                        <h5 className="flex items-center gap-2 text-base font-bold text-[#3cbe45]">
                          <span className="material-symbols-outlined">health_and_safety</span>
                          Recommended Action
                        </h5>
                        <p className="mt-3 text-sm text-slate-700 dark:text-slate-300">
                          {result.recommendation ||
                            "Apply appropriate fungicide and remove affected leaves immediately."}
                        </p>
                      </div>

                      <div className="rounded-lg bg-[#3cbe45]/5 p-5">
                        <h5 className="flex items-center gap-2 text-base font-bold text-[#3cbe45]">
                          <span className="material-symbols-outlined">assignment</span>
                          Prevention Tips
                        </h5>
                        <p className="mt-3 text-sm text-slate-700 dark:text-slate-300">
                          {result.prevention ||
                            "Improve air circulation, avoid overhead watering, and monitor regularly."}
                        </p>
                      </div>
                    </div>

                    {/* Buttons */}
                    <div className="mt-8 flex flex-wrap gap-3 justify-end">
                      <button
                        onClick={clearUpload}
                        className="rounded-lg px-5 py-2.5 text-sm font-medium text-slate-600 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                      >
                        New Scan
                      </button>
                      <button className="rounded-lg bg-[#3cbe45]/10 px-5 py-2.5 text-sm font-medium text-[#3cbe45] hover:bg-[#3cbe45]/20 transition-colors">
                        Save to History
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}