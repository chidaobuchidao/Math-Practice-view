import request from '@/utils/request'

export const questionApi = {
  // 获取题目库（可按类型和难度筛选）
  getQuestionBank(params = {}) {
    return request.get('/questions/bank', { params })
  },

  // 获取所有题目
  getAllQuestions() {
    return request.get('/questions/all')
  },

  // 获取单个题目详情
  getQuestionById(questionId) {
    return request.get(`/questions/${questionId}`)
  },

  // 获取题目选项（类型和难度）
  getOptions() {
    return request.get('/questions/options')
  },

  // 添加题目
  addQuestion(data) {
    return request.post('/questions/add', data)
  },

  // 更新题目
  updateQuestion(questionId, data) {
    return request.put(`/questions/${questionId}`, data)
  },

  // 删除题目
  deleteQuestion(questionId) {
    return request.delete(`/questions/${questionId}`)
  },

  // 获取所有题目类型
  getQuestionTypes() {
    return request.get('/questions/types')
  },

  // 获取所有难度等级
  getDifficultyLevels() {
    return request.get('/questions/difficulties')
  },

  // 题目自动生成器
  generateQuestions: (data) => {
    return request.post('/api/questions/generate', data)
  },
  
  generateQuickQuestions: (count, createdBy) => {
    return request.post(`/api/questions/generate/quick?count=${count}&createdBy=${createdBy}`)
  },

  // 创建单选题
  createSingleChoiceQuestion(data) {
    return request.post('/api/choice-questions/single', data)
  },

  // 创建多选题
  createMultipleChoiceQuestion(data) {
    return request.post('/api/choice-questions/multiple', data)
  },

  // 更新选择题
  updateChoiceQuestion(questionId, data) {
    return request.put(`/api/choice-questions/${questionId}`, data)
  },

  // 获取选择题详情
  getChoiceQuestion(questionId) {
    return request.get(`/api/choice-questions/${questionId}`)
  }
}