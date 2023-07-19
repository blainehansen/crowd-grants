<template lang="pug">

div
	ResultPromise(:promise="promise")
		template(#loading): | ...
		template(#err="err"): h1 Something went wrong! {{ err }}
		template(#ok="proposals")
			div(v-for="proposal in proposals.nodes", :key="proposal.id")
				div: NuxtLink(:to="`/proposal/${proposal.id}`") {{ proposal.title }}
				div: NuxtLink(:to="`/person/${proposal.owner.id}`") {{ proposal.owner.name }}
				p {{ proposal.totalPledgedAmount }} pledged out of {{ proposal.fundingRequirement }}

</template>

<script setup lang="ts">
import { computed } from 'vue'
import api from '@/utils/api'

const promise = computed(() => api.FetchProposals())

</script>
