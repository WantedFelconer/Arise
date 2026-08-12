import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'
import { BackendBridge } from './services/backendBridge'

// Initialize API interceptor bridging frontend to backend Express & AI services
BackendBridge.setupFetchInterceptor()

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)

