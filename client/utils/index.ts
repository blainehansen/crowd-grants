import { Ref } from 'vue'
import { Result, Ok, Err } from '@blainehansen/monads'

export type Unpromise<F extends (...args: any[]) => Promise<Result<any, any>>> =
	F extends (...args: any[]) => Promise<Result<infer T, any>> ? T : never

export type Nullable<T> = { [K in keyof T]: T[K] | null }

export function resultPromise<T>(promise: Promise<T>): Promise<Result<T, Error>> {
	return promise.then(Ok).catch(Err)
}

function demandKeyOk<T, K extends string>(v: { [k in K]: T }, key: K): Result<NonNullable<T>, Error> {
	const trueV = v[key]
	if (trueV === null || trueV === undefined) return Err(new Error(`${key} is null`))
	return Ok(trueV)
}

export function resultPromiseDemandKey<T, K extends string>(
	promise: Promise<{ [k in K]: T }>,
	key: K,
): Promise<Result<NonNullable<T>, Error>> {
	return promise.then(v => demandKeyOk<T, K>(v, key)).catch(Err)
}

export async function handleFeedback<F, E, T>(
	feedback: Ref<F | null>, loading: F, success: F, error: (e: E) => F,
	actionPromise: Promise<Result<T, E>>,
): Promise<T | undefined> {
	feedback.value = loading
	return actionPromise.then(result => {
		if (result.isOk()) {
			feedback.value = success
			return result.value
		}
		else {
			feedback.value = error(result.error)
			return undefined
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

export function projectLink(id: number, status: ProjectStatusEnum): string {
	switch (status) {
		case ProjectStatusEnum.Draft: return `/draft/${id}`
		case ProjectStatusEnum.Proposal: return `/proposal/${id}`
		default: return `/project/${id}`
	}
}
