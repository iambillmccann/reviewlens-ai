import { Outlet } from 'react-router-dom'

import { useTheme } from '@/lib/theme'
import { Header } from './Header'

export interface LayoutProps {
  children?: React.ReactNode
}

export function Layout({ children }: LayoutProps) {
  // Initialize theme infrastructure based on system preference
  useTheme()

  return (
    <div className="flex h-screen flex-col overflow-hidden bg-background text-foreground">
      {/* Fixed-height top header */}
      <Header />

      {/* Main content fills remaining height */}
      <main className="flex-1 overflow-y-auto bg-background">
        {children || <Outlet />}
      </main>
    </div>
  )
}

