import { useEffect, useState } from "react";

export default function useCanSubmit(isValid: boolean, showProgressAndSuccess: boolean, formState: string, touched: boolean): boolean {
  const [state, setState] = useState(false);

  useEffect(() => {
    if (isValid && formState == 'ready' && showProgressAndSuccess && touched) {
      setState(true);
    } else {
      setState(false);
    }
  }, [isValid, showProgressAndSuccess, formState, touched, setState]);

  return state;
}
