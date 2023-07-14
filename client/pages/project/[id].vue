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

			button(@click="castVote(userId)", :disabled="") Cast vote!
			p(v-if="voteFeedback") {{ voteFeedback }}

</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/utils/api'
import { userId } from '@composables'
import { useRoute, navigateTo } from 'nuxt'
const route = useRoute()

// const executeFlag = ref(true)
const projectPromise = computed(() => {
	// executeFlag.value
	return api.FetchProject({ projectId: route.params.id, userId: userId.value })
})

const voteFeedback = ref(null as string | null)
async function castVote(userId: string) {
	const newVote = project.userPledge.vote
	if (newVote === null) return

	const succeeded = await handleFeedback(
		voteFeedback, "loading...", "vote cast!", e => `oh no! ${e}`,
		api.CastVote(userId, route.params.id, newVote),
	)
	if (succeeded)
		// force refresh
		navigateTo(route.url)
		// executeFlag.value = !executeFlag.value
}

</script>
