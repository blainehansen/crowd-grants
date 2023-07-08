<template lang="pug">

ResultPromise(:promise="draftPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="draft")

		input(v-model="draft.title")

		div(v-for="(month, index) in draft.months")
			input(v-model="month.budgetAmount")
			input(v-model="month.description")
			button(@click="deleteMonth(draft, index)") delete month

		button(@click="addMonth(draft)") add month

		input(v-model="draft.prizeAmount")

		button(@click="save(draft)") save
		p(v-if="saveFeedback") {{ saveFeedback }}
		//- ActionFeedback(:feedback="saveFeedback")

</template>

<script setup lang="ts">
import { computed, onUnmounted } from 'vue'
import api from '@/utils/api'
import { handleFeedback, useActionFeedback, Unpromise } from '@/utils'
import { userId } from '@/composables'

const draftPromise = computed(() => api.UserDraft({ ownerId: userId.value }))
type Draft = Unpromise<typeof api.UserDraft>

function addMonth(draft: Draft) {
	draft.months.push({ budgetAmount: 0, description: '' })
}
function deleteMonth(draft: Draft, index: number) {
	draft.months.splice(index, 1)
}

const saveFeedback = useActionFeedback()
function save(draft: Draft) {
	handleFeedback(saveFeedback, api.SaveDraft({ ownerId: userId.value, draft }))
}

type Feedback = string | null
function useActionFeedback() {
	return ref(null as Feedback)
}

export function handleFeedback<E>(feedback: Ref<Feedback>, actionPromise: Promise<Result<unknown, E>>) {
	feedback.value = 'loading...'
	actionPromise.then(result => {
		if (result.isOk()) {
			feedback.value = 'success!'
			const timeoutId = setTimeout(() => { feedback.value = null }, 2000)
			onUnmounted(() => clearTimeout(timeoutId))
		}
		else if (result.isErr())
			feedback.value = `oh no! ${result.error}`

	})
}

export function resultPromise<T>(promise: Promise<T>): Promise<Result<T, E>> {
	return promise.then(Ok).catch(Err)
}

</script>
