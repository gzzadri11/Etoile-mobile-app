export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-muted px-4">
      <div className="mb-8 flex flex-col items-center gap-2">
        <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary">
          <span className="text-2xl font-bold text-primary-foreground">E</span>
        </div>
        <h1 className="text-xl font-semibold text-foreground">
          Etoile Recruteurs
        </h1>
      </div>
      <div className="w-full max-w-md">{children}</div>
    </div>
  );
}
