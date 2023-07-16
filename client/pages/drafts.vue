<template lang="pug">

div
	ResultPromise(:promise="promise")
		template(#loading): | ...
		template(#err="err"): h1 Something went wrong! {{ err }}
		template(#ok="drafts")
			div(v-for="draft in drafts", :key="draft.id")
				h1 {{ draft.title }}
				NuxtLink(:to="`/draft/${draft.id}`", tag="button") edit

	input(v-model="newDraftTitle")
	button(v-if="newDraftTitle", @click="createDraft") create a new draft
	p(v-if="createDraftErr")

</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { navigateTo } from '#imports'
import api from '@/utils/api'
import { userId } from '@/composables'

const newDraftTitle = ref('')
const createDraftErr = ref(null as string | null)

const promise = computed(() => {
	if (!userId.value) return
	return api.FetchDrafts({ userId: userId.value })
})

async function createDraft() {
	if (!newDraftTitle.value || !userId.value) return

	const createResult = await api.CreateDraft({ input: { ownerId: userId.value, title: newDraftTitle.value } })
	if (createResult.isErr()) {
		createDraftErr.value = createResult.error.message
		return
	}
	const draftId = createResult.value
	return navigateTo(`/draft/${draftId}`)
}

</script>
