import { defineStore } from 'pinia'
import { ref , computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // 状态
  const userInfo = ref(null)
  const token = ref('')
  
  // getters
  const isLoggedIn = computed(() => !!userInfo.value)
  const isTeacher = computed(() => userInfo.value?.role === 'teacher')
  const isStudent = computed(() => userInfo.value?.role === 'student')
  
  // actions
  const setUserInfo = (info) => {
    userInfo.value = info
    // 同时保存到localStorage
    localStorage.setItem('currentUser', JSON.stringify(info))
  }
  
  const clearUserInfo = () => {
    userInfo.value = null
    token.value = ''
    localStorage.removeItem('currentUser')
  }
  
  // 初始化时从localStorage读取
  const initFromStorage = () => {
    const stored = localStorage.getItem('currentUser')
    if (stored) {
      userInfo.value = JSON.parse(stored)
    }
  }
  
  return {
    userInfo,
    token,
    isLoggedIn,
    isTeacher,
    isStudent,
    setUserInfo,
    clearUserInfo,
    initFromStorage
  }
})