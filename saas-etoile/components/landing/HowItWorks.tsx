export function HowItWorks() {
  const steps = [
    {
      number: "1",
      title: "Créez votre compte",
      description:
        "Inscription en 2 minutes avec vérification SIRET. Gratuit, sans engagement.",
    },
    {
      number: "2",
      title: "Publiez votre offre",
      description:
        "Décrivez votre poste en alternance. Ajoutez une vidéo ou une affiche pour attirer les talents.",
    },
    {
      number: "3",
      title: "Pré-sélectionnez",
      description:
        "Recevez les candidatures vidéo. Shortlistez en un clic. Contactez directement.",
    },
  ];

  return (
    <section id="how-it-works" className="scroll-mt-16 bg-bg-subtle px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <div className="mb-16 text-center">
          <h2 className="heading-lg mb-4 text-text-primary">
            Comment ça marche ?
          </h2>
          <p className="body-lg text-text-secondary">
            Trois étapes pour transformer votre recrutement
          </p>
        </div>

        <div className="grid gap-12 md:grid-cols-3">
          {steps.map((step, i) => (
            <div key={i} className="text-center">
              <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-accent text-2xl font-bold text-white">
                {step.number}
              </div>
              <h3 className="mb-3 text-xl font-semibold text-text-primary">
                {step.title}
              </h3>
              <p className="text-sm leading-relaxed text-text-secondary">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
