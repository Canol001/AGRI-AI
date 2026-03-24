import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import API from "../api/api";

export default function Dashboard() {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // User & stats
  const [userName, setUserName] = useState("User");
  const [totalScans, setTotalScans] = useState(0);
  const [healthRatio, setHealthRatio] = useState(null);
  const [recentAlerts, setRecentAlerts] = useState(0);
  const [storageUsedPercent, setStorageUsedPercent] = useState(0);

  // Recent scans (limited preview)
  const [recentScans, setRecentScans] = useState([]);

  // Current upload + prediction
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [predicting, setPredicting] = useState(false);
  const [predictionResult, setPredictionResult] = useState(null);
  const [predictionError, setPredictionError] = useState(null);

  // Mobile sidebar toggle
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("access");
    if (!token) {
      navigate("/login");
      return;
    }

    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        const [dashboardRes, scansRes] = await Promise.all([
          API.get("/dashboard/"),
          API.get("/recent-scans/"),
        ]);

        // Set user & stats
        setUserName(dashboardRes.data.user || "User");
        setTotalScans(dashboardRes.data.total_scans || 0);
        setHealthRatio(dashboardRes.data.health_ratio ?? null);
        setRecentAlerts(dashboardRes.data.alerts || 0);

        // Storage usage (assuming max 1000 scans)
        const used = Math.min(100, Math.round((dashboardRes.data.total_scans || 0) / 10));
        setStorageUsedPercent(used);

        // Recent scans
        setRecentScans(scansRes.data || []);
      } catch (err) {
        console.error("Dashboard fetch error:", err);
        if (err.response?.status === 401) {
          localStorage.removeItem("access");
          localStorage.removeItem("refresh");
          navigate("/login");
        } else {
          setError("Failed to load dashboard. Please try again.");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [navigate]);

  const handleFileChange = (e) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) {
      setFile(selectedFile);
      setPreview(URL.createObjectURL(selectedFile));
      setPredictionResult(null);
      setPredictionError(null);
    }
  };

  const handlePredict = async () => {
    if (!file) {
      setPredictionError("Please select an image first.");
      return;
    }

    setPredicting(true);
    setPredictionError(null);

    const formData = new FormData();
    formData.append("image", file);

    try {
      const res = await API.post("/predict/", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });

      setPredictionResult(res.data);

      // Refresh recent scans & stats
      const [scansRes, dashboardRes] = await Promise.all([
        API.get("/recent-scans/"),
        API.get("/dashboard/"),
      ]);

      setRecentScans(scansRes.data || []);
      setTotalScans(dashboardRes.data.total_scans || totalScans);
      setStorageUsedPercent(Math.min(100, Math.round((dashboardRes.data.total_scans || 0) / 10)));
    } catch (err) {
      console.error("Prediction error:", err);
      setPredictionError("Failed to analyze image. Please try again.");
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

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f6f8f6] dark:bg-[#141e14]">
        <div className="text-center">
          <div className="material-symbols-outlined text-6xl text-[#3cbe45] animate-spin">
            hourglass_top
          </div>
          <p className="mt-4 text-slate-600 dark:text-slate-400">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f6f8f6] dark:bg-[#141e14]">
        <div className="text-center max-w-md px-6">
          <p className="text-xl font-bold text-red-600 mb-4">Error</p>
          <p className="text-slate-600 dark:text-slate-400 mb-6">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-6 py-3 bg-[#3cbe45] text-white rounded-lg font-medium hover:bg-[#35a93d]"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  // Latest result = current prediction OR most recent scan
  const latest = predictionResult || (recentScans.length > 0 ? recentScans[0] : null);

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
          {/* Logo + mobile close */}
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
              href="#"
              className="flex items-center gap-3 rounded-lg bg-[#3cbe45]/10 px-3 py-2 text-[#3cbe45]"
            >
              <span className="material-symbols-outlined">dashboard</span>
              <span className="text-sm font-medium">Dashboard</span>
            </a>
            <a
              href="/scan"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
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
            {/* <a
              href="#"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
            >
              <span className="material-symbols-outlined">analytics</span>
              <span className="text-sm font-medium">Reports</span>
            </a> */}
            <a
              href="/settings"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
            >
              <span className="material-symbols-outlined">settings</span>
              <span className="text-sm font-medium">Settings</span>
            </a>
          </nav>
        </div>

        {/* Storage Usage */}
        <div className="mt-auto p-6">
          <div className="rounded-xl bg-[#3cbe45]/5 p-4">
            <p className="text-xs font-semibold text-[#3cbe45] uppercase tracking-wider">Storage Usage</p>
            <div className="mt-2 h-1.5 w-full rounded-full bg-[#3cbe45]/20">
              <div className="h-1.5 rounded-full bg-[#3cbe45]" style={{ width: `${storageUsedPercent}%` }} />
            </div>
            <p className="mt-2 text-[10px] text-slate-500">
              {storageUsedPercent}% of 1,000 scans used
            </p>
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
            <h2 className="text-lg font-bold">Agri_AI</h2>
          </div>

          <div className="hidden lg:block">
            <h2 className="text-lg font-bold">Agri_AI</h2>
          </div>

          <div className="flex items-center gap-3 sm:gap-6">
            <div className="relative w-48 sm:w-64">
              <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">search</span>
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

        {/* Content */}
        <div className="p-4 sm:p-6 lg:p-8">
          {/* Stats */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {/* Total Scans */}
            <div className="rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 p-5 sm:p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-slate-500">Total Scans</p>
                <span className="material-symbols-outlined text-[#3cbe45]">monitoring</span>
              </div>
              <p className="mt-2 text-2xl sm:text-3xl font-bold">{totalScans}</p>
              <div className="mt-2 flex items-center gap-1 text-xs font-semibold text-[#3cbe45]">
                <span className="material-symbols-outlined text-xs">trending_up</span>
                <span>+12.5% this month</span>
              </div>
            </div>

            {/* Health Ratio */}
            <div className="rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 p-5 sm:p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-slate-500">Health Ratio</p>
                <span className="material-symbols-outlined text-[#3cbe45]">eco</span>
              </div>
              <p className="mt-2 text-2xl sm:text-3xl font-bold">
                {healthRatio !== null ? `${healthRatio}%` : "—"}
              </p>
              <div className="mt-2 flex items-center gap-1 text-xs font-semibold text-[#3cbe45]">
                <span className="material-symbols-outlined text-xs">check_circle</span>
                <span>Optimal performance</span>
              </div>
            </div>

            {/* Recent Alerts */}
            <div className="rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 p-5 sm:p-6 shadow-sm">
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-slate-500">Recent Alerts</p>
                <span className="material-symbols-outlined text-orange-500">warning</span>
              </div>
              <p className="mt-2 text-2xl sm:text-3xl font-bold">{recentAlerts} Cases</p>
              <div className="mt-2 flex items-center gap-1 text-xs font-semibold text-orange-500">
                <span className="material-symbols-outlined text-xs">schedule</span>
                <span>Action required</span>
              </div>
            </div>
          </div>

          {/* Scan Crop Section */}
          <div className="mt-8">
            <div className="rounded-xl border-2 border-dashed border-[#3cbe45]/20 bg-[#3cbe45]/5 px-4 sm:px-6 py-10 sm:py-12 text-center">
              <div className="mb-4 flex h-14 w-14 sm:h-16 sm:w-16 mx-auto items-center justify-center rounded-full bg-[#3cbe45]/10 text-[#3cbe45]">
                <span className="material-symbols-outlined text-3xl">upload_file</span>
              </div>
              <h3 className="text-xl sm:text-2xl font-bold">Scan Your Crop</h3>
              <p className="mt-2 max-w-md mx-auto text-sm text-slate-500">
                Upload high-resolution images of crop leaves for instant AI diagnosis. Supports JPG, PNG, HEIC.
              </p>

              {preview && (
                <div className="mt-6">
                  <img
                    src={preview}
                    alt="Uploaded crop preview"
                    className="max-h-48 sm:max-h-64 mx-auto rounded-lg shadow-md object-contain"
                  />
                </div>
              )}

              <div className="mt-6 sm:mt-8 flex flex-col sm:flex-row gap-4 justify-center">
                <label className="cursor-pointer">
                  <div className="flex items-center justify-center gap-2 rounded-lg bg-[#3cbe45] px-6 py-2.5 sm:py-3 text-sm font-bold text-white shadow-lg shadow-[#3cbe45]/20 hover:bg-[#35a93d] transition-all">
                    <span className="material-symbols-outlined text-sm">add_a_photo</span>
                    Files
                  </div>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                </label>

                <button
                  disabled
                  className="flex items-center justify-center gap-2 rounded-lg border border-[#3cbe45]/20 bg-white dark:bg-[#141e14] px-6 py-2.5 sm:py-3 text-sm font-bold text-[#3cbe45] opacity-60 cursor-not-allowed"
                >
                  <span className="material-symbols-outlined text-sm">camera_alt</span>
                  Camera
                </button>
              </div>

              <button
                onClick={handlePredict}
                disabled={predicting || !file}
                className={`mt-6 px-8 py-3 rounded-lg font-bold text-white transition-all shadow-lg ${
                  predicting || !file
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-[#3cbe45] hover:bg-[#35a93d] shadow-[#3cbe45]/30"
                }`}
              >
                {predicting ? "Analyzing..." : "Run Diagnosis"}
              </button>

              {predictionError && (
                <p className="mt-4 text-sm text-red-600 bg-red-50 dark:bg-red-950/30 p-3 rounded-lg">
                  {predictionError}
                </p>
              )}
            </div>
          </div>

          {/* Latest Diagnosis Result */}
          {latest && (
            <div className="mt-10">
              <h3 className="mb-4 text-sm font-bold uppercase tracking-wider text-slate-400">
                Latest Diagnosis Result
              </h3>

              <div className="overflow-hidden rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 shadow-sm">
                <div className="flex flex-col md:flex-row">
                  {/* Image */}
                  <div className="h-64 md:h-auto md:w-80 lg:w-96 relative">
                    <img
                      src={`${import.meta.env.VITE_API_BASE_URL}${latest.image || latest.image_url || ""}`}
                      alt={latest.disease || latest.disease_name || "Crop scan"}
                      className="h-full w-full object-cover"
                      onError={(e) => {
                        e.currentTarget.src =
                          "https://tse4.mm.bing.net/th/id/OIP.EMOozEnvhQmAU0Mw4NioSwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3";
                      }}
                    />
                  </div>

                  {/* Content */}
                  <div className="flex flex-1 flex-col p-5 sm:p-6">
                    <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
                      <div>
                        <div className="flex items-center flex-wrap gap-3">
                          <h4 className="text-2xl sm:text-3xl font-bold">
                            {latest.disease || latest.disease_name || "Unknown"}
                          </h4>
                          <span className="rounded-full bg-orange-100 dark:bg-orange-900/30 px-3 py-1 text-xs sm:text-sm font-bold uppercase text-orange-600 dark:text-orange-400">
                            HIGH RISK
                          </span>
                        </div>
                        <p className="mt-2 text-sm text-slate-500">
                          Pathogen: <span className="italic">{latest.recommendation?.pathogen || "Unknown"} </span> • Detected{" "}
                          {new Date(latest.date || latest.created_at || Date.now()).toLocaleString()}
                        </p>
                      </div>

                      <div className="text-right">
                        <p className="text-3xl sm:text-4xl font-bold text-[#3cbe45]">
                          {(latest.confidence || latest.confidence || 0).toFixed(0)}%
                        </p>
                        <p className="text-xs text-slate-500">Confidence Score</p>
                      </div>
                    </div>

                    {/* Treatment & Prevention — now from API */}
                    <div className="mt-6 sm:mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="rounded-lg bg-slate-50 dark:bg-slate-800/50 p-4 sm:p-5">
                        <h5 className="flex items-center gap-2 text-base font-bold text-slate-700 dark:text-slate-300">
                          <span className="material-symbols-outlined text-[#3cbe45]">health_and_safety</span>
                          Recommended Treatment
                        </h5>
                        <div className="mt-3 text-sm text-slate-600 dark:text-slate-400 space-y-2">
                          {predictionResult?.recommendation?.treatment ? (
                            <p>{predictionResult.recommendation.treatment}</p>
                          ) : latest?.recommendation?.treatment ? (
                            <p>{latest.recommendation.treatment}</p>
                          ) : (
                            <p className="text-slate-400 italic">No treatment recommendation available</p>
                          )}
                        </div>
                      </div>

                      <div className="rounded-lg bg-slate-50 dark:bg-slate-800/50 p-4 sm:p-5">
                        <h5 className="flex items-center gap-2 text-base font-bold text-slate-700 dark:text-slate-300">
                          <span className="material-symbols-outlined text-[#3cbe45]">assignment</span>
                          Prevention Plan
                        </h5>
                        <div className="mt-3 text-sm text-slate-600 dark:text-slate-400 space-y-2">
                          {predictionResult?.recommendation?.prevention ? (
                            <p>{predictionResult.recommendation.prevention}</p>
                          ) : latest?.recommendation?.prevention ? (
                            <p>{latest.recommendation.prevention}</p>
                          ) : (
                            <p className="text-slate-400 italic">No prevention advice available</p>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="mt-6 sm:mt-8 flex flex-wrap justify-end gap-3">
                      <button className="rounded-lg px-4 py-2 text-xs sm:text-sm font-medium text-slate-600 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors">
                        Discard Scan
                      </button>
                      <button className="rounded-lg bg-[#3cbe45]/10 px-4 py-2 text-xs sm:text-sm font-medium text-[#3cbe45] hover:bg-[#3cbe45]/20 transition-colors">
                        Generate PDF Report
                      </button>
                      <button className="rounded-lg bg-[#3cbe45] px-5 py-2.5 sm:py-3 text-xs sm:text-sm font-medium text-white hover:bg-[#35a93d] transition-all shadow-md">
                        Save to History
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Link to full history */}
          <div className="mt-8 text-center sm:text-right">
            <a
              href="/history"
              className="inline-flex items-center gap-2 text-[#3cbe45] font-medium hover:underline"
            >
              View Full Scan History
              <span className="material-symbols-outlined text-base">arrow_forward</span>
            </a>
          </div>
        </div>
      </main>
    </div>
  );
}