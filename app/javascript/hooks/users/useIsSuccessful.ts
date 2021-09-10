import { useEffect, useState } from "react";
import useCurrentUserAuth from "../useCurrentUserAuth";

export default function useIsSuccessful(showProgressAndSuccess: boolean, onSuccess: () => void): boolean {
  const [state, setState] = useState(false);

  const { currentUser } = useCurrentUserAuth();

  useEffect(() => {
    if (!state && currentUser && showProgressAndSuccess) {
      setState(true);
      onSuccess();
    } else {
      setState(false);
    }
  }, [currentUser, showProgressAndSuccess, setState]);

  return state;
}
