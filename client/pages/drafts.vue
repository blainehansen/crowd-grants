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
import { ref } from 'vue'
import { navigateTo } from 'nuxt'
import api from '@/utils/api'
import { userId } from '@/composables'

const newDraftTitle = ref('')
const createDraftErr = ref(null as string | null)

const promise = computed(() => {
	return api.UserDrafts({ id: userId.value })
})

async function createDraft() {
	if (!newDraftTitle.value)
	const createResult = await api.CreateDraft({ ownerId: userId.value, title: newDraftTitle.value })
	if (createResult.is_err()) {
		createDraftErr.value = createResult.error
		return
	}
	const draftId = createResult.value
	return navigateTo(`/drafts/edit/${draftId}`)
}

</script>
