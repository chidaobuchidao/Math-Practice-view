// src/utils/debug.js
export const debugUtils = {
  // 检查API响应结构
  inspectResponse(response, apiName) {
    console.group(`🔍 ${apiName} 响应检查`)
    console.log('完整响应:', response)
    console.log('响应数据:', response.data)
    console.log('状态码:', response.status)
    console.log('请求配置:', response.config)
    console.groupEnd()
  },
  
  // 检查用户数据格式
  checkUserData(userData) {
    console.group('👤 用户数据检查')
    console.log('用户数据:', userData)
    console.log('ID:', userData?.id)
    console.log('用户名:', userData?.username)
    console.log('角色:', userData?.role)
    console.log('班级:', userData?.userClass)
    console.groupEnd()
    
    return userData && userData.id && userData.username
  }
}