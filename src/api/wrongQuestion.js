import request from '@/utils/request'

// 错题集相关 API
export const wrongQuestionApi = {
  // 获取学生的错题列表
  getWrongQuestions(studentId) {
    console.log('调用 getWrongQuestions API，studentId:', studentId)
    return request.get(`/wrong-questions/student/${studentId}`)
  },

  // 从错题集中移除题目
  removeWrongQuestion(studentId, questionId) {
    return request.delete(`/wrong-questions/student/${studentId}/question/${questionId}`)
  },

  // 清空错题集
  clearWrongQuestions(studentId) {
    return request.delete(`/wrong-questions/student/${studentId}/clear`)
  },

  // 统计错题数量
  countWrongQuestions(studentId) {
    return request.get(`/wrong-questions/student/${studentId}/count`)
  }
}

export default wrongQuestionApi