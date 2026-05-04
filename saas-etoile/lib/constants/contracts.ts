export const CONTRACT_TYPES = [
  { value: "alternance", label: "Alternance" },
  { value: "stage", label: "Stage" },
  { value: "professionnalisation", label: "Professionnalisation" },
] as const;

export function getContractTypeLabel(code: string | null): string {
  if (!code) return "Non défini";
  return CONTRACT_TYPES.find((c) => c.value === code)?.label ?? code;
}
