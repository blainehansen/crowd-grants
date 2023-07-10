<template lang="pug">

ResultPromise(:promise="proposalPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="proposal")
		h1 {{ proposal.title }}

		h2 Funding requirement: {{ proposal.fundingRequirement }}
		h2 Budget amount: {{ proposal.budgetAmount }}
		h2 Prize amount: {{ proposal.prizeAmount }}
		h2 Overall pledged amount: {{ proposal.overallPledgedAmount }} (from {{ proposal.overallPledgerCount }} pledgers)

		p Proposed months
		div(v-for="(month, index) in proposal.months")
			h2 {{ month.budgetAmount }}
			h2 {{ month.description }}

		h2 {{ proposal.prizeAmount }}

		h2 Creator:
		NuxtLink(:to="`/person/${proposal.owner.id}`") {{ proposal.owner.name }}

		template(v-if="userId !== null")
			input(v-model.number="pledgeAmount")
			button(@click="pledge(userId)", :disabled="!pledgeAmount") pledge to this project!
			p(v-if="pledgeFeedback") {{ pledgeFeedback }}

</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/utils/api'
import { userId } from '@composables'
import { useRoute, navigateTo } from 'nuxt'
const route = useRoute()

// const executeFlag = ref(true)
const proposalPromise = computed(() => {
	// executeFlag.value
	return api.FetchProposal({ proposalId: route.params.id })
})


const pledgeFeedback = ref(null as string | null)
async function pledge(userId: string) {
	const parsedPledgeAmount = parseFloat(pledgeAmount.value)
	if (isNaN(parsedPledgeAmount)) {
		pledgeFeedback.value = "not a number"
		return
	}

	const succeeded = await handleFeedback(
		pledgeFeedback, "loading...", "pledged!", e => `oh no! ${e}`,
		api.MakePledge(userId, route.params.id, parsedPledgeAmount),
	)
	if (succeeded)
		// force refresh
		navigateTo(route.url)
		// executeFlag.value = !executeFlag.value
}

</script>
