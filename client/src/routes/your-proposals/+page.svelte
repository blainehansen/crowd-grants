<template lang="pug">

+each("proposals as { id, title } (id)")
	h1 {title}

</template>


<script lang="ts">
let person = 'hello'
</script>
