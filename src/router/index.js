import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import StudentDashboard from '../views/StudentDashboard.vue'
import TeacherDashboard from '../views/TeacherDashboard.vue'

const routes = [
  {
    path: '/',
    redirect: '/login',
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
  },
  {
    path: '/student',
    name: 'StudentDashboard',
    component: StudentDashboard,
    meta: { requiresAuth: true, role: 'student' },
  },
  {
    path: '/teacher',
    name: 'TeacherDashboard',
    component: TeacherDashboard,
    meta: { requiresAuth: true, role: 'teacher' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 路由守卫 - 检查登录状态和角色
router.beforeEach((to, from, next) => {
  const userInfo = JSON.parse(localStorage.getItem('currentUser') || '{}')

  if (to.meta.requiresAuth) {
    if (!userInfo.id) {
      next('/login')
    } else if (to.meta.role && userInfo.role !== to.meta.role) {
      // 角色不匹配，跳转到对应角色的首页
      next(userInfo.role === 'student' ? '/student' : '/teacher')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
