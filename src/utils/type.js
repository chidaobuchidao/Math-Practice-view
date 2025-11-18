// 获取题目类型名称
export const getTypeName = (typeId) => {
  const typeMap = {
    1: '单选题',
    2: '多选题',
    3: '填空题',
    4: '判断题',
    5: '计算题',
    6: '解答题',
    7: '应用题'
  }
  return typeMap[typeId] || '未知类型'
}

// 获取题目难度名称
export const getDifficultyName = (difficultyId) => {
  const difficultyMap = {
    1: '入门',
    2: '简单',
    3: '中等',
    4: '困难',
    5: '挑战'
  }
  return difficultyMap[difficultyId] || '未知难度'
}

// 获取题目类型标签样式
export const getTypeTagType = (typeId) => {
  const typeMap = {
    1: 'success',
    2: 'primary',
    3: 'warning',
    4: 'info',
    5: 'danger',
    6: 'success',
    7: 'primary'
  }
  return typeMap[typeId] || 'info'
}

// 获取题目难度标签样式
export const getDifficultyTagType = (difficultyId) => {
  const difficultyMap = {
    1: 'info',
    2: 'success',
    3: 'warning',
    4: 'danger',
    5: 'danger'
  }
  return difficultyMap[difficultyId] || 'info'
}

// 以下为字符串键（例如错题集使用的 'AddAndSub' / 'easy'）的兼容工具函数
export const getTypeTextByKey = (key) => {
  const map = {
    'AddAndSub': '加减运算',
    'MulAndDiv': '乘除运算',
    'Mixed': '混合运算'
  }
  return map[key] || key
}

export const getTypeTagTypeByKey = (key) => {
  const map = {
    'AddAndSub': 'success',
    'MulAndDiv': 'primary',
    'Mixed': 'warning'
  }
  return map[key] || 'info'
}

export const getDifficultyTextByKey = (key) => {
  const map = {
    'easy': '简单',
    'medium': '中等',
    'hard': '困难'
  }
  return map[key] || key
}

export const getDifficultyTagTypeByKey = (key) => {
  const map = {
    'easy': 'success',
    'medium': 'warning',
    'hard': 'danger'
  }
  return map[key] || 'info'
}