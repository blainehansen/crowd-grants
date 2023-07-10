<template lang="pug">

ResultPromise(:promise="projectPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="project")
		h1 {{ project.title }}

		h2 {{ project.monthsPassed }} have passed, {{ project.months.length - project.monthsPassed }} more to go.
		h2 {{ project.budgetSpent }} has been spent of {{ project.budgetAmount }}.

		h2 Prize amount: {{ project.prizeAmount }}

		p Months
		div(v-for="(month, index) in project.months")
			h2 {{ month.budgetAmount }}
			h2 {{ month.description }}
			p {{ month.completed ? 'passed' : 'future' }}

		h2 Creator:
		NuxtLink(:to="`/person/${project.owner.id}`") {{ project.owner.name }}

		template(v-if="userId !== null && project.userPledge !== null")
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
	return api.FetchProject({ projectId: route.params.id })
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
