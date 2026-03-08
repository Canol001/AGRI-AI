import axios from "axios";

// Create an axios instance
const API = axios.create({
  // baseURL: "http://127.0.0.1:8000/api/",
  baseURL: "https://agri-ai-7fnp.onrender.com/api/",
  headers: {
    "Content-Type": "application/json",
  },
});

// Attach token from localStorage automatically
API.interceptors.request.use((req) => {
  // Prefer access token if using JWT
  const token = localStorage.getItem("access"); // access token
  if (token) {
    req.headers.Authorization = `Bearer ${token}`;
  }
  return req;
}, (error) => {
  return Promise.reject(error);
});

// Optional: Response interceptor for handling 401 globally
API.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Token expired or invalid
      localStorage.removeItem("access");
      localStorage.removeItem("refresh");
      // Optionally redirect to login page
      window.location.href = "/";
    }
    return Promise.reject(error);
  }
);

export default API;