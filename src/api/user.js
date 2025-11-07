import request from '@/utils/request'

export interface User {
  id?: number
  username: string
  password: string
  role: string
  userClass?: string
  createdAt?: string
}

export interface LoginRequest {
  username: string
  password: string
}

export interface ApiResponse<T = any> {
  success: boolean
  message: string
  data: T
}

// 用户登录
export const login = (data: LoginRequest): Promise<ApiResponse<User>> => {
  return request.post('/User/login', data)
}

// 用户注册
export const register = (data: User): Promise<ApiResponse> => {
  return request.post('/User/register', data)
}

// 获取用户列表
export const getUserList = (): Promise<ApiResponse<User[]>> => {
  return request.get('/User/list')
}

// 获取学生列表
export const getStudents = (): Promise<ApiResponse<User[]>> => {
  return request.get('/User/students')
}

// 获取老师列表
export const getTeachers = (): Promise<ApiResponse<User[]>> => {
  return request.get('/User/teachers')
}
