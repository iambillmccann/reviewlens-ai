import { BrowserRouter, Routes, Route } from 'react-router-dom'

import { useTheme } from '@/lib/theme'
import { Layout } from '@/components/layout/Layout'
import { Home } from '@/components/pages/Home'

export default function App() {
  useTheme()

  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Home />} />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}