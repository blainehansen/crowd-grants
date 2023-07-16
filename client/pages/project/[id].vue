<template lang="pug">

ResultPromise(:promise="projectPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="project")
		h1 {{ project.title }}
		h2 Creator:
		NuxtLink(:to="`/person/${project.owner.id}`") {{ project.owner.name }}

		div {{ project.body }}

		h2 {{ project.monthsPassed }} have passed, {{ project.monthCount - project.monthsPassed }} more to go.
		h2 {{ project.fundsPaid }} has been spent of {{ project.totalPledgedAmount }}.

		h2 Actual prize amount: {{ project.actualPrizeAmount }} (originally asked for {{ project.prizeAmount }})

		template(v-if="project.userPledge !== null")
			p You pledged {{ project.userPledge.amount }} {{ project.userPledge.count > 1 ? `in ${project.userPledge.count} pledges` : '' }}
			p(v-if="project.userPledge.vote !== null") You've cast a vote to {{ project.userPledge.vote ? 'continue' : 'discontinue' }} this project.
			p(v-else) You haven't cast a vote to discontinue this project.

			input#continue(type='radio', :value='true', v-model='project.userPledge.vote')
			label(for='continue') Continue
			input#no_continue(type='radio', :value='false', v-model='project.userPledge.vote')
			label(for='no_continue') Don't continue

			button(@click="castVote(userId, project.userPledge.vote)", :disabled="project.userPledge.vote === null") Cast vote!
			p(v-if="voteFeedback") {{ voteFeedback }}

</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, navigateTo } from '#imports'
import api from '@/utils/api'
import { handleFeedback } from '@/utils'
import { userId } from '@/composables'
const route = useRoute()

// const executeFlag = ref(true)
const projectPromise = computed(() => {
	// executeFlag.value
	if (!userId.value) return
	return api.FetchProject({ projectId: route.params.id as string, userId: userId.value })
})

const voteFeedback = ref(null as string | null)
async function castVote(userId: string | null, newVote: boolean | null) {
	if (userId === null || newVote === null) return

	const succeeded = await handleFeedback(
		voteFeedback, "loading...", "vote cast!", e => `oh no! ${e}`,
		api.CastVote({ pledgerId: userId, projectId: route.params.id as string, shouldContinue: newVote }),
	)
	if (succeeded)
		// force refresh
		navigateTo(route.path)
		// executeFlag.value = !executeFlag.value
}

</script>
