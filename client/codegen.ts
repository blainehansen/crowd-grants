import type { CodegenConfig } from '@graphql-codegen/cli'

const config: CodegenConfig = {
	schema: 'http://localhost:6060/graphql',
	documents: ['utils/api/*.gql'],
	generates: {
		'utils/api/index.generated.ts': {
			// plugins: ['typescript', 'typescript-operations', 'typescript-generic-sdk'],
			plugins: ['typescript', 'typescript-operations', 'typescript-graphql-request'],
			config: {
				scalars: {
					UUID: 'string',
					BigFloat: 'number',
					Cursor: 'unknown',
				},
				strictScalars: true,
				avoidOptionals: true,
				skipTypename: true,
				arrayInputCoercion: false,
				onlyOperationTypes: true,
				disableDescriptions: true,
			},
		},
	},
}
export default config
