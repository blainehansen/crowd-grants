// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
	devServer: {
		port: 8080,
	},
	ssr: false,
	imports: {
		autoImport: false,
	},
	typescript: {
		typeCheck: true,
	},
})
