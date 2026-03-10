import { Leaf, Users, BarChart3, ShieldCheck, Edit, Trash2, Plus, LogOut, Settings, Activity, Database } from 'lucide-react';
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../api/api';  // your axios instance

export default function AdminDashboard() {
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Stats from /administrator/
  const [stats, setStats] = useState<any>(null);

  // Users list from /admin/users/
  const [users, setUsers] = useState<any[]>([]);

  // Add/Edit modal state
  const [isAdding, setIsAdding] = useState(false);
  const [selectedUser, setSelectedUser] = useState<any | null>(null);
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    is_staff: false,
  });

  useEffect(() => {
    const token = localStorage.getItem('access');
    if (!token) {
      navigate('/login');
      return;
    }

    const fetchAdminData = async () => {
      try {
        setLoading(true);
        setError(null);

        const [statsRes, usersRes] = await Promise.all([
          API.get('/administrator/'),
          API.get('/admin/users/'),  // ← new endpoint you need to create
        ]);

        setStats(statsRes.data);
        setUsers(usersRes.data || []);

      } catch (err: any) {
        console.error('Admin fetch error:', err);
        if (err.response?.status === 401) {
          localStorage.removeItem('access');
          localStorage.removeItem('refresh');
          navigate('/login');
        } else {
          setError(err.response?.data?.error || 'Failed to load admin dashboard');
        }
      } finally {
        setLoading(false);
      }
    };

    fetchAdminData();
  }, [navigate]);

  // Add new user
  const handleAddUser = async () => {
    if (!formData.username || !formData.email || !formData.password) {
      alert('Please fill username, email, and password');
      return;
    }

    try {
      const res = await API.post('/admin/users/', {
        username: formData.username,
        email: formData.email,
        password: formData.password,
        is_staff: formData.is_staff,
      });

      setUsers([...users, res.data]);
      setIsAdding(false);
      setFormData({ username: '', email: '', password: '', is_staff: false });
      alert('User created successfully');
    } catch (err: any) {
      alert(err.response?.data?.error || 'Failed to create user');
    }
  };

  // Edit existing user
  const handleEditUser = async () => {
    if (!selectedUser) return;

    try {
      const payload: any = {
        username: formData.username,
        email: formData.email,
        is_staff: formData.is_staff,
      };
      // Only send password if changed
      if (formData.password) payload.password = formData.password;

      const res = await API.patch(`/admin/users/${selectedUser.id}/`, payload);

      setUsers(users.map(u => (u.id === selectedUser.id ? res.data : u)));
      setSelectedUser(null);
      setFormData({ username: '', email: '', password: '', is_staff: false });
      alert('User updated successfully');
    } catch (err: any) {
      alert(err.response?.data?.error || 'Failed to update user');
    }
  };

  // Delete user
  const handleDeleteUser = async (id: number) => {
    if (!window.confirm('Delete this user permanently?')) return;

    try {
      await API.delete(`/admin/users/${id}/`);
      setUsers(users.filter(u => u.id !== id));
      alert('User deleted');
    } catch (err: any) {
      alert(err.response?.data?.error || 'Failed to delete user');
    }
  };

  const openEditModal = (user: any) => {
    setSelectedUser(user);
    setFormData({
      username: user.username,
      email: user.email,
      password: '',
      is_staff: user.is_staff,
    });
    setIsAdding(false);
  };

  const handleLogout = () => {
    if (window.confirm('Log out from admin panel?')) {
      localStorage.removeItem('access');
      localStorage.removeItem('refresh');
      navigate('/login');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-emerald-50 to-green-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-emerald-600 mx-auto"></div>
          <p className="mt-4 text-lg text-emerald-700">Loading admin dashboard...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-emerald-50 to-green-50">
        <div className="text-center max-w-md p-8 bg-white rounded-2xl shadow-xl">
          <p className="text-2xl font-bold text-red-600 mb-4">Error</p>
          <p className="text-gray-700 mb-6">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-8 py-3 bg-emerald-600 text-white rounded-xl hover:bg-emerald-700"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-green-50 font-sans antialiased">
      {/* Sidebar - same as before */}
      <aside className="fixed top-0 left-0 w-64 h-screen bg-white shadow-xl border-r border-emerald-100 hidden md:block">
        <div className="p-6 flex items-center gap-3 border-b">
          <Leaf className="h-8 w-8 text-emerald-600" />
          <span className="text-2xl font-bold text-green-800">CropGuard Admin</span>
        </div>
        <nav className="p-4 space-y-2">
          <a href="#dashboard" className="flex items-center gap-3 px-4 py-3 rounded-lg bg-emerald-50 text-emerald-800 font-medium">
            <BarChart3 className="h-5 w-5" /> Dashboard
          </a>
          <a href="#users" className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-emerald-50 text-green-800 font-medium">
            <Users className="h-5 w-5" /> Users
          </a>
          <a href="#activity" className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-emerald-50 text-green-800 font-medium">
            <Activity className="h-5 w-5" /> Activity Logs
          </a>
          <a href="#settings" className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-emerald-50 text-green-800 font-medium">
            <Settings className="h-5 w-5" /> Settings
          </a>
          <a href="#data" className="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-emerald-50 text-green-800 font-medium">
            <Database className="h-5 w-5" /> Data Export
          </a>
        </nav>
        <div className="absolute bottom-0 w-full p-4 border-t">
          <button 
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-red-50 text-red-600 font-medium"
          >
            <LogOut className="h-5 w-5" /> Log Out
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="md:ml-64 p-6 md:p-10">
        {/* Dashboard Stats */}
        <section id="dashboard" className="mb-12">
          <h1 className="text-3xl md:text-4xl font-bold text-green-900 mb-8">Admin Dashboard</h1>
          {stats && (
            <div className="grid md:grid-cols-4 gap-6">
              <div className="bg-white p-6 rounded-2xl shadow-md border border-emerald-100">
                <Users className="h-10 w-10 text-emerald-600 mb-4" />
                <div className="text-3xl font-bold text-green-800">{stats.system_overview.total_users}</div>
                <p className="text-gray-600">Total Users</p>
              </div>
              <div className="bg-white p-6 rounded-2xl shadow-md border border-emerald-100">
                <BarChart3 className="h-10 w-10 text-emerald-600 mb-4" />
                <div className="text-3xl font-bold text-green-800">{stats.system_overview.total_scans}</div>
                <p className="text-gray-600">Total Detections</p>
              </div>
              <div className="bg-white p-6 rounded-2xl shadow-md border border-emerald-100">
                <Activity className="h-10 w-10 text-emerald-600 mb-4" />
                <div className="text-3xl font-bold text-green-800">{stats.system_overview.active_users_30d}</div>
                <p className="text-gray-600">Active Users (30d)</p>
              </div>
              <div className="bg-white p-6 rounded-2xl shadow-md border border-emerald-100">
                <ShieldCheck className="h-10 w-10 text-emerald-600 mb-4" />
                <div className="text-3xl font-bold text-green-800">{stats.system_overview.average_confidence}%</div>
                <p className="text-gray-600">Avg Confidence</p>
              </div>
            </div>
          )}
        </section>

        {/* Users Management */}
        <section id="users" className="mb-12">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-green-900">Registered Users</h2>
            <button
              onClick={() => {
                setIsAdding(true);
                setSelectedUser(null);
                setFormData({ username: '', email: '', password: '', is_staff: false });
              }}
              className="flex items-center gap-2 bg-emerald-600 text-white px-6 py-3 rounded-xl font-semibold hover:bg-emerald-700 transition"
            >
              <Plus className="h-5 w-5" /> Add User
            </button>
          </div>

          <div className="overflow-x-auto bg-white rounded-2xl shadow-md border border-emerald-100">
            <table className="min-w-full divide-y divide-emerald-100">
              <thead className="bg-emerald-50">
                <tr>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-green-800">Username</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-green-800">Email</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-green-800">Role</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-green-800">Joined</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-green-800">Scans</th>
                  <th className="px-6 py-3 text-left text-sm font-semibold text-green-800">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-emerald-100">
                {users.map((user) => (
                  <tr key={user.id} className="hover:bg-emerald-50">
                    <td className="px-6 py-4 text-sm font-medium text-gray-900">{user.username}</td>
                    <td className="px-6 py-4 text-sm text-gray-700">{user.email}</td>
                    <td className="px-6 py-4 text-sm text-gray-700">
                      <span className={`inline-block px-2 py-1 rounded-full text-xs font-medium ${user.is_staff ? 'bg-emerald-100 text-emerald-800' : 'bg-gray-100 text-gray-800'}`}>
                        {user.is_staff ? 'Admin' : 'User'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-700">
                      {new Date(user.date_joined).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-700">{user.scans_count ?? '—'}</td>
                    <td className="px-6 py-4 flex gap-3">
                      <button
                        onClick={() => openEditModal(user)}
                        className="text-emerald-600 hover:text-emerald-800 transition"
                      >
                        <Edit className="h-5 w-5" />
                      </button>
                      <button
                        onClick={() => handleDeleteUser(user.id)}
                        className="text-red-600 hover:text-red-800 transition"
                      >
                        <Trash2 className="h-5 w-5" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Add/Edit Modal */}
          {(isAdding || selectedUser) && (
            <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
              <div className="bg-white rounded-2xl shadow-2xl max-w-lg w-full p-8">
                <h3 className="text-2xl font-bold text-green-900 mb-6">
                  {isAdding ? 'Create New User' : `Edit ${selectedUser?.username}`}
                </h3>

                <div className="space-y-5">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Username</label>
                    <input
                      type="text"
                      value={formData.username}
                      onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                      className="w-full p-3 border border-emerald-200 rounded-xl focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200/50"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input
                      type="email"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      className="w-full p-3 border border-emerald-200 rounded-xl focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200/50"
                      required
                    />
                  </div>

                  {isAdding && (
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
                      <input
                        type="password"
                        value={formData.password}
                        onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                        className="w-full p-3 border border-emerald-200 rounded-xl focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200/50"
                        required
                      />
                    </div>
                  )}

                  <div className="flex items-center gap-3">
                    <input
                      type="checkbox"
                      id="is_staff"
                      checked={formData.is_staff}
                      onChange={(e) => setFormData({ ...formData, is_staff: e.target.checked })}
                      className="h-5 w-5 text-emerald-600 rounded"
                    />
                    <label htmlFor="is_staff" className="text-green-800 font-medium">
                      Grant Admin Privileges (is_staff)
                    </label>
                  </div>
                </div>

                <div className="mt-8 flex justify-end gap-4">
                  <button
                    onClick={() => {
                      setIsAdding(false);
                      setSelectedUser(null);
                    }}
                    className="px-6 py-3 rounded-xl text-gray-700 hover:bg-gray-100 transition"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={isAdding ? handleAddUser : handleEditUser}
                    className="px-8 py-3 bg-emerald-600 text-white rounded-xl font-semibold hover:bg-emerald-700 transition shadow-md"
                  >
                    {isAdding ? 'Create User' : 'Save Changes'}
                  </button>
                </div>
              </div>
            </div>
          )}
        </section>

        {/* Other sections (placeholders) */}
        <section id="activity" className="mb-12">
          <h2 className="text-2xl font-bold text-green-900 mb-6">Recent Activity</h2>
          <div className="bg-white p-6 rounded-2xl shadow-md border border-emerald-100">
            <p className="text-gray-600">Activity logs (logins, scans, model updates) will appear here.</p>
          </div>
        </section>

        <section id="data">
          <h2 className="text-2xl font-bold text-green-900 mb-6">Export & Backup</h2>
          <div className="bg-white p-6 rounded-2xl shadow-md border border-emerald-100">
            <button className="flex items-center gap-2 bg-emerald-600 text-white px-6 py-3 rounded-xl font-semibold hover:bg-emerald-700 transition">
              <Database className="h-5 w-5" /> Export All Data (CSV/JSON)
            </button>
            <p className="mt-4 text-gray-600">Backup scans, users, and recommendations.</p>
          </div>
        </section>
      </main>
    </div>
  );
}