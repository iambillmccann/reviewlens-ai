import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'

export function Account() {
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-xl">Account</CardTitle>
          <CardDescription>
            Authentication is currently disabled for Reviewlens-ai.
          </CardDescription>
        </CardHeader>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Access Model</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2 text-sm">
            <p>
              <span className="font-medium text-foreground">Status:</span> Public access enabled
            </p>
            <p>
              <span className="font-medium text-foreground">Identity provider:</span> None configured
            </p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Next Step</CardTitle>
          <CardDescription>Use this page for product-level account preferences once they are implemented.</CardDescription>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          This route is available so the app shell remains stable while account management is being rebuilt.
        </CardContent>
      </Card>
    </div>
  )
}