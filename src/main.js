import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import App from './App.vue'
import router from './router'
import { getCurrentInstance } from 'vue'
import { useUserStore } from './stores/user' // 添加：相对路径导入 store

const app = createApp(App)

// 注册 Pinia
const pinia = createPinia()
app.use(pinia)

// 在 app.use(pinia) 之后、mount 之前初始化用户状态，保证路由守卫能读取到正确状态
const userStore = useUserStore()
userStore.initFromStorage()

// 暴露当前实例，用于在组件中访问全局属性
const instance = getCurrentInstance()
if (instance) {
  instance.appContext.config.globalProperties.$teacherInfoRef = instance
}

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(ElementPlus)
app.use(router)
app.mount('#app')
