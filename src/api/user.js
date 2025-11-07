import request from '@/utils/request'

export const userApi = {
  // 用户登录
  login(data) {
    return request.post('/User/login', data)
  },
  
  // 用户注册
  register(data) {
    return request.post('/User/register', data)
  },
  
  // 检查用户名
  checkUsername(username) {
    return request.get(`/User/checkUsername?username=${username}`)
  },
  
  // 获取学生列表
  getStudents() {
    return request.get('/User/students')
  },
  
  // 获取教师列表
  getTeachers() {
    return request.get('/User/teachers')
  },
  
  // 添加用户
  addUser(data) {
    return request.post('/User/add', data)
  }
}