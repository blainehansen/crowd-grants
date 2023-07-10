// export type Unpromise<P extends Ref<Promise<any> | null>> = P extends Ref<Promise<infer T> | null> ? T : never
export type Unpromise<F extends (...args: any[]) => Promise<any>> = F extends (...args: any[]) => Promise<infer T> ? T : never

export function resultPromise<T>(promise: Promise<T>): Promise<Result<T, E>> {
	return promise.then(Ok).catch(Err)
}

export async function handleFeedback<F, E>(
	feedback: Ref<F | null>, loading: F, success: F, error: (e: E) => F,
	actionPromise: Promise<Result<unknown, E>>,
): boolean {
	feedback.value = loading
	return actionPromise.then(result => {
		if (result.isOk()) {
			feedback.value = success
			const timeoutId = setTimeout(() => { feedback.value = null }, 2000)
			onUnmounted(() => clearTimeout(timeoutId))
			return true
		}
		else {
			feedback.value = error(result.error)
			return false
		}
	})
}
