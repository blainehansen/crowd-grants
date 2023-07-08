// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
	ssr: false,
	imports: {
		autoImport: false,
	},
	typescript: {
		typeCheck: true,
	},
})
