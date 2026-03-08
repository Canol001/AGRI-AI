import { useState } from "react";
import API from "../api/api";
import { useNavigate } from "react-router-dom";

export default function Register() {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const res = await API.post("register/", {
        username,
        email,
        password,
      });

      localStorage.setItem("token", res.data.token);
      navigate("/dashboard");
    } catch (err) {
      alert("Registration failed");
      // Consider showing better error feedback later (e.g. field-specific messages)
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        {/* Header / Title */}
        <div className="text-center">
          <h2 className="mt-6 text-3xl font-bold tracking-tight text-gray-900">
            Create your account
          </h2>
          <p className="mt-2 text-sm text-gray-600">
            Join us and start managing your projects
          </p>
        </div>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-xl sm:rounded-lg sm:px-10 border border-gray-200">
          <form className="space-y-6" onSubmit={handleSubmit}>
            {/* Username field */}
            <div>
              <label
                htmlFor="username"
                className="block text-sm font-medium text-gray-700"
              >
                Username
              </label>
              <div className="mt-1">
                <input
                  id="username"
                  name="username"
                  type="text"
                  autoComplete="username"
                  required
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className="
                    block w-full rounded-md border-0 py-2.5 px-3
                    text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300
                    placeholder:text-gray-400 focus:ring-2 focus:ring-inset
                    focus:ring-indigo-600 sm:text-sm sm:leading-6
                    transition-colors duration-200
                  "
                  placeholder="Choose a username"
                />
              </div>
            </div>

            {/* Email field */}
            <div>
              <label
                htmlFor="email"
                className="block text-sm font-medium text-gray-700"
              >
                Email address
              </label>
              <div className="mt-1">
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="
                    block w-full rounded-md border-0 py-2.5 px-3
                    text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300
                    placeholder:text-gray-400 focus:ring-2 focus:ring-inset
                    focus:ring-indigo-600 sm:text-sm sm:leading-6
                    transition-colors duration-200
                  "
                  placeholder="you@example.com"
                />
              </div>
            </div>

            {/* Password field */}
            <div>
              <label
                htmlFor="password"
                className="block text-sm font-medium text-gray-700"
              >
                Password
              </label>
              <div className="mt-1">
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="
                    block w-full rounded-md border-0 py-2.5 px-3
                    text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300
                    placeholder:text-gray-400 focus:ring-2 focus:ring-inset
                    focus:ring-indigo-600 sm:text-sm sm:leading-6
                    transition-colors duration-200
                  "
                  placeholder="••••••••"
                />
              </div>
            </div>

            {/* Submit button */}
            <div>
              <button
                type="submit"
                className="
                  w-full flex justify-center rounded-md bg-indigo-600
                  px-4 py-2.5 text-sm font-semibold text-white shadow-sm
                  hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2
                  focus-visible:outline-offset-2 focus-visible:outline-indigo-600
                  transition-all duration-200 active:scale-[0.98]
                "
              >
                Create account
              </button>
            </div>
          </form>

          {/* Footer link to login */}
          <div className="mt-6 text-center text-sm">
            <p className="text-gray-600">
              Already have an account?{" "}
              <a
                href="/login"
                className="font-medium text-indigo-600 hover:text-indigo-500"
              >
                Sign in
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}