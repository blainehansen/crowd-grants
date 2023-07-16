// export type Unpromise<P extends Ref<Promise<any> | null>> = P extends Ref<Promise<infer T> | null> ? T : never
import { onUnmounted, Ref } from 'vue'
import { Result, Ok, Err } from '@blainehansen/monads'

export type Unpromise<F extends (...args: any[]) => Promise<Result<any, any>>> =
	F extends (...args: any[]) => Promise<Result<infer T, any>> ? T : never

export function resultPromise<T>(promise: Promise<T>): Promise<Result<T, Error>> {
	return promise.then(Ok).catch(Err)
}

export async function handleFeedback<F, E>(
	feedback: Ref<F | null>, loading: F, success: F, error: (e: E) => F,
	actionPromise: Promise<Result<unknown, E>>,
): Promise<boolean> {
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

import { ProjectStatusEnum } from '@/utils/api'

export function renderStatus(status: ProjectStatusEnum) {
	switch (status) {
		case ProjectStatusEnum.Draft: return 'Draft'
		case ProjectStatusEnum.Proposal: return 'Proposal'
		case ProjectStatusEnum.Closed: return 'Closed'
		case ProjectStatusEnum.Funded: return 'Funded'
		case ProjectStatusEnum.Complete: return 'Complete'
		case ProjectStatusEnum.Failed: return 'Failed'
	}
}
