import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'

import { useTheme } from '@/lib/theme'
import { Layout } from '@/components/layout/Layout'
import { Account } from '@/components/pages/Account'
import { Home } from '@/components/pages/Home'
import { Settings } from '@/components/pages/Settings'

export default function App() {
  useTheme()

  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Home />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/settings/account" element={<Account />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}