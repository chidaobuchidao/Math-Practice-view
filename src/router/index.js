import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/',
    redirect: '/login',
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresGuest: true },
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { requiresGuest: true },
  },
  {
    path: '/teacher',
    name: 'TeacherDashboard',
    component: () => import('@/views/teacher/TeacherDashboard.vue'),
    meta: { requiresAuth: true, role: 'teacher' },
  },
  {
    path: '/student',
    name: 'StudentDashboard',
    component: () => import('@/views/student/StudentDashboard.vue'),
    meta: { requiresAuth: true, role: 'student' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()

  // 初始化用户信息 - 现在从 sessionStorage 读取
  if (!userStore.userInfo) {
    userStore.initFromStorage()
  }

  const isLoggedIn = userStore.isLoggedIn
  const userRole = userStore.userInfo?.role

  // 检查是否需要认证
  if (to.meta.requiresAuth && !isLoggedIn) {
    next('/login')
    return
  }

  // 检查是否要求未登录（如登录页面）
  if (to.meta.requiresGuest && isLoggedIn) {
    // 根据角色跳转到对应首页
    next(userRole === 'teacher' ? '/teacher' : '/student')
    return
  }

  // 检查角色权限
  if (to.meta.role && userRole !== to.meta.role) {
    // 角色不匹配，跳转到对应首页
    next(userRole === 'teacher' ? '/teacher' : '/student')
    return
  }

  next()
})

export default router
