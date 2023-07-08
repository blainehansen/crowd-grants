<template lang="pug">

h1 {{ person.toLowerCase() }}
	
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '@/utils/api'

const person = ref('HELLO')

</script>
