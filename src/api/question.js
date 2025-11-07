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
  
  // 获取题目选项
  getOptions() {
    return request.get('/questions/options')
  },
  
  // 添加题目
  addQuestion(data) {
    return request.post('/questions/add', data)
  },
  
  // 删除题目
  deleteQuestion(questionId) {
    return request.delete(`/questions/${questionId}`)
  }
}