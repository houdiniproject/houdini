
// License: LGPL-3.0-or-later
// we add CSRF to the window type

type WindowAndCsrf = Window & {_csrf:string};
export function windowWithCSRF(): WindowAndCsrf {
  return window as unknown as WindowAndCsrf;
}

/** includes the csrf token automatically */
export function commonFetch(url: string, props: any): Promise<Response> {
  return fetch(url, {
    method: 'POST',
    body: JSON.stringify(props),
    headers: new Headers({
      'Content-Type': 'application/json',
      'X-CSRF-Token': windowWithCSRF()._csrf
    }),
    credentials: 'include'
  });
}