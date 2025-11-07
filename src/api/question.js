import request from '@/utils/request'

export const questionApi = {
  // 获取题目库
  getQuestionBank(params = {}) {
    return request.get('/questions/bank', { params })
  },

  // 获取所有题目
  getAllQuestions() {
    return request.get('/questions/all')
  },
  // 获取单个题目详情（新增）
  getQuestionById(questionId) {
    return request.get(`/questions/${questionId}`)
  },

  // 获取题目选项
  getOptions() {
    return request.get('/questions/options')
  },

  // 添加题目
  addQuestion(data) {
    return request.post('/questions/add', data)
  },

  // 更新题目（新增）
  updateQuestion(questionId, data) {
    return request.put(`/questions/${questionId}`, data)
  },
  // 删除题目
  deleteQuestion(questionId) {
    return request.delete(`/questions/${questionId}`)
  },
}
