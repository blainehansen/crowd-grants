import { GraphQLClient } from 'graphql-request'
import { getSdk } from './index.generated'

import { Result } from '@blainehansen/monads'
import { resultPromise } from '@/utils'

export * from './index.generated'
// TODO template host
// export default getSdk(new GraphQLClient('http://localhost:6060/graphql'))

const sdk = getSdk(new GraphQLClient('http://localhost:6060/graphql'))
// const safeSdk = {} as { [K in typeof sdk]: (...args: Parameters<sdk[K]>) => Result<ReturnType<sdk[K]>, Error> }
// for (const key in sdk) {
// 	const sdkFunc = sdk[key]
// 	safeSdk[key] = (...args: any[]) => resultPromise(sdkFunc(...args))
// }
// export default safeSdk

export default {
	FetchPerson(...args: Parameters<typeof sdk.FetchPerson>) {
		return resultPromise(sdk.FetchPerson(...args))
	},
	FetchYou(...args: Parameters<typeof sdk.FetchYou>) {
		return resultPromise(sdk.FetchYou(...args))
	},
	FetchDrafts(...args: Parameters<typeof sdk.FetchDrafts>) {
		return resultPromise(sdk.FetchDrafts(...args))
	},
	FetchDraft(...args: Parameters<typeof sdk.FetchDraft>) {
		return resultPromise(sdk.FetchDraft(...args))
	},
	CreateDraft(...args: Parameters<typeof sdk.CreateDraft>) {
		return resultPromise(sdk.CreateDraft(...args))
	},
	SaveDraft(...args: Parameters<typeof sdk.SaveDraft>) {
		return resultPromise(sdk.SaveDraft(...args))
	},
	PublishDraft(...args: Parameters<typeof sdk.PublishDraft>) {
		return resultPromise(sdk.PublishDraft(...args))
	},
	FetchProposals(...args: Parameters<typeof sdk.FetchProposals>) {
		return resultPromise(sdk.FetchProposals(...args))
	},
	FetchProposal(...args: Parameters<typeof sdk.FetchProposal>) {
		return resultPromise(sdk.FetchProposal(...args))
	},
	MakePledge(...args: Parameters<typeof sdk.MakePledge>) {
		return resultPromise(sdk.MakePledge(...args))
	},
	FetchProject(...args: Parameters<typeof sdk.FetchProject>) {
		return resultPromise(sdk.FetchProject(...args))
	},
	CastVote(...args: Parameters<typeof sdk.CastVote>) {
		return resultPromise(sdk.CastVote(...args))
	},
	FetchProjects(...args: Parameters<typeof sdk.FetchProjects>) {
		return resultPromise(sdk.FetchProjects(...args))
	},
}

