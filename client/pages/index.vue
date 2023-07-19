<template lang="pug">

div
	h1 Crowd Grants!
	
	div: NuxtLink(v-if="!userId", to="/login") log in
	div: NuxtLink(v-if="userId", to="/you") see your account
	div: NuxtLink(v-if="userId", to="/draft/new") draft a new project
	div: NuxtLink(to="/proposals") see proposals
	div: NuxtLink(to="/projects") see ongoing projects


</template>

<script setup lang="ts">
// import api from '@/utils/api'

import { userId } from '@/composables'

</script>
