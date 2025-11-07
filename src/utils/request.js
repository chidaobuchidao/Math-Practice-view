import axios from 'axios'
import { ElMessage } from 'element-plus'

// 创建axios实例
const request = axios.create({
  baseURL: 'http://localhost:8080',
  timeout: 10000,
})

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    // 可以在这里添加token等
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器 - 改进错误处理
request.interceptors.response.use(
  (response) => {
    const res = response.data
    
    console.log('API响应:', response.config.url, res) // 调试信息

    // 根据你的后端响应格式调整
    if (res.code === 200) {
      return res
    } else {
      // 登录失败时，后端可能返回 { code: 错误码, message: "用户名或密码错误", data: null }
      const errorMsg = res.message || '请求失败'
      ElMessage.error(errorMsg)
      return Promise.reject(new Error(errorMsg))
    }
  },
  (error) => {
    console.error('请求错误详情:', error)
    
    if (error.response) {
      // 服务器返回错误状态码
      const status = error.response.status
      const message = error.response.data?.message || error.response.data || '请求失败'
      
      switch (status) {
        case 400:
          ElMessage.error('请求参数错误: ' + message)
          break
        case 401:
          ElMessage.error('认证失败: ' + message)
          break
        case 404:
          ElMessage.error('请求接口不存在')
          break
        case 500:
          ElMessage.error('服务器内部错误: ' + message)
          break
        default:
          ElMessage.error(`错误 ${status}: ${message}`)
      }
    } else if (error.request) {
      // 请求发出但没有收到响应
      ElMessage.error('网络连接失败，请检查网络连接或后端服务是否启动')
    } else {
      // 其他错误
      ElMessage.error(error.message || '请求配置错误')
    }
    
    return Promise.reject(error)
  }
)

export default request