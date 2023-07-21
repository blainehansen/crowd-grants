<template lang="pug">

ResultPromise(:promise="projectPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="project")
		ProposalProject(v-if="project.status === ProjectStatusEnum.Proposal", :proposal="project")
		FundedProject(v-else, :project="project")

</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute, navigateTo } from '#imports'
import api, { ProjectStatusEnum } from '@/utils/api'
import { handleFeedback } from '@/utils'
import { userId } from '@/composables'
const route = useRoute()

// const executeFlag = ref(true)
const projectPromise = computed(() => {
	// executeFlag.value
	if (!userId.value) return
	// TODO navigate away if project status no longer matches
	return api.FetchProject({ projectId: route.params.id as string, userId: userId.value })
})

</script>
