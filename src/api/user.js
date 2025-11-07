import request from '../utils/request' // 使用相对路径，避免别名解析问题

export function login(data) {
  return request.post('/User/login', data)
}

export function register(data) {
  return request.post('/User/register', data)
}

export function checkUsername(username) {
  return request.get(`/User/checkUsername?username=${username}`)
}

export function getStudents() {
  return request.get('/User/students')
}

export function getTeachers() {
  return request.get('/User/teachers')
}

export function addUser(data) {
  return request.post('/User/add', data)
}

export function deleteUser(userId) {
  return request.delete(`/User/delete/${userId}`)
}

// 兼容旧代码：默认/命名聚合导出
export const userApi = {
  login,
  register,
  checkUsername,
  getStudents,
  getTeachers,
  addUser,
  deleteUser,
}
