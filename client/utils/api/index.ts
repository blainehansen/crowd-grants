import { GraphQLClient } from 'graphql-request'
import { getSdk } from './index.generated'

import { Result } from '@blainehansen/monads'
import { resultPromise } from '@/utils'

export * from './index.generated'
// TODO template host
// export default getSdk(new GraphQLClient('http://localhost:6060/graphql'))

const sdk = getSdk(new GraphQLClient('http://localhost:6060/graphql'))
const safeSdk = {} as { [K in typeof sdk]: (...args: Parameters<sdk[K]>) => Result<ReturnType<sdk[K]>, Error> }
for (const key in sdk) {
	const sdkFunc = sdk[key]
	safeSdk[key] = (...args) => resultPromise(sdkFunc(...args))
}
export default safeSdk
