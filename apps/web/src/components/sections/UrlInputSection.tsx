import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from 'sonner';

export function UrlInputSection() {
  const [url, setUrl] = useState('');

  const handleAnalyzeClick = () => {
    toast.success('Analysis requested! (feature coming soon)');
  };

  return (
    <div className="max-w-xl mx-auto space-y-3 w-full">
      <div className="flex gap-2 flex-col sm:flex-row">
        <Input
          placeholder="Paste a Google Maps business URL"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          className="flex-1"
        />
        <Button onClick={handleAnalyzeClick} className="w-full sm:w-auto">
          Analyze Reviews
        </Button>
      </div>
      <p className="text-sm text-muted-foreground text-center">
        Supported platforms: Google Maps, Amazon, G2, Capterra, or similar
        publicly accessible review sites.
      </p>
    </div>
  );
}
