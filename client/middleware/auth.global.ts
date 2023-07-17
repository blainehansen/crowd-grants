import { userId } from '@/composables'
import { defineNuxtRouteMiddleware, navigateTo } from '#imports'

export default defineNuxtRouteMiddleware((to, from) => {
	if (userId.value === null && (
		to.path.startsWith('/draft/')
		|| to.path.startsWith('/you')
	))
		return navigateTo('/login')
})