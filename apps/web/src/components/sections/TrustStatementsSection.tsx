import { Card, CardContent } from '@/components/ui/card';
import { ShieldCheck, Target, Lock } from 'lucide-react';

interface TrustStatement {
  icon: React.ComponentType<{ className?: string }>;
  title: string;
  description: string;
}

const trustStatements: TrustStatement[] = [
  {
    icon: ShieldCheck,
    title: 'Evidence-backed answers',
    description: 'Every answer is supported by real reviews.',
  },
  {
    icon: Target,
    title: 'Scope you can trust',
    description: 'AI answers only from the selected dataset.',
  },
  {
    icon: Lock,
    title: 'Your data stays public',
    description: 'We only read publicly available reviews.',
  },
];

export function TrustStatementsSection() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full">
      {trustStatements.map((statement, index) => {
        const Icon = statement.icon;
        return (
          <Card key={index} className="text-center">
            <CardContent className="pt-6">
              <div className="flex justify-center mb-4">
                <Icon className="h-8 w-8 text-primary" />
              </div>
              <h3 className="font-semibold mb-2">{statement.title}</h3>
              <p className="text-sm text-muted-foreground">
                {statement.description}
              </p>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
