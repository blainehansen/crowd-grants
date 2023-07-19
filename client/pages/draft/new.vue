<template lang="pug">

div
	h1 Create a new draft!

	input(v-model="newDraftTitle")
	button(v-if="newDraftTitle", @click="createDraft") create
	p(v-if="createDraftFeedback") {{ createDraftFeedback }}

</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { navigateTo } from '#imports'
import api from '@/utils/api'
import { userId } from '@/composables'
import { handleFeedback } from '@/utils'

const newDraftTitle = ref('')
const createDraftFeedback = ref(null as string | null)

async function createDraft() {
	if (!newDraftTitle.value || !userId.value) return

	const draftId = await handleFeedback(
		createDraftFeedback, "creating...", null, (e) => `oh no! ${e}`,
		api.CreateDraft({ input: { ownerId: userId.value, title: newDraftTitle.value } }),
	)
	if (draftId !== undefined)
		return navigateTo(`/draft/${draftId}`)
}

</script>
