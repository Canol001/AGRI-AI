// src/components/ProtectedRoute.jsx
import React from "react";
import { Navigate } from "react-router-dom";

const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem("access"); // JWT token

  if (!token) {
    // If no token, redirect to login
    return <Navigate to="/login" replace />;
  }

  // Else, render the child component
  return children;
};

export default ProtectedRoute;