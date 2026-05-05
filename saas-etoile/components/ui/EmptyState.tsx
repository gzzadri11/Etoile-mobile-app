export function EmptyState({ label = 'Aucun résultat.' }: { label?: string }) {
  return (
    <div className="flex flex-col items-center justify-center p-12 text-center">
      <div className="mb-3 text-3xl">📭</div>
      <div className="text-sm text-text-tertiary">{label}</div>
    </div>
  )
}
