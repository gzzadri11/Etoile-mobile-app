export function PageHeader({
  title,
  children,
}: {
  title: string;
  children?: React.ReactNode;
}) {
  return (
    <div className="sticky top-0 z-30 flex h-14 items-center justify-between border-b border-border bg-white px-8">
      <h1 className="text-xl font-bold text-text-primary">{title}</h1>
      {children && <div className="flex items-center gap-3">{children}</div>}
    </div>
  );
}
