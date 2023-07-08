import { GraphQLClient } from 'graphql-request'
import { getSdk } from './index.generated'

export * from './index.generated'
// TODO template host
export default getSdk(new GraphQLClient('http://localhost:6060/graphql'))
