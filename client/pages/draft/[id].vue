<template lang="pug">

ResultPromise(:promise="draftPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="draft")

		input(v-model="draft.title")

		div(v-for="(month, index) in draft.months")
			input(v-model.number="month.budgetAmount")
			input(v-model="month.description")
			button(@click="deleteMonth(draft, index)") delete month

		button(@click="addMonth(draft)") add month

		input(v-model.number="draft.prizeAmount")

		button(@click="save(draft)", :disabled="!valid") save
		p(v-if="saveFeedback") {{ saveFeedback }}

		button(@click="publish(draft)", :disabled="!valid") publish!
		p(v-if="publishFeedback") {{ publishFeedback }}

</template>

<script setup lang="ts">
import { ref, computed, onUnmounted } from 'vue'
import api from '@/utils/api'
import { handleFeedback, Unpromise } from '@/utils'
import { userId } from '@/composables'
import { useRoute } from 'nuxt'
const route = useRoute()

const draftPromise = computed(() => api.FetchDraft({ draftId: route.params.id, userId: userId.value }))
type Draft = Unpromise<typeof api.FetchDraft>['project']

const valid = computed(() => {
	// TODO
	return true
})

function addMonth(draft: Draft) {
	draft.months.push({ budgetAmount: 0, description: '' })
}
function deleteMonth(draft: Draft, index: number) {
	draft.months.splice(index, 1)
}

const saveFeedback = ref(null as string | null)
function save(draft: Draft) {
	handleFeedback(
		saveFeedback, "saving...", "success!", (e) => `oh no! ${e}`
		api.SaveDraft(draft),
	)
}

const publishFeedback = ref(null as string | null)
async function publish(_: Draft) {
	await handleFeedback(
		publishFeedback, "publishing...", "success! you'll be redirected soon", (e) => `oh no! ${e}`
		api.PublishDraft(route.params.id),
	)
	return navigateTo(`/proposal/${route.params.id}`)
}

</script>
