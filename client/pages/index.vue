<template lang="pug">

div
	h1 Crowd Grants!
	
	NuxtLink(v-if="userId", to="/drafts") see your draft proposals
	NuxtLink(v-if="userId", to="/pledges") see your projects and pledges
	NuxtLink(to="/proposals") see proposals
	NuxtLink(to="/projects") see ongoing projects

	//- create account/log in

</template>

<script setup lang="ts">
// import api from '@/utils/api'

import { userId } from '@/composables'

</script>
