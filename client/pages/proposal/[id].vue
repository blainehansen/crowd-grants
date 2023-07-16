<template lang="pug">

ResultPromise(:promise="proposalPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="proposal")
		h1 {{ proposal.title }}
		h2 Creator:
		NuxtLink(:to="`/person/${proposal.owner.id}`") {{ proposal.owner.name }}

		h2 Funding requirement: {{ proposal.fundingRequirement }} ({{ proposal.initialAmount }} initial, {{ proposal.monthlyAmount }} for {{ proposal.monthCount }} months, and a prize of {{ proposal.prizeAmount }})

		h2 Overall pledged amount: {{ proposal.totalPledgedAmount }} (from {{ proposal.totalPledgerCount }} pledgers)

		div {{ proposal.body }}

		template(v-if="userId !== null")
			input(v-model.number="pledgeAmount")
			button(@click="pledge(userId)", :disabled="!pledgeAmount") pledge to this project!
			p(v-if="pledgeFeedback") {{ pledgeFeedback }}

</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, navigateTo } from '#imports'
import api from '@/utils/api'
import { handleFeedback } from '@/utils'
import { userId } from '@/composables'

const route = useRoute()

// const executeFlag = ref(true)
const proposalPromise = computed(() => {
	// executeFlag.value
	return api.FetchProposal({ proposalId: route.params.id as string })
})

const pledgeAmount = ref('')

const pledgeFeedback = ref(null as string | null)
async function pledge(userId: string) {
	const parsedPledgeAmount = parseFloat(pledgeAmount.value)
	if (isNaN(parsedPledgeAmount)) {
		pledgeFeedback.value = "not a number"
		return
	}

	const succeeded = await handleFeedback(
		pledgeFeedback, "loading...", "pledged!", e => `oh no! ${e}`,
		api.MakePledge({ pledgerId: userId, projectId: route.params.id as string, amount: parsedPledgeAmount}),
	)
	if (succeeded)
		// force refresh
		navigateTo(route.path)
		// executeFlag.value = !executeFlag.value
}

</script>
