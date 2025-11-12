import request from '@/utils/request'

export const paperApi = {
  // 获取所有试卷
  getPapers() {
    return request.get('/papers/all')
  },

  // 获取所有试卷（同上）
  getAllPapers() {
    return request.get('/papers/all')
  },

  // 生成试卷
  generatePaper(data) {
    return request.post('/papers/generate', data)
  },

  // 获取试卷详情
  getPaperDetail(paperId) {
    return request.get(`/papers/${paperId}`)
  },

  // 删除试卷
  deletePaper(paperId) {
    return request.delete(`/papers/${paperId}`)
  },

  // 获取学生试卷
  getStudentPapers(studentId) {
    return request.get(`/papers/student/${studentId}`)
  },

  // 提交试卷答案
  submitPaper(paperId, data) {
    return request.post(`/papers/${paperId}/submit`, data)
  },
}

