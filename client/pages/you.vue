<template lang="pug">

div
	ResultPromise(:promise="promise")
		template(#loading): | ...
		template(#err="err"): h1 Something went wrong! {{ err }}
		template(#ok="account")
			h1 {{ account.name }}

			h2 Your projects:
			NuxtLink(v-for="project in account.projects.nodes", :key="project.id", :to="projectLink(project.id, project.status)")
				| {{ project.title }} ({{ renderStatus(project.status) }})

			div(v-for="project in account.projectPledges.nodes", :key="project.projectId")
				p {{ project.title }} ({{ renderStatus(project.status) }})
				p You pledged {{ project.amount }} {{ project.count > 1 ? `in ${project.pledgeCount} pledges` : '' }}
				p(v-if="project.vote !== null") You've cast a vote to {{ project.vote ? 'continue' : 'discontinue' }} this project.
				p(v-else) You haven't cast a vote to discontinue this project.

	div: NuxtLink(to="/draft/new") Create a new draft.

</template>

<script setup lang="ts">
import { computed } from 'vue'
import { navigateTo } from '#imports'
import { userId } from '@/composables'
import { renderStatus, projectLink } from '@/utils'
import api, { ProjectStatusEnum } from '@/utils/api'

const promise = computed(() => api.FetchYou({ userId: userId.value! }))

</script>
