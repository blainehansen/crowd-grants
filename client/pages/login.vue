<template lang="pug">

div
	div(v-if="userId !== null") You are logged in.
	template(v-else)
		p Let's unsafely log in!
		input(v-model="tempUserId", placeholder="00000000-0000-0000-0000-000000000000")
		button(@click="unsafelyLogIn", :disabled="!tempUserId") log in as this userId

</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, navigateTo } from '#imports'
// import api from '@/utils/api'
// import { handleFeedback } from '@/utils'
import { userId } from '@/composables'
const route = useRoute()

const tempUserId = ref('')

function unsafelyLogIn() {
	if (!tempUserId.value) return
	userId.value = tempUserId.value
	return navigateTo(route.query.r as string || '/')
}

</script>
