export function LoadingSpinner() {
  return (
    <div className="flex items-center justify-center p-12">
      <div className="h-6 w-6 animate-spin rounded-full border-[2.5px] border-border border-t-accent" />
    </div>
  )
}
