import { useEffect, useState } from "react";
import { NetworkError } from "../../api/errors";

export default function useIsReady(wasSubmitting: boolean, onFailure: (error: NetworkError) => void, failed: boolean, lastSignInAttemptError: NetworkError): boolean {
  const [state, setState] = useState(true);

  useEffect(() => {
    if (failed && wasSubmitting) {
      setState(true);
      onFailure(lastSignInAttemptError);
    }
  }, [failed, wasSubmitting, lastSignInAttemptError, onFailure, setState]);

  return state;
}