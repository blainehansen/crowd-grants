<template lang="pug">

div
	ResultPromise(:promise="promise")
		template(#loading): | ...
		template(#err="err"): h1 Something went wrong! {{ err }}
		template(#ok="{ account, drafts, proposals, projects, completeProjects, closedProjects, failedProjects, pledgedProjects }")
			h1 {{ account.name }}

			h2 drafts:
			NuxtLink(v-for="draft in drafts", :key="draft.id", :to="`/draft/${draft.id}`") {{ draft.title }}

			h2 proposals:
			ProjectLink(v-for="proposal in proposals", :key="proposal.id", :project="proposal")
			h2 projects:
			ProjectLink(v-for="project in projects", :key="project.id", :project="project")
			h2 complete projects:
			ProjectLink(v-for="project in completeProjects", :key="project.id", :project="project")
			h2 closed projects:
			ProjectLink(v-for="project in closedProjects", :key="project.id", :project="project")
			h2 failed projects:
			ProjectLink(v-for="project in failedProjects", :key="project.id", :project="project")

			div(v-for="pledgedProject in pledgedProjects")
				p {{ pledgedProject.title }} ({{ renderStatus(pledgedProject.status).toLowerCase() }})
				p You pledged {{ pledgedProject.pledgeAmount }} {{ pledgedProject.pledgeCount > 1 ? `in ${pledgedProject.pledgeCount} pledges` : '' }}

				template(v-if="pledgedProject.status.type === 'PROPOSAL'")
					h2 Funding requirement: {{ proposal.status.fundingRequirement }}
					h2 Overall pledged amount: {{ proposal.status.overallPledgedAmount }}

				template(v-if="pledgedProject.status.type === 'FUNDED'")
					h2 {{ pledgedProject.status.monthsPassed }} months have passed of this project, {{ pledgedProject.status.monthsRemaining }} more to go.
					h2 Currently {{ pledgedProject.status.weightInFavor }} in favor against {{ pledgedProject.status.weightInFavor }} opposed.
					p(v-if="pledgedProject.vote !== null") You've cast a vote to {{ pledgedProject.vote ? 'continue' : 'discontinue' }} this project.
					p(v-else) You haven't cast a vote to discontinue this project.

				template(v-if="pledgedProject.status.type === 'CLOSED' || pledgedProject.status.type === 'FAILED'")
					p {{ pledgedProject.status.refundedAmount }} was able to be refunded to you.


</template>

<script setup lang="ts">
import { computed } from 'vue'
import api, { ProposalStatusEnum } from '@/utils/api'

function renderStatus(status: ProposalStatusEnum) {
	switch (status) {
		case ProposalStatusEnum.DRAFT: return 'Draft'
		case ProposalStatusEnum.PROPOSAL: return 'Proposal'
		case ProposalStatusEnum.CLOSED: return 'Closed'
		case ProposalStatusEnum.FUNDED: return 'Funded'
		case ProposalStatusEnum.COMPLETE: return 'Complete'
		case ProposalStatusEnum.FAILED: return 'Failed'
	}
}

const promise = computed(async () => {
	const { account, allProjects, pledgedProjects } = await api.FetchAccount()
	const grouping = {}
	for (const project of allProjects) {
		(grouping[project.status] = grouping[project.status] || []).push(project)
	}
	const {
		DRAFT: drafts = [],
		PROPOSAL: proposals = [],
		CLOSED: closedProjects = [],
		FUNDED: projects = [],
		COMPLETE: completeProjects = [],
		FAILED: failedProjects = [],
	} = grouping
	return { account, drafts, proposals, closedProjects, projects, completeProjects, failedProjects, pledgedProjects }
})

</script>
