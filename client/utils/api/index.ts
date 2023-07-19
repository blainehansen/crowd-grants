import { GraphQLClient } from 'graphql-request'
import { getSdk } from './index.generated'

import { Result } from '@blainehansen/monads'
import { resultPromise, resultPromiseDemandKey } from '@/utils'

export * from './index.generated'
// TODO template host
// export default getSdk(new GraphQLClient('http://localhost:6060/graphql'))

const sdk = getSdk(new GraphQLClient('http://localhost:6060/graphql'))
// const safeSdk = {} as { [K in typeof sdk]: (...args: Parameters<sdk[K]>) => Result<ReturnType<sdk[K]>, Error> }
// for (const key in sdk) {
// 	const sdkFunc = sdk[key]
// 	safeSdk[key] = (...args: any[]) => resultPromiseDemandKey(sdkFunc(...args), '')
// }
// export default safeSdk

export default {
	FetchPerson(...args: Parameters<typeof sdk.FetchPerson>) {
		return resultPromiseDemandKey(sdk.FetchPerson(...args), 'person')
	},
	FetchYou(...args: Parameters<typeof sdk.FetchYou>) {
		return resultPromiseDemandKey(sdk.FetchYou(...args), 'you')
	},
	FetchDraft(...args: Parameters<typeof sdk.FetchDraft>) {
		return resultPromiseDemandKey(sdk.FetchDraft(...args), 'draft')
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
		return resultPromiseDemandKey(sdk.FetchProposals(...args), 'proposals')
	},
	FetchProposal(...args: Parameters<typeof sdk.FetchProposal>) {
		return resultPromiseDemandKey(sdk.FetchProposal(...args), 'proposal')
	},
	MakePledge(...args: Parameters<typeof sdk.MakePledge>) {
		return resultPromise(sdk.MakePledge(...args))
	},
	FetchProject(...args: Parameters<typeof sdk.FetchProject>) {
		return resultPromiseDemandKey(sdk.FetchProject(...args), 'project')
	},
	CastVote(...args: Parameters<typeof sdk.CastVote>) {
		return resultPromise(sdk.CastVote(...args))
	},
	FetchProjects(...args: Parameters<typeof sdk.FetchProjects>) {
		return resultPromiseDemandKey(sdk.FetchProjects(...args), 'projects')
	},
}

