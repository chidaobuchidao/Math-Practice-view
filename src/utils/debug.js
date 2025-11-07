// 调试工具
export const debug = {
  // 打印API请求信息
  logApiCall(url, data, response) {
    console.group('API调用调试')
    console.log('请求URL:', url)
    console.log('请求数据:', data)
    console.log('响应数据:', response)
    console.groupEnd()
  },
  
  // 检查本地存储
  checkStorage() {
    console.log('localStorage内容:', localStorage)
  },
  
  // 清除用户数据
  clearUserData() {
    localStorage.removeItem('currentUser')
    console.log('用户数据已清除')
  }
}