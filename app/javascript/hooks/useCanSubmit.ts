import { useEffect, useState } from "react";

export default function useCanSubmit(isValid: boolean, showProgressAndSuccess: boolean, formState: string): boolean {
  const [state, setState] = useState(false);

  useEffect(() => {
    if (isValid && formState == 'ready' && showProgressAndSuccess) {
      setState(true);
    } else {
      setState(false);
    }
  }, [isValid, showProgressAndSuccess, formState, state]);

  return state;
}
