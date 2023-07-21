import { GraphQLClient } from 'graphql-request'
import { getSdk } from './index.generated'

import { Result } from '@blainehansen/monads'
import { Nullable, resultPromise, resultPromiseDemandKey } from '@/utils'

export * from './index.generated'
import { ProjectStatusEnum, ProjectPaymentKind } from './index.generated'
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
	MakePledge(...args: Parameters<typeof sdk.MakePledge>) {
		return resultPromise(sdk.MakePledge(...args))
	},
	CastVote(...args: Parameters<typeof sdk.CastVote>) {
		return resultPromise(sdk.CastVote(...args))
	},
	FetchProjects(...args: Parameters<typeof sdk.FetchProjects>) {
		// return resultPromiseDemandKey<{ nodes: Array<ProjectSummary> } | null, 'projects'>(
		return resultPromiseDemandKey(
			sdk.FetchProjects(...args), 'projects',
		)
	},
	FetchProject(...args: Parameters<typeof sdk.FetchProject>) {
		// return resultPromiseDemandKey<Project | null, 'project'>(
		return resultPromiseDemandKey(
			sdk.FetchProject(...args), 'project',
		)
	},
}


// export type Owner = { id: string, name: string }

// export type ProposalProjectSummary = {
// 	id: string,
// 	// status: ProjectStatusEnum.Proposal,
// 	status: ProjectStatusEnum,
// 	owner: Owner,
// 	title: string,
// 	totalPledgedAmount: number | null,
// 	monthCount: number,
// }

// export type FundedProjectSummary = {
// 	id: string,
// 	// status: ProjectStatusEnum.Funded,
// 	status: ProjectStatusEnum,
// 	owner: Owner,
// 	title: string,
// 	totalPledgedAmount: number | null,
// 	monthCount: number,
// 	monthsPassed: number | null,
// 	fundsPaid: number | null,
// }

// export type ProjectSummary = ProposalProjectSummary | FundedProjectSummary

// export type UserPledge = Nullable<{
// 	vote: boolean,
// 	amount: number,
// 	count: number,
// }>

// export type ProposalProject = {
// 	id: string,
// 	// status: ProjectStatusEnum.Proposal,
// 	status: ProjectStatusEnum,
// 	owner: Owner,
// 	title: string,
// 	body: string,
// 	initialAmount: number,
// 	monthCount: number,
// 	monthlyAmount: number,
// 	prizeAmount: number,

// 	fundingRequirement: number | null,
// 	actualPrizeAmount: number | null,
// 	totalPledgedAmount: number | null,
// 	totalPledgerCount: number | null,

// 	userPledge: UserPledge | null,
// }

// export type FundedProject = {
// 	id: string,
// 	// status: ProjectStatusEnum.Funded,
// 	status: ProjectStatusEnum,
// 	owner: Owner,
// 	title: string,
// 	body: string,
// 	initialAmount: number,
// 	monthCount: number,
// 	monthlyAmount: number,
// 	prizeAmount: number,

// 	// baseFundingRequirement
// 	fundingRequirement: number | null,
// 	actualPrizeAmount: number | null,
// 	totalPledgedAmount: number | null,
// 	totalPledgerCount: number | null,

// 	fundsPaid: number | null,
// 	monthsPassed: number | null,
// 	nextPayment: Nullable<{
// 		amount: number,
// 		isLast: boolean,
// 		kind: ProjectPaymentKind,
// 	}> | null,
// 	overallPledgeVote: Nullable<{
// 		shouldContinue: boolean,
// 		weightInFavor: number,
// 		weightOpposed: number,
// 	}> | null,

// 	userPledge: UserPledge | null,
// }

// export type Project = ProposalProject | FundedProject
