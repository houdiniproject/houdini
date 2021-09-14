import { useEffect, useState } from "react";
import { NetworkError } from "../../api/errors";

export default function useIsReady(wasSubmitting: boolean, onFailure: (error: NetworkError) => void, failed: boolean, lastSignInAttemptError: NetworkError, submitting: boolean): boolean {
  const [state, setState] = useState(true);

  useEffect(() => {
    if (failed && wasSubmitting) {
      setState(true);
      onFailure(lastSignInAttemptError);
    } else if (submitting) {
      setState(false);
    }
  }, [failed, wasSubmitting, lastSignInAttemptError, onFailure, submitting, setState]);

  return state;
}