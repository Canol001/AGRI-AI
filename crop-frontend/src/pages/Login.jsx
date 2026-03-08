import { useState } from "react";
import API from "../api/api";
import { useNavigate } from "react-router-dom";

export default function Login() {

  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  const handleSubmit = async (e) => {
  e.preventDefault();

  try {
    const res = await API.post("login/", {
      username,
      password,
    });

    const accessToken = res.data.access;
    const refreshToken = res.data.refresh;

    if (!accessToken) {
      alert("Login failed: no access token returned");
      return;
    }

    // Save tokens
    localStorage.setItem("access", accessToken);
    localStorage.setItem("refresh", refreshToken);

    // Set axios default header for future requests
    API.defaults.headers.common["Authorization"] = `Bearer ${accessToken}`;

    navigate("/dashboard");

  } catch (err) {
    alert("Login failed");
    console.error(err);
  }
};


  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">

      <div className="sm:mx-auto sm:w-full sm:max-w-md">

        <div className="text-center">
          <h2 className="mt-6 text-3xl font-bold text-gray-900">
            Welcome back
          </h2>

          <p className="mt-2 text-sm text-gray-600">
            Sign in to your account
          </p>
        </div>

      </div>


      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">

        <div className="bg-white py-8 px-6 shadow-xl sm:rounded-lg border border-gray-200">

          <form className="space-y-6" onSubmit={handleSubmit}>

            {/* Username */}
            <div>

              <label className="block text-sm font-medium text-gray-700">
                Username
              </label>

              <input
                type="text"
                required
                value={username}
                onChange={(e)=>setUsername(e.target.value)}
                placeholder="Enter your username"
                className="
                mt-1 block w-full rounded-md border-0 py-2.5 px-3
                text-gray-900 shadow-sm ring-1 ring-gray-300
                focus:ring-2 focus:ring-indigo-600
                sm:text-sm
                "
              />

            </div>


            {/* Password */}
            <div>

              <label className="block text-sm font-medium text-gray-700">
                Password
              </label>

              <input
                type="password"
                required
                value={password}
                onChange={(e)=>setPassword(e.target.value)}
                placeholder="••••••••"
                className="
                mt-1 block w-full rounded-md border-0 py-2.5 px-3
                text-gray-900 shadow-sm ring-1 ring-gray-300
                focus:ring-2 focus:ring-indigo-600
                sm:text-sm
                "
              />

            </div>


            {/* Button */}
            <div>

              <button
                type="submit"
                disabled={loading}
                className="
                w-full flex justify-center rounded-md bg-indigo-600
                px-4 py-2.5 text-sm font-semibold text-white shadow-sm
                hover:bg-indigo-500 transition
                "
              >

                {loading ? "Signing in..." : "Sign in"}

              </button>

            </div>

          </form>


          <div className="mt-6 text-center text-sm">

            <p className="text-gray-600">
              Don't have an account?{" "}
              <a
                href="/register"
                className="font-medium text-indigo-600 hover:text-indigo-500"
              >
                Sign up
              </a>
            </p>

          </div>

        </div>

      </div>

    </div>
  );
}