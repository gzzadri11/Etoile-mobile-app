import { useEffect } from "react";

/**
 * Hook to register keyboard shortcuts
 *
 * @param shortcuts - Map of key to handler function
 * @param enabled - Whether shortcuts are active (default: true)
 *
 * @example
 * useKeyboardShortcuts({
 *   'ArrowRight': () => nextItem(),
 *   'ArrowLeft': () => prevItem(),
 *   ' ': () => togglePlay(),
 *   'c': () => contact(),
 * }, isModalOpen);
 */
export function useKeyboardShortcuts(
  shortcuts: Record<string, () => void>,
  enabled: boolean = true
) {
  useEffect(() => {
    if (!enabled) return;

    function handleKeyDown(e: KeyboardEvent) {
      // Ignore if typing in input/textarea
      if (
        e.target instanceof HTMLInputElement ||
        e.target instanceof HTMLTextAreaElement
      ) {
        return;
      }

      const handler = shortcuts[e.key];
      if (handler) {
        e.preventDefault();
        handler();
      }
    }

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [shortcuts, enabled]);
}
