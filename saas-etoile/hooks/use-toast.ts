import * as React from "react"

type ToastVariant = "default" | "destructive"

export interface ToastProps {
  title?: string
  description?: string
  variant?: ToastVariant
}

// Simple toast implementation (MVP - no UI component needed for now)
// Toast notifications are logged to console for manual testing
export function useToast() {
  const toast = React.useCallback((props: ToastProps) => {
    // MVP: Log to console for manual testing
    // In production, this would show a UI toast component
    console.log(`[TOAST ${props.variant || "default"}]`, props.title, props.description)

    // Optional: Use browser notification API
    if (props.variant === "destructive") {
      console.error(props.title, props.description)
    } else {
      console.info(props.title, props.description)
    }
  }, [])

  return { toast }
}
