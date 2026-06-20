import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'

export function Home() {
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-xl">Welcome to Reviewlens-ai</CardTitle>
          <CardDescription>
            A public review workspace ready for product-specific features.
          </CardDescription>
        </CardHeader>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Current State</CardTitle>
          <CardDescription>
            Authentication has been removed. The frontend now loads as a public application shell.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-2 text-sm text-muted-foreground">
          <p>The next implementation step is wiring Reviewlens-specific data and workflows into this shell.</p>
          <p>Use the Settings and Account pages as placeholders while the product surface is being rebuilt.</p>
        </CardContent>
      </Card>

      <div className="grid gap-4 lg:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Overview</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-28 rounded-md border border-dashed border-border bg-muted/40" />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-28 rounded-md border border-dashed border-border bg-muted/40" />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Insights</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-28 rounded-md border border-dashed border-border bg-muted/40" />
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
