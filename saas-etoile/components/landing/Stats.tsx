export function Stats() {
  const stats = [
    { value: "< 30s", label: "Temps de prise en main" },
    { value: "40s", label: "Durée de présentation vidéo" },
    { value: "100%", label: "Recruteurs vérifiés SIRET" },
  ];

  return (
    <section className="bg-bg-subtle px-6 py-16">
      <div className="mx-auto max-w-5xl">
        <div className="grid grid-cols-1 divide-y divide-border md:grid-cols-3 md:divide-x md:divide-y-0">
          {stats.map((stat, i) => (
            <div key={i} className="py-8 text-center md:py-0">
              <div className="text-4xl font-bold text-text-primary">{stat.value}</div>
              <div className="mt-2 text-sm text-text-secondary">{stat.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
