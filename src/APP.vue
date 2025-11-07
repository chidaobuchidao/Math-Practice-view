<template>
    <div id="app">
        <router-view />
    </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
let visibilityHandler = null

onMounted(() => {
    // 页面获得焦点时重新检查用户状态
    visibilityHandler = () => {
        if (!document.hidden) {
            userStore.initFromStorage()
        }
    }

    document.addEventListener('visibilitychange', visibilityHandler)
})

onUnmounted(() => {
    if (visibilityHandler) {
        document.removeEventListener('visibilitychange', visibilityHandler)
    }
})
</script>

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB',
        'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
}

#app {
    min-height: 100vh;
}
</style>