import { cn } from '@/lib/utils'

export function Header({ className, ...props }: React.HTMLAttributes<HTMLElement>) {
  return (
    <header
      className={cn(
        'flex h-16 shrink-0 items-center justify-between border-b border-border bg-background px-6 lg:px-8',
        className
      )}
      {...props}
    >
      <h1 className="text-lg font-semibold tracking-tight text-foreground">
        ReviewLens AI
      </h1>
      <button
        className="text-sm text-muted-foreground hover:text-foreground transition-colors cursor-default"
        disabled
      >
        How it works
      </button>
    </header>
  )
}
