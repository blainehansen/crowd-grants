export function usePromise<T>(f: () => Promise<T>) {
	//
}

// export type Unpromise<P extends Ref<Promise<any> | null>> = P extends Ref<Promise<infer T> | null> ? T : never
export type Unpromise<F extends (...args: any[]) => Promise<any>> = F extends (...args: any[]) => Promise<infer T> ? T : never
