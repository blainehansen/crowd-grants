<template lang="pug">

ResultPromise(:promise="personPromise")
	template(#loading): | ...
	template(#err="err"): | {{ err }}
	template(#ok="person")
		h1 {{ person.name }}

		NuxtLink(
			v-for="project in publishedProjects", :key="project.id",
			tag="h2", :to="`/project/${project.id}`",
		) {{ project.title }} ({{ renderStatus(project.status) }})

</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/utils/api'
import { renderStatus } from '@/utils'
import { useRoute } from 'nuxt'
const route = useRoute()

const personPromise = computed(() => {
	return api.FetchPerson({ personId: route.params.id })
})

</script>
