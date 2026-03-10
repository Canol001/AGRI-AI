import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import API from "../api/api";

export default function History() {
  const navigate = useNavigate();

  const [scans, setScans] = useState([]);
  const [totalScans, setTotalScans] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // Selected scan for modal
  const [selectedScan, setSelectedScan] = useState(null);
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [deleteError, setDeleteError] = useState(null);

  // User info
  const [userName, setUserName] = useState("User");

  useEffect(() => {
    const token = localStorage.getItem("access");
    if (!token) {
      navigate("/login");
      return;
    }

    const fetchHistory = async () => {
      try {
        setLoading(true);
        setError(null);

        const [dashboardRes, scansRes] = await Promise.all([
          API.get("/dashboard/"),
          API.get("/recent-scans/"), // or "/history/" if you have a full history endpoint
        ]);

        setUserName(dashboardRes.data.user || "User");
        setTotalScans(dashboardRes.data.total_scans || 0);
        setScans(scansRes.data || []);
      } catch (err) {
        console.error("History fetch error:", err);
        if (err.response?.status === 401) {
          localStorage.removeItem("access");
          localStorage.removeItem("refresh");
          navigate("/login");
        } else {
          setError("Failed to load scan history.");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchHistory();
  }, [navigate]);

  const handleLogout = () => {
    if (window.confirm("Are you sure you want to log out?")) {
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      navigate("/login");
    }
  };

  const openDetails = (scan) => {
    setSelectedScan(scan);
    setDeleteError(null);
  };

  const closeModal = () => {
    setSelectedScan(null);
    setDeleteError(null);
  };

  const handleDeleteScan = async () => {
    if (!selectedScan) return;

    if (!window.confirm("Are you sure you want to delete this scan? This action cannot be undone.")) {
      return;
    }

    setDeleteLoading(true);
    setDeleteError(null);

    try {
      await API.delete(`/scans/${selectedScan.id}/`); // Adjust endpoint as per your backend

      // Remove from list
      setScans((prev) => prev.filter((s) => s.id !== selectedScan.id));
      setTotalScans((prev) => Math.max(0, prev - 1));

      // Close modal
      closeModal();
    } catch (err) {
      console.error("Delete error:", err);
      setDeleteError("Failed to delete scan. Please try again.");
    } finally {
      setDeleteLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f6f8f6] dark:bg-[#141e14]">
        <div className="text-center">
          <div className="material-symbols-outlined text-6xl text-[#3cbe45] animate-spin">
            hourglass_top
          </div>
          <p className="mt-4 text-slate-600 dark:text-slate-400">Loading history...</p>
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
              href="/dashboard"
              className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors"
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
              className="flex items-center gap-3 rounded-lg bg-[#3cbe45]/10 px-3 py-2 text-[#3cbe45]"
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

        {/* Storage Usage */}
        <div className="mt-auto p-6">
          <div className="rounded-xl bg-[#3cbe45]/5 p-4">
            <p className="text-xs font-semibold text-[#3cbe45] uppercase tracking-wider">Storage Usage</p>
            <div className="mt-2 h-1.5 w-full rounded-full bg-[#3cbe45]/20">
              <div className="h-1.5 rounded-full bg-[#3cbe45]" style={{ width: `${Math.min(100, Math.round(totalScans / 10))}%` }} />
            </div>
            <p className="mt-2 text-[10px] text-slate-500">
              {Math.min(100, Math.round(totalScans / 10))}% of 1,000 scans used
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
            <h2 className="text-lg font-bold">Scan History</h2>
          </div>

          <div className="hidden lg:block">
            <h2 className="text-lg font-bold">Scan History</h2>
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

        {/* History Content */}
        <div className="p-4 sm:p-6 lg:p-8">
          <h3 className="mb-6 text-xl sm:text-2xl font-bold">Your Scan History</h3>

          {scans.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <span className="material-symbols-outlined text-6xl text-slate-300 mb-4">history</span>
              <p className="text-lg font-medium text-slate-600 dark:text-slate-400">No scans yet</p>
              <p className="mt-2 text-sm text-slate-500 max-w-md">
                Start scanning crops to see your diagnosis history here.
              </p>
              <a
                href="/dashboard"
                className="mt-6 inline-flex items-center gap-2 text-[#3cbe45] font-medium hover:underline"
              >
                Go to Dashboard
                <span className="material-symbols-outlined">arrow_forward</span>
              </a>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5 sm:gap-6">
              {scans.map((scan) => (
                <div
                  key={scan.id}
                  className="rounded-xl overflow-hidden border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 shadow-sm hover:shadow-md transition-shadow flex flex-col"
                >
                  <div className="relative aspect-[4/3] bg-slate-100 dark:bg-slate-900">
                    <img
                      src={`http://199.231.191.165:8000${scan.image}`}
                      alt={scan.disease || "Crop scan"}
                      className="h-full w-full object-cover"
                      onError={(e) => {
                        e.target.src = "https://images.unsplash.com/photo-1597843786411-a7fa8ed2f1c4?w=800";
                      }}
                    />
                    <div className="absolute top-3 right-3 bg-[#3cbe45] text-white text-xs font-bold px-2.5 py-1 rounded-full shadow">
                      {(scan.confidence || 0).toFixed(0)}%
                    </div>
                  </div>

                  <div className="p-4 flex flex-col flex-1">
                    <h4 className="font-semibold text-lg truncate">
                      {scan.disease || scan.disease_name || "Unknown"}
                    </h4>
                    <p className="mt-1 text-sm text-slate-500">
                      {new Date(scan.date || scan.created_at || Date.now()).toLocaleString()}
                    </p>

                    <div className="mt-auto pt-4 flex justify-end">
                      <button
                        onClick={() => openDetails(scan)}
                        className="text-sm font-medium text-[#3cbe45] hover:underline flex items-center gap-1"
                      >
                        View Details
                        <span className="material-symbols-outlined text-base">arrow_forward</span>
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>

      {/* Details Modal */}
      {selectedScan && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 px-4">
          <div className="bg-white dark:bg-[#1a2a1a] rounded-2xl shadow-2xl max-w-3xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-5 sm:p-6 lg:p-8">
              {/* Header */}
              <div className="flex items-start justify-between mb-6">
                <div>
                  <h3 className="text-2xl sm:text-3xl font-bold">
                    {selectedScan.disease || selectedScan.disease_name || "Unknown Diagnosis"}
                  </h3>
                  <p className="mt-1 text-sm text-slate-500">
                    Scanned on {new Date(selectedScan.date || selectedScan.created_at || Date.now()).toLocaleString()}
                  </p>
                </div>
                <button
                  onClick={closeModal}
                  className="text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200"
                >
                  <span className="material-symbols-outlined text-3xl">close</span>
                </button>
              </div>

              {/* Confidence & Pathogen */}
              <div className="mb-6 flex flex-wrap gap-6">
                <div>
                  <p className="text-sm text-slate-500">Confidence Score</p>
                  <p className="text-3xl font-bold text-[#3cbe45]">
                    {(selectedScan.confidence || 0).toFixed(1)}%
                  </p>
                </div>
                <div>
                  <p className="text-sm text-slate-500">Pathogen</p>
                  <p className="text-lg font-medium">
                    {selectedScan.recommendation?.pathogen || "Not specified"}
                  </p>
                </div>
              </div>

              {/* Treatment */}
              <div className="mb-6">
                <h4 className="flex items-center gap-2 text-lg font-bold mb-3 text-[#3cbe45]">
                  <span className="material-symbols-outlined">health_and_safety</span>
                  Recommended Treatment
                </h4>
                <div className="bg-slate-50 dark:bg-slate-800/50 p-4 rounded-lg text-sm text-slate-700 dark:text-slate-300 whitespace-pre-line">
                  {selectedScan.recommendation?.treatment ||
                    "No specific treatment information available from this scan."}
                </div>
              </div>

              {/* Prevention */}
              <div className="mb-8">
                <h4 className="flex items-center gap-2 text-lg font-bold mb-3 text-[#3cbe45]">
                  <span className="material-symbols-outlined">assignment</span>
                  Prevention Plan
                </h4>
                <div className="bg-slate-50 dark:bg-slate-800/50 p-4 rounded-lg text-sm text-slate-700 dark:text-slate-300 whitespace-pre-line">
                  {selectedScan.recommendation?.prevention ||
                    "No specific prevention advice available from this scan."}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row gap-4 justify-end">
                <button
                  onClick={closeModal}
                  className="px-6 py-3 bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 rounded-lg font-medium hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors"
                >
                  Close
                </button>

                <button
                  onClick={handleDeleteScan}
                  disabled={deleteLoading}
                  className={`px-6 py-3 rounded-lg font-medium text-white transition-all flex items-center justify-center gap-2 ${
                    deleteLoading
                      ? "bg-red-400 cursor-not-allowed"
                      : "bg-red-600 hover:bg-red-700 shadow-md"
                  }`}
                >
                  {deleteLoading ? (
                    <>
                      <span className="material-symbols-outlined animate-spin">hourglass_top</span>
                      Deleting...
                    </>
                  ) : (
                    <>
                      <span className="material-symbols-outlined">delete</span>
                      Remove from History
                    </>
                  )}
                </button>

                {deleteError && (
                  <p className="text-sm text-red-600 mt-2 text-center sm:text-left w-full">
                    {deleteError}
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}