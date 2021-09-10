// useState<'ready' | 'canSubmit' | 'submitting' | 'success'>
import { useEffect, useState } from "react";
import useCurrentUserAuth from "./useCurrentUserAuth";

export default function useIsSubmitting(onSubmitting: () => void, isValid: boolean): boolean {
  const [state, setState] = useState(false);
  const { submitting } = useCurrentUserAuth();

  useEffect(() => {
    if (isValid && submitting) {
      setState(true);
      onSubmitting();
    }
  }, [submitting, isValid, onSubmitting]);

  return state;
}