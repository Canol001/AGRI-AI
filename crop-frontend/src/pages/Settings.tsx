import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import API from "../api/api";

export default function Settings() {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // User info
  const [userName, setUserName] = useState("User");

  // Password form
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const [passwordLoading, setPasswordLoading] = useState(false);
  const [passwordSuccess, setPasswordSuccess] = useState(false);
  const [passwordError, setPasswordError] = useState<string | null>(null);

  // Language preference (fetched from backend + saved to backend)
  const [preferredLanguage, setPreferredLanguage] = useState<"en" | "sw" | "luo">("en");
  const [languageSaving, setLanguageSaving] = useState(false);
  const [languageSuccess, setLanguageSuccess] = useState(false);
  const [languageError, setLanguageError] = useState<string | null>(null);

  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("access");
    if (!token) {
      navigate("/login");
      return;
    }

    const fetchSettingsData = async () => {
      try {
        setLoading(true);
        setError(null);

        // Fetch user name from dashboard (same as History page)
        // Fetch current language + other profile data from dedicated profile endpoint
        const [dashboardRes, profileRes] = await Promise.all([
          API.get("/dashboard/"),
          API.get("/profile/"),          // ← Backend must return { preferred_language: "en" | "sw" | "luo", ... }
        ]);

        setUserName(dashboardRes.data.user || "User");

        // Set the language that is already saved in the database
        const savedLang = profileRes.data.preferred_language || "en";
        setPreferredLanguage(savedLang as "en" | "sw" | "luo");

      } catch (err: any) {
        console.error("Settings fetch error:", err);
        if (err.response?.status === 401) {
          localStorage.removeItem("access");
          localStorage.removeItem("refresh");
          navigate("/login");
        } else {
          setError("Failed to load settings.");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchSettingsData();
  }, [navigate]);

  const handleLogout = () => {
    if (window.confirm("Are you sure you want to log out?")) {
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      navigate("/login");
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordError(null);
    setPasswordSuccess(false);

    if (newPassword !== confirmPassword) {
      setPasswordError("New passwords do not match.");
      return;
    }
    if (newPassword.length < 8) {
      setPasswordError("New password must be at least 8 characters long.");
      return;
    }

    setPasswordLoading(true);

    try {
      // Real backend call – password is saved to database here
      await API.post("/change-password/", {
        current_password: currentPassword,
        new_password: newPassword,
      });

      setPasswordSuccess(true);
      // Clear form
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
    } catch (err: any) {
      console.error("Password change error:", err);
      setPasswordError(
        err.response?.data?.detail ||
        err.response?.data?.current_password?.[0] ||
        "Failed to change password. Please check your current password."
      );
    } finally {
      setPasswordLoading(false);
    }
  };

  const handleSaveLanguage = async () => {
    setLanguageError(null);
    setLanguageSuccess(false);
    setLanguageSaving(true);

    try {
      // Real backend call – language is saved to database here
      await API.patch("/profile/", {
        preferred_language: preferredLanguage,
      });

      setLanguageSuccess(true);

      // Optional: You can also store it in localStorage for instant use across the app
      // localStorage.setItem("preferred_language", preferredLanguage);
    } catch (err: any) {
      console.error("Language save error:", err);
      setLanguageError(
        err.response?.data?.detail || "Failed to save language preference."
      );
    } finally {
      setLanguageSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f6f8f6] dark:bg-[#141e14]">
        <div className="text-center">
          <div className="material-symbols-outlined text-6xl text-[#3cbe45] animate-spin">
            hourglass_top
          </div>
          <p className="mt-4 text-slate-600 dark:text-slate-400">Loading settings...</p>
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

      {/* Sidebar (identical to History page) */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 w-64 transform transition-transform duration-300 lg:relative lg:translate-x-0
          ${sidebarOpen ? "translate-x-0" : "-translate-x-full"}
          border-r border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 flex flex-col`}
      >
        <div className="flex flex-col gap-8 p-6">
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

          <nav className="flex flex-col gap-2">
            <a href="/dashboard" className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors">
              <span className="material-symbols-outlined">dashboard</span>
              <span className="text-sm font-medium">Dashboard</span>
            </a>
            <a href="/scan" className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors">
              <span className="material-symbols-outlined">document_scanner</span>
              <span className="text-sm font-medium">Scan Crop</span>
            </a>
            <a href="/history" className="flex items-center gap-3 rounded-lg px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-[#3cbe45]/5 transition-colors">
              <span className="material-symbols-outlined">history</span>
              <span className="text-sm font-medium">History</span>
            </a>
            <a href="/settings" className="flex items-center gap-3 rounded-lg bg-[#3cbe45]/10 px-3 py-2 text-[#3cbe45]">
              <span className="material-symbols-outlined">settings</span>
              <span className="text-sm font-medium">Settings</span>
            </a>
          </nav>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex flex-1 flex-col overflow-y-auto">
        <header className="flex h-16 items-center justify-between border-b border-[#3cbe45]/10 bg-white/80 dark:bg-[#141e14]/80 px-4 sm:px-6 lg:px-8 backdrop-blur-md">
          <div className="flex items-center gap-3 lg:hidden">
            <button onClick={() => setSidebarOpen(true)}>
              <span className="material-symbols-outlined text-2xl text-slate-600 dark:text-slate-400">menu</span>
            </button>
            <h2 className="text-lg font-bold">Settings</h2>
          </div>

          <div className="hidden lg:block">
            <h2 className="text-lg font-bold">Settings</h2>
          </div>

          <div className="flex items-center gap-3 sm:gap-6">
            <div className="text-right hidden sm:block">
              <p className="text-xs font-bold">{userName}</p>
              <p className="text-[10px] text-slate-500">Agronomist</p>
            </div>
            <img
              alt="Profile"
              className="h-8 w-8 sm:h-9 sm:w-9 rounded-full object-cover ring-2 ring-[#3cbe45]/20"
              src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80"
            />
            <button
              onClick={handleLogout}
              className="text-sm text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
            >
              Logout
            </button>
          </div>
        </header>

        {/* Settings Content */}
        <div className="p-4 sm:p-6 lg:p-8 max-w-3xl">
          <h3 className="mb-8 text-xl sm:text-2xl font-bold">Account Settings</h3>

          {/* Change Password */}
          <div className="mb-12 rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 p-6 shadow-sm">
            <h4 className="mb-6 text-lg font-bold flex items-center gap-2">
              <span className="material-symbols-outlined text-[#3cbe45]">lock</span>
              Change Password
            </h4>

            <form onSubmit={handleChangePassword} className="space-y-5">
              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1.5">Current Password</label>
                <input
                  type="password"
                  value={currentPassword}
                  onChange={(e) => setCurrentPassword(e.target.value)}
                  className="w-full rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-4 py-2.5 text-sm focus:border-[#3cbe45] focus:ring-2 focus:ring-[#3cbe45]/30"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1.5">New Password</label>
                <input
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  className="w-full rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-4 py-2.5 text-sm focus:border-[#3cbe45] focus:ring-2 focus:ring-[#3cbe45]/30"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1.5">Confirm New Password</label>
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="w-full rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-4 py-2.5 text-sm focus:border-[#3cbe45] focus:ring-2 focus:ring-[#3cbe45]/30"
                  required
                />
              </div>

              {passwordError && <p className="text-sm text-red-600">{passwordError}</p>}
              {passwordSuccess && <p className="text-sm text-[#3cbe45] font-medium">Password changed successfully!</p>}

              <div className="flex justify-end">
                <button
                  type="submit"
                  disabled={passwordLoading}
                  className={`px-6 py-2.5 rounded-lg font-medium text-white flex items-center gap-2 transition-all ${
                    passwordLoading ? "bg-[#35a93d] cursor-not-allowed" : "bg-[#3cbe45] hover:bg-[#35a93d]"
                  }`}
                >
                  {passwordLoading ? (
                    <>
                      <span className="material-symbols-outlined animate-spin">hourglass_top</span>
                      Saving...
                    </>
                  ) : (
                    "Update Password"
                  )}
                </button>
              </div>
            </form>
          </div>

          {/* Preferred Language */}
          <div className="rounded-xl border border-[#3cbe45]/10 bg-white dark:bg-[#141e14]/50 p-6 shadow-sm">
            <h4 className="mb-6 text-lg font-bold flex items-center gap-2">
              <span className="material-symbols-outlined text-[#3cbe45]">language</span>
              Preferred Language
            </h4>

            <div className="space-y-4">
              <select
                value={preferredLanguage}
                onChange={(e) => setPreferredLanguage(e.target.value as "en" | "sw" | "luo")}
                className="w-full max-w-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-4 py-2.5 text-sm focus:border-[#3cbe45] focus:ring-2 focus:ring-[#3cbe45]/30"
              >
                <option value="en">English</option>
                <option value="sw">Kiswahili</option>
                <option value="luo">Dholuo</option>
              </select>

              {languageError && <p className="text-sm text-red-600">{languageError}</p>}
              {languageSuccess && (
                <p className="text-sm text-[#3cbe45] font-medium">
                  Language preference saved! (Future pages will respond in {preferredLanguage === "sw" ? "Kiswahili" : preferredLanguage === "luo" ? "Dholuo" : "English"})
                </p>
              )}

              <div className="flex justify-end">
                <button
                  onClick={handleSaveLanguage}
                  disabled={languageSaving}
                  className={`px-6 py-2.5 rounded-lg font-medium text-white flex items-center gap-2 transition-all ${
                    languageSaving ? "bg-[#35a93d] cursor-not-allowed" : "bg-[#3cbe45] hover:bg-[#35a93d]"
                  }`}
                >
                  {languageSaving ? (
                    <>
                      <span className="material-symbols-outlined animate-spin">hourglass_top</span>
                      Saving...
                    </>
                  ) : (
                    "Save Preference"
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}