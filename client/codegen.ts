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
					Date: 'unknown',
					Datetime: 'unknown',
				},
				strictScalars: true,
				// avoidOptionals: true,
				avoidOptionals: {
					field: true,
					object: true,
					defaultValue: true,
					inputValue: false,
				},
				skipTypename: true,
				arrayInputCoercion: false,
				onlyOperationTypes: true,
				disableDescriptions: true,

				inputMaybeValue: 'T | null | undefined',

			},
		},
	},
}
export default config
