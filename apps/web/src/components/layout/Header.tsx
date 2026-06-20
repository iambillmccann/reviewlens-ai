import { Bell, Menu, Search, Settings, User, X } from 'lucide-react'
import { Link } from 'react-router-dom'

import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
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
        <h1 className="text-sm font-semibold tracking-wide text-foreground">Reviewlens-ai</h1>
      </div>
      <div className="flex items-center gap-1">
        <Button variant="ghost" size="icon" className="hidden sm:inline-flex" aria-label="Search">
          <Search className="size-4" />
        </Button>
        <Button variant="ghost" size="icon" className="hidden sm:inline-flex" aria-label="Notifications">
          <Bell className="size-4" />
        </Button>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="ml-2 size-10 rounded-full"
              aria-label="Open application menu"
            >
              <div className="flex size-8 items-center justify-center rounded-full border border-border/80 bg-muted">
                <User className="size-4 text-muted-foreground" aria-hidden="true" />
              </div>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-52" sideOffset={8}>
            <DropdownMenuLabel>Application menu</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem asChild>
              <Link to="/settings" className="flex items-center gap-2">
                <Settings className="size-4" />
                Settings
              </Link>
            </DropdownMenuItem>
            <DropdownMenuItem asChild>
              <Link to="/settings/account" className="flex items-center gap-2">
                <User className="size-4" />
                Account
              </Link>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
