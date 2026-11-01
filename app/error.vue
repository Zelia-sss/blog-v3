<script setup lang="ts">
import type { NuxtError } from '#app'

defineProps<{
	error: NuxtError & { url?: string }
}>()

const isDev = import.meta.dev
</script>

<template>
<NuxtLayout>
	<template #aside>
		<WidgetBlogLog />
	</template>

	<div class="app-error">
		<ZError
			:code="isDev ? error.stack : undefined"
			:message="isDev ? error.url : undefined"
			:title="`[${error.status}] ${isDev ? error.message : '页面出错了'}`"
		>
			<template #operation>
				<ZButton text="返回主页" @click="clearError({ redirect: '/' })" />
				<ZButton text="尝试忽略" @click="clearError()" />
			</template>
		</ZError>
	</div>
</NuxtLayout>
</template>

<style lang="scss" scoped>
.app-error {
	margin: 1rem;
}
</style>
