import { Progress } from "@/components/ui/progress";

interface ProfileProgressBarProps {
  completionPercentage: number;
}

export function ProfileProgressBar({ completionPercentage }: ProfileProgressBarProps) {
  const getColorClass = () => {
    if (completionPercentage === 100) return "text-green-600";
    if (completionPercentage >= 60) return "text-yellow-600";
    return "text-red-600";
  };

  const getProgressColorClass = () => {
    if (completionPercentage === 100) return "[&>div]:bg-green-600";
    if (completionPercentage >= 60) return "[&>div]:bg-yellow-600";
    return "[&>div]:bg-red-600";
  };

  return (
    <div className="sticky top-0 z-10 bg-background border-b p-4">
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <p className={`text-sm font-medium ${getColorClass()}`}>
            Complétude profil : {completionPercentage}%
          </p>
        </div>
        <Progress value={completionPercentage} className={getProgressColorClass()} />
      </div>
    </div>
  );
}
