// useState<'ready' | 'canSubmit' | 'submitting' | 'success'>
import { useEffect, useState } from "react";
import { NetworkError } from "../api/errors";
import useCurrentUserAuth from "./useCurrentUserAuth";

export default function useForm(wasSubmitting: boolean, onFailure: (error: NetworkError) => void, onSuccess: () => void, onSubmitting: () => void, isValid: boolean): string {
  const [state, setState] = useState('ready');
  const { currentUser, lastSignInAttemptError, failed, submitting } = useCurrentUserAuth();

  useEffect(() => {
    if (failed && wasSubmitting) {
      setState('ready');
      onFailure(lastSignInAttemptError);
    }
  }, [failed, wasSubmitting, lastSignInAttemptError, onFailure, setState]);

  useEffect(() => {
    if (currentUser && state !== 'success') {
      setState('success');
      onSuccess();
    }
  }, [currentUser, onSuccess, state, setState]);

  useEffect(() => {
    if (isValid && submitting) {
      setState('submitting');
      onSubmitting();
    }
  }, [submitting, isValid, onSubmitting]);

  useEffect(() => {
    if (isValid && state == 'ready') {
      setState('canSubmit');
    }
  }, [isValid, state]);

  return state;
}