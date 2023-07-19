<template lang="pug">

ResultPromise(:promise="personPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="person")
		h1 {{ person.name }}

		NuxtLink(
			v-for="project in person.publishedProjects.nodes", :key="project.id",
			tag="h2", :to="projectLink(project.id, project.status)",
		) {{ project.title }} ({{ renderStatus(project.status) }})

</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from '#imports'
import api from '@/utils/api'
import { renderStatus, projectLink } from '@/utils'
const route = useRoute()

const personPromise = computed(() => {
	return api.FetchPerson({ personId: route.params.id as string })
})

</script>
