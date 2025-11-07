import request from '@/utils/request'

export const userApi = {
  // 用户登录
  async login(data) {
    const response = await request.post('/User/login', data)
    return response
  },
  
  // 用户注册 - 添加更详细的错误处理
  async register(data) {
    try {
      const response = await request.post('/User/register', data)
      return response
    } catch (error) {
      console.error('注册API错误:', error)
      throw error
    }
  },
  
  // 检查用户名
  async checkUsername(username) {
    const response = await request.get(`/User/checkUsername?username=${username}`)
    return response
  },
  
  // 获取学生列表
  async getStudents() {
    const response = await request.get('/User/students')
    return response
  },
  
  // 获取教师列表
  async getTeachers() {
    const response = await request.get('/User/teachers')
    return response
  }
}