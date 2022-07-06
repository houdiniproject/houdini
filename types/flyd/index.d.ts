// License: MIT
// from https://github.com/paldepind/flyd/blob/master/index.d.ts

/* eslint-disable @typescript-eslint/member-ordering */

declare namespace flyd {
	interface Stream<T> {
    (): T;
    (value: T): Stream<T>;
    (value: Promise<T> | PromiseLike<T>): Stream<T>;

    end: Stream<boolean>;
  }

	interface CreateStream {
    <T>(): Stream<T>;
    <T>(value: T): Stream<T>;
    <T>(value: Promise<T> | PromiseLike<T>): Stream<T>;
    (): Stream<void>;
  }

	interface Static {
		stream: CreateStream;
	}
}


declare module 'flyd' {
  const f: flyd.Static;
  export = f;
}

