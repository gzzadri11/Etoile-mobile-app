export function ErrorState({ message }: { message: string }) {
  return (
    <div className="flex flex-col items-center justify-center p-12 text-center">
      <div className="mb-3 text-3xl">⚠️</div>
      <div className="mb-1 text-sm font-semibold text-text-primary">Erreur de chargement</div>
      <div className="text-xs text-text-tertiary">{message}</div>
    </div>
  )
}
