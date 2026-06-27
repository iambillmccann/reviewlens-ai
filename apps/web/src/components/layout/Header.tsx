import { Bell, Menu, Search, X } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'

interface HeaderProps extends React.HTMLAttributes<HTMLElement> {
  isSidebarOpen?: boolean
  onMenuToggle?: () => void
}

export function Header({
  className,
  isSidebarOpen = false,
  onMenuToggle,
  ...props
}: HeaderProps) {
  return (
    <header
      className={cn(
        'flex h-14 shrink-0 items-center justify-between border border-border bg-background px-4',
        className
      )}
      {...props}
    >
      <div className="flex items-center gap-2">
        <Button
          variant="ghost"
          size="icon"
          className="md:hidden"
          aria-label={isSidebarOpen ? 'Close navigation menu' : 'Open navigation menu'}
          aria-expanded={isSidebarOpen}
          onClick={onMenuToggle}
        >
          {isSidebarOpen ? <X className="size-4" /> : <Menu className="size-4" />}
        </Button>
        <div className="size-7 rounded-md bg-primary/10" aria-hidden="true" />
        <h1 className="text-sm font-semibold tracking-wide text-foreground">ReviewLens AI</h1>
      </div>
      <div className="flex items-center gap-1">
        <Button variant="ghost" size="icon" className="hidden sm:inline-flex" aria-label="Search">
          <Search className="size-4" />
        </Button>
        <Button variant="ghost" size="icon" className="hidden sm:inline-flex" aria-label="Notifications">
          <Bell className="size-4" />
        </Button>
      </div>
    </header>
  )
}
