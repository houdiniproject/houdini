import { useEffect, useState } from "react";
import { NetworkError } from "../api/errors";
import useCurrentUserAuth from "./useCurrentUserAuth";

export default function useIsReady(wasSubmitting: boolean, onFailure: (error: NetworkError) => void): boolean {
  const [state, setState] = useState(true);
  const { lastSignInAttemptError, failed } = useCurrentUserAuth();

  useEffect(() => {
    if (failed && wasSubmitting) {
      setState(true);
      onFailure(lastSignInAttemptError);
    }
  }, [failed, wasSubmitting, lastSignInAttemptError, onFailure, setState]);

  return state;
}