/**
 * 活动记录工具函数
 * 提供简洁的API来记录教师活动
 */

// 活动类型常量
export const ACTIVITY_TYPES = {
  LOGIN: 'login',
  CREATE_QUESTION: 'create_question',
  UPDATE_QUESTION: 'update_question',
  DELETE_QUESTION: 'delete_question',
  GENERATE_PAPER: 'generate_paper',
  DELETE_PAPER: 'delete_paper',
  ADD_STUDENT: 'add_student',
  DELETE_STUDENT: 'delete_student',
}

// 模块类型常量
export const MODULE_TYPES = {
  QUESTION: 'question',
  PAPER: 'paper',
  STUDENT: 'student',
  SYSTEM: 'system',
}

// 存储教师信息组件引用的变量
let teacherInfoRef = null

/**
 * 设置教师信息组件引用
 * @param {Object} ref - 教师信息组件引用
 */
export const setTeacherInfoRef = (ref) => {
  teacherInfoRef = ref
}

/**
 * 记录活动
 * @param {string} type - 活动类型
 * @param {string} content - 活动内容
 * @param {string} module - 模块类型
 */
export const recordActivity = (type, content, module = MODULE_TYPES.SYSTEM) => {
  if (teacherInfoRef && teacherInfoRef.value && teacherInfoRef.value.recordActivity) {
    teacherInfoRef.value.recordActivity({
      type,
      content,
      module,
    })
  } else {
    console.warn('教师信息组件引用未找到，无法记录活动:', { type, content, module })
    // 可以选择将活动暂存，等组件可用时再记录
  }
}

/**
 * 记录题目相关活动
 */
export const questionLogger = {
  create: (content) =>
    recordActivity(
      ACTIVITY_TYPES.CREATE_QUESTION,
      `添加了新题目: ${content}`,
      MODULE_TYPES.QUESTION,
    ),
  update: (content) =>
    recordActivity(ACTIVITY_TYPES.UPDATE_QUESTION, `更新了题目: ${content}`, MODULE_TYPES.QUESTION),
  delete: (content) =>
    recordActivity(ACTIVITY_TYPES.DELETE_QUESTION, `删除了题目: ${content}`, MODULE_TYPES.QUESTION),
}

/**
 * 记录试卷相关活动
 */
export const paperLogger = {
  generate: (title, studentCount = 1) => {
    const target = studentCount > 1 ? `${studentCount}名学生` : '学生'
    recordActivity(
      ACTIVITY_TYPES.GENERATE_PAPER,
      `生成了试卷"${title}"给${target}`,
      MODULE_TYPES.PAPER,
    )
  },
  delete: (title) =>
    recordActivity(ACTIVITY_TYPES.DELETE_PAPER, `删除了试卷"${title}"`, MODULE_TYPES.PAPER),
}

/**
 * 记录学生相关活动
 */
export const studentLogger = {
  add: (username) =>
    recordActivity(ACTIVITY_TYPES.ADD_STUDENT, `添加了学生: ${username}`, MODULE_TYPES.STUDENT),
  delete: (username) =>
    recordActivity(ACTIVITY_TYPES.DELETE_STUDENT, `删除了学生: ${username}`, MODULE_TYPES.STUDENT),
}

/**
 * 记录系统活动
 */
export const systemLogger = {
  login: (username) =>
    recordActivity(ACTIVITY_TYPES.LOGIN, `教师 ${username} 登录系统`, MODULE_TYPES.SYSTEM),
}

export default {
  setTeacherInfoRef,
  recordActivity,
  questionLogger,
  paperLogger,
  studentLogger,
  systemLogger,
  ACTIVITY_TYPES,
  MODULE_TYPES,
}
