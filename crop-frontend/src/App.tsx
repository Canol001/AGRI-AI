import {BrowserRouter,Routes,Route} from "react-router-dom"
import ProtectedRoute from "./components/ProtectedRoute";

import Home from "./pages/Home"
import Login from "./pages/Login"
import Register from "./pages/Register"
import Dashboard from "./pages/Dashboard"
import Scan from "./pages/Scan"
import History from "./pages/History"

function App(){

return(

<BrowserRouter>

<Routes>

<Route path="/" element={<Home/>}/>
<Route path="/login" element={<Login/>}/>
<Route path="/register" element={<Register/>}/>
<Route
  path="/dashboard"
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  }
/>
<Route path="/scan" element={<Scan/>}/>
<Route path="/history" element={<History/>}/>

</Routes>

</BrowserRouter>

)

}

export default App