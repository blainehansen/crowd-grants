<template lang="pug">

ResultPromise(:promise="draftPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="draft")
		input(v-model="draft.title", placeholder="title")
		input(v-model.number="draft.initialAmount", placeholder="initial funding requirement, for upfront costs")
		input(v-model.number="draft.monthCount", placeholder="how many months will your project run?")
		input(v-model.number="draft.monthlyAmount", placeholder="how much per month do you need?")
		input(v-model.number="draft.prizeAmount", placeholder="prize amount")

		textarea(v-model="draft.body", placeholder="describe your project")

		button(@click="save(draft)", :disabled="!valid(draft)") save
		p(v-if="saveFeedback") {{ saveFeedback }}

		button(@click="publish(draft)", :disabled="!valid(draft)") publish!
		p(v-if="publishFeedback") {{ publishFeedback }}

</template>

<script setup lang="ts">
import { ref, computed, onUnmounted } from 'vue'
import { useRoute, navigateTo } from '#imports'
import api from '@/utils/api'
import { handleFeedback, Unpromise } from '@/utils'
import { userId } from '@/composables'
const route = useRoute()

const draftPromise = computed(() => api.FetchDraft({ draftId: route.params.id as string }))
type Draft = Unpromise<typeof api.FetchDraft>

function valid(draft: Draft) {
	return draft.initialAmount >= 0
		&& draft.monthCount >= 0
		&& draft.monthlyAmount >= 0
		&& draft.prizeAmount >= 0
}

const saveFeedback = ref(null as string | null)
function save(draft: Draft) {
	handleFeedback(
		saveFeedback, "saving...", "success!", (e) => `oh no! ${e}`,
		api.SaveDraft(draft),
	)
}

const publishFeedback = ref(null as string | null)
async function publish(_: Draft) {
	await handleFeedback(
		publishFeedback, "publishing...", "success! you'll be redirected soon", (e) => `oh no! ${e}`,
		api.PublishDraft({ projectId: route.params.id as string }),
	)
	return navigateTo(`/proposal/${route.params.id}`)
}

</script>
