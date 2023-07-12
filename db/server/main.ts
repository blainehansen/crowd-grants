import http = require('http')
import postgraphile = require('postgraphile')

// https://www.graphql-code-generator.com/docs/plugins/typescript
// https://www.graphql-code-generator.com/docs/plugins/typescript-generic-sdk
// PG_URL=$(grep 'url =' tusker.toml | sed "s/url = '\(.*\)'/\1/")

const postgraphileService = postgraphile.postgraphile(
	// here's where we would use the client name to make a more specific url
	process.env.PG_URL,
	"public",
	{
		watchPg: true,
		dynamicJson: true,
		enableCors: true,
		setofFunctionsContainNulls: false,
		ignoreRBAC: false,
		ignoreIndexes: true,
		graphileBuildOptions: {
			pgStrictFunctions: true,
		},
		showErrorStack: "json",
		extendedErrors: ["hint", "detail", "errcode"],
		pgDefaultRole: 'user',
		appendPlugins: [
			require('@graphile-contrib/pg-simplify-inflector'),
			// require('postgraphile-plugin-nested-mutations'),
			// require('postgraphile-plugin-connection-filter'),
			builder => {
				// builder.hook("GraphQLObjectType:fields:field", (field, build, context) => {
				// 	// if (!context.scope.isMutationPayload && context.scope.pgIntrospection?.name == 'proposal_draft' && context.scope.fieldName == 'months') {
				// 	return context.scope.isPgForwardRelationField
				// 		?
				// 		: field

				// 	if (
				// 		!context.scope.isPgForwardRelationField
				// 		|| !context.scope.pgFieldIntrospection?.keyAttributes?.every((attr: any) => attr.isNotNull)
				// 	) return field
				// 	return {
				// 		...field,
				// 		type: new build.graphql.GraphQLNonNull(field.type),
				// 	}
				// })

				builder.hook("GraphQLObjectType:fields:field", (field, build, context) => {
					// if (!context.scope.isMutationPayload) {
					// 	console.log('field:', field)
					// 	console.log('context.scope:', context.scope)
					// 	console.log('')
					// }
					return context.scope.isPgForwardRelationField
						? {
							...field,
							type: new build.graphql.GraphQLNonNull(field.type),
						}
						: field
				})
			},
		],
		exportGqlSchemaPath: "schema.graphql",
		graphiql: true,
		enhanceGraphiql: true,
		allowExplain: _req => true,
		enableQueryBatching: true,
		legacyRelations: "omit",
		// pgSettings(req) {},
	},
)

http
	.createServer((req, res) => {
		// console.log(req.headers)
		// always getting maverik, but could choose which one based on a header
		// const postgraphileService = postgraphileServices['maverik']
		postgraphileService(req, res)
	})
	.listen(process.env.PORT || 6060)
