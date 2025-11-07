import request from '@/utils/request'

export const paperApi = {
  // 生成试卷
  generatePaper(data) {
    return request.post('/papers/generate', data)
  },
  
  // 获取学生试卷列表
  getStudentPapers(studentId) {
    return request.get(`/papers/student/${studentId}`)
  },
  
  // 获取试卷详情
  getPaperDetail(paperId) {
    return request.get(`/papers/${paperId}`)
  },
  
  // 删除试卷
  deletePaper(paperId) {
    return request.delete(`/papers/${paperId}`)
  }
}