<template lang="pug">

div
	ResultPromise(:promise="promise")
		template(#loading): | ...
		template(#err="err"): h1 Something went wrong! {{ err }}
		template(#ok="projects")
			div(v-for="project in projects", :key="project.id")
				NuxtLink(:to="`/project/${project.id}`") {{ project.title }}
				NuxtLink(:to="`/person/${project.owner.id}`") {{ project.owner.name }}
				p {{ project.monthsPassed }} have passed, {{ project.monthCount - project.monthsPassed }} more to go.
				p {{ project.fundsPaid }} paid of {{ project.totalPledgedAmount }}

</template>

<script setup lang="ts">
import { computed } from 'vue'
import api from '@/utils/api'

const promise = computed(() => api.FetchProjects())

</script>
