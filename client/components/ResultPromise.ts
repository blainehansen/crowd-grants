import { reactive, watch, defineComponent, h, InternalSlots } from 'vue'
import { Result } from '@blainehansen/monads'

// type SlotsType<T, E> = {
// 	default: () => VNode[],
// 	combined?: (args: { loading: boolean, ok: T | null, err: E | null }) => VNode[],
// 	ok?: (value: T) => VNode[],
// 	err?: (error: E) => VNode[],
// 	loading?: () => VNode[],
// }

export default defineComponent(
	// <T, E>(props: { promise: Promise<Result<T, E>> | null, tag: string }, { slots }: { slots: SlotsType<T, E> }) => {
	<T, E>(props: { promise: Promise<Result<T, E>> | null, tag?: string }, { slots }: { slots: InternalSlots }) => {
		const state = reactive({
			resolved: false,
			ok: null as T | null,
			err: null as E | null,
		})

		watch(() => props.promise, (promise, oldPromise) => {
			if (promise === oldPromise)
				return

			state.resolved = false
			state.err = null
			if (!promise) {
				state.ok = null
				return
			}
			promise.then(result => {
				result.match({
					ok: ok => { state.ok = ok },
					err: err => { state.err = err },
				})
				state.resolved = true
			})
		}, { immediate: true })

		return () => {
			const defaultItems = slots.default() || []
			// return h(props.tag, defaultItems.concat(
			return h('div', defaultItems.concat(
				slots.combined ? slots.combined({ loading: !state.resolved, ok: state.ok, err: state.err, })
				: slots.err && state.err !== null ? slots.err(state.err)
				: slots.ok && state.resolved ? slots.ok(state.ok)
				: slots.loading ? slots.loading()
				: []
			))
		}
	},
	{
		props: {
			promise: {
				type: Object,
				required: true,
			},

			// tag: String,
			// tag: {
			// 	type: String,
			// 	// validator(tag: string) {
			// 	// 	return tag !== ''
			// 	// },
			// 	default: 'div',
			// 	required: false,
			// },
		},
	},
)
