<template lang="pug">

h1 CrowdGrants!

div: a(href="/your-proposals/") create draft proposal


div browse current proposals
div browse ongoing projects
div browse past discontinued projects
div browse past successful projects

</template>


<script lang="ts">
let person = 'hello'

import { createNewProposal } from '$lib/api'

createNewProposal({ owner_id })

</script>
