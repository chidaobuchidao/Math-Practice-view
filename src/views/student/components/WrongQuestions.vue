<template>
  <div class="wrong-questions">
    <div class="toolbar">
      <h3>我的错题集</h3>
      <div class="toolbar-actions">
        <el-button type="danger" @click="handleClearAll" :loading="clearing" :disabled="!isStudentIdValid">
          <el-icon>
            <Delete />
          </el-icon>
          清空错题集
        </el-button>
        <el-button type="primary" @click="generatePracticePaper" :loading="generating" :disabled="!isStudentIdValid">
          <el-icon>
            <Document />
          </el-icon>
          生成练习试卷
        </el-button>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="!isStudentIdValid" class="loading-state">
      <el-empty description="正在加载学生信息..." />
    </div>

    <!-- 错题集内容 -->
    <div v-else>
      <!-- 统计信息 -->
      <el-row :gutter="20" style="margin-bottom: 20px;">
        <el-col :span="6">
          <el-statistic title="错题总数" :value="wrongQuestions.length" />
        </el-col>
        <el-col :span="6" v-for="stat in typeStats" :key="stat.typeKey">
          <el-statistic :title="`${stat.typeName}错题`" :value="stat.count" />
        </el-col>
      </el-row>

      <!-- 错题类型统计饼图 -->
      <el-card style="margin-bottom: 20px;">
        <template #header>
          <div class="card-header">
            <span>错题类型分布</span>
          </div>
        </template>
        <div ref="chartRef" style="height: 300px; position: relative;">
          <div v-if="wrongQuestions.length === 0"
            style="position: absolute; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; color: #909399; top: 0; left: 0; z-index: 10; background: white;">
            暂无错题数据
          </div>
        </div>
      </el-card>

      <!-- 错题列表 -->
      <el-card>
        <template #header>
          <div class="card-header">
            <span>错题列表</span>
            <div class="header-actions">
              <el-select v-model="filterType" placeholder="按类型筛选" clearable style="width: 120px; margin-right: 10px;">
                <el-option v-for="type in uniqueTypes" :key="type" :label="getTypeText(type)" :value="type" />
              </el-select>
              <el-select v-model="filterDifficulty" placeholder="按难度筛选" clearable style="width: 120px;">
                <el-option v-for="diff in uniqueDifficulties" :key="diff" :label="getDifficultyText(diff)"
                  :value="diff" />
              </el-select>
            </div>
          </div>
        </template>

        <el-table :data="filteredWrongQuestions" v-loading="loading" style="width: 100%">
          <el-table-column prop="id" label="错题ID" width="100" align="center" />
          <el-table-column label="题目内容">
            <template #default="{ row }">
              <div class="question-content">
                <div class="question-text" v-html="row.content"></div>
                <!-- 显示题目图片 -->
                <div v-if="row.images && row.images.length > 0" class="question-images-list">
                  <img v-for="(img, idx) in row.images" :key="idx" 
                       :src="getImageUrl(img.imagePath || img.image_path)" 
                       class="question-image-thumb" 
                       @click="previewImage(img.imagePath || img.image_path)" />
                </div>
                <div class="question-meta">
                  <el-tag size="small" :type="getTypeTagType(row.type_id || row.type)">
                    {{ getTypeText(row.type_id || row.type) }}
                  </el-tag>
                  <el-tag size="small" :type="getDifficultyTagType(row.difficulty_id || row.difficulty)">
                    {{ getDifficultyText(row.difficulty_id || row.difficulty) }}
                  </el-tag>
                  <span class="wrong-answer">我的答案: {{ formatStudentAnswerWithContent(row) }}</span>
                  <span class="correct-answer">正确答案: {{ formatCorrectAnswerWithContent(row) }}</span>
                  <span class="record-time">记录时间: {{ formatDate(row.created_at) }}</span>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" align="center">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="reviewQuestion(row)">
                复习
              </el-button>
              <el-button type="danger" size="small" @click="handleRemoveWrongQuestion(row.question_id || row.id)">
                移除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <div v-if="filteredWrongQuestions.length === 0 && !loading" class="empty-state">
          <el-empty description="暂无错题记录" />
        </div>
      </el-card>

      <!-- 复习题目对话框 -->
      <el-dialog v-model="showReviewDialog" :title="`复习题目 - 第${reviewQuestionIndex + 1}题`" width="600px">
        <div v-if="currentReviewQuestion" class="review-content">
          <div class="question-header">
            <el-tag size="small" :type="getTypeTagType(currentReviewQuestion.type_id || currentReviewQuestion.type)">
              {{ getTypeText(currentReviewQuestion.type_id || currentReviewQuestion.type) }}
            </el-tag>
            <el-tag size="small"
              :type="getDifficultyTagType(currentReviewQuestion.difficulty_id || currentReviewQuestion.difficulty)">
              {{ getDifficultyText(currentReviewQuestion.difficulty_id || currentReviewQuestion.difficulty) }}
            </el-tag>
          </div>

          <div class="question-text" style="font-size: 16px; margin: 20px 0;">
            {{ currentReviewQuestion.content }}
          </div>

          <!-- 显示题目图片 -->
          <div v-if="currentReviewQuestion.images && currentReviewQuestion.images.length > 0" class="question-images" style="margin: 15px 0;">
            <img v-for="(img, idx) in currentReviewQuestion.images" :key="idx" 
                 :src="getImageUrl(img.imagePath)" 
                 class="question-image" 
                 @click="previewImage(img.imagePath)" />
          </div>

          <!-- 选择题：显示选项 -->
          <div v-if="isChoiceQuestion(currentReviewQuestion)" class="choice-options-section" style="margin: 20px 0;">
            <div class="options-label" style="font-weight: bold; margin-bottom: 10px;">选项：</div>
            <div v-for="option in getSortedOptions(currentReviewQuestion.options)" :key="option.optionKey" 
                 class="option-item" 
                 :class="{ 'correct-option': isCorrectOption(option.optionKey, currentReviewQuestion) }"
                 style="padding: 8px; margin: 5px 0; border: 1px solid #e4e7ed; border-radius: 4px;">
              <span class="option-key" style="font-weight: bold; margin-right: 8px;">{{ option.optionKey }}.</span>
              <span v-html="option.content"></span>
            </div>
          </div>

          <div class="answer-input" style="margin: 20px 0;">
            <el-input v-if="!isChoiceQuestion(currentReviewQuestion)" 
                      v-model="reviewAnswer" 
                      placeholder="请输入你的答案" 
                      style="width: 200px;" />
            <!-- 选择题：使用下拉选择 -->
            <el-select v-else 
                       v-model="reviewAnswer" 
                       placeholder="请选择答案" 
                       style="width: 200px;">
              <el-option 
                v-for="option in getSortedOptions(currentReviewQuestion.options)" 
                :key="option.optionKey" 
                :label="`${option.optionKey}. ${option.content}`" 
                :value="option.optionKey" />
            </el-select>
          </div>

          <div class="review-actions" style="margin-top: 20px;">
            <el-button @click="checkAnswer" type="primary" :disabled="!reviewAnswer || reviewAnswer.trim() === ''">
              检查答案
            </el-button>
            <el-button @click="showAnswer" type="text">
              显示答案
            </el-button>
          </div>

          <div v-if="showResult" class="result-section" style="margin-top: 20px;">
            <el-alert :title="resultMessage" :type="isAnswerCorrect ? 'success' : 'error'" :closable="false" show-icon>
            </el-alert>
            <div v-if="!isAnswerCorrect" style="margin-top: 10px;">
              <div style="color: #67c23a; font-weight: bold; margin-bottom: 5px;">
                正确答案: {{ formatCorrectAnswer(currentReviewQuestion.correct_answer || currentReviewQuestion.answer) }}
              </div>
              <!-- 选择题：显示正确答案对应的选项内容 -->
              <div v-if="isChoiceQuestion(currentReviewQuestion)" style="margin-top: 8px; padding: 8px; background: #f0f9ff; border-radius: 4px;">
                <div v-for="answerKey in getCorrectAnswerKeys(currentReviewQuestion)" :key="answerKey" style="margin: 5px 0;">
                  <strong>{{ answerKey }}.</strong> {{ getOptionContent(answerKey, currentReviewQuestion.options) }}
                </div>
              </div>
            </div>
            <div v-if="currentReviewQuestion.analysis"
              style="margin-top: 10px; padding: 10px; background: #f8f9fa; border-radius: 4px;">
              <strong>解析:</strong> {{ currentReviewQuestion.analysis }}
            </div>
          </div>
        </div>

        <template #footer>
          <el-button @click="showReviewDialog = false">关闭</el-button>
          <el-button v-if="reviewQuestions.length > 1" @click="nextQuestion" type="primary" :disabled="!showResult">
            {{ reviewQuestionIndex < reviewQuestions.length - 1 ? '下一题' : '完成复习' }} </el-button>
        </template>
      </el-dialog>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Delete, Document } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { wrongQuestionApi } from '@/api/wrongQuestion'
import { paperApi } from '@/api/paper'
import { questionApi } from '@/api/question'
import request from '@/utils/request'
import { getTypeName as utilGetTypeName, getTypeTagType as utilGetTypeTagType, getDifficultyName as utilGetDifficultyName, getDifficultyTagType as utilGetDifficultyTagType, getTypeTextByKey, getTypeTagTypeByKey, getDifficultyTextByKey, getDifficultyTagTypeByKey } from '@/utils/type'

const props = defineProps({
  studentId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['practice-generated'])

const loading = ref(false)
const clearing = ref(false)
const generating = ref(false)
const wrongQuestions = ref([])
const filterType = ref('')
const filterDifficulty = ref('')
const chartRef = ref(null)
let chartInstance = null

// 复习相关状态
const showReviewDialog = ref(false)
const reviewQuestions = ref([])
const reviewQuestionIndex = ref(0)
const currentReviewQuestion = ref(null)
const reviewAnswer = ref('')
const showResult = ref(false)
const isAnswerCorrect = ref(false)
const resultMessage = ref('')

// 计算属性：检查 studentId 是否有效
const isStudentIdValid = computed(() => {
  return props.studentId !== null && props.studentId !== undefined && props.studentId > 0
})

// 计算过滤后的错题列表
const filteredWrongQuestions = computed(() => {
  let filtered = wrongQuestions.value

  if (filterType.value !== null && filterType.value !== undefined && filterType.value !== '') {
    filtered = filtered.filter(q => {
      const qTypeKey = q.type_id || q.type
      // 直接比较 typeKey（数字或字符串）
      if (qTypeKey === filterType.value) {
        return true
      }
      // 如果 filterType.value 是数字或字符串，都能正确匹配
      return false
    })
  }

  if (filterDifficulty.value !== null && filterDifficulty.value !== undefined && filterDifficulty.value !== '') {
    filtered = filtered.filter(q => {
      const qDiffKey = q.difficulty_id || q.difficulty
      // 直接比较 diffKey（数字或字符串）
      if (qDiffKey === filterDifficulty.value) {
        return true
      }
      return false
    })
  }

  return filtered
})

// 获取所有唯一的类型
const uniqueTypes = computed(() => {
  const types = new Set()
  wrongQuestions.value.forEach(q => {
    const typeValue = q.type_id || q.type
    if (typeValue !== null && typeValue !== undefined) {
      types.add(typeValue)
    }
  })
  return Array.from(types).sort()
})

// 获取所有唯一的难度
const uniqueDifficulties = computed(() => {
  const difficulties = new Set()
  wrongQuestions.value.forEach(q => {
    const diffValue = q.difficulty_id || q.difficulty
    if (diffValue !== null && diffValue !== undefined) {
      difficulties.add(diffValue)
    }
  })
  return Array.from(difficulties).sort()
})

// 类型统计信息（用于统计栏）
const typeStats = computed(() => {
  const stats = {}
  wrongQuestions.value.forEach(q => {
    const typeKey = q.type_id || q.type
    if (typeKey !== null && typeKey !== undefined) {
      if (!stats[typeKey]) {
        stats[typeKey] = {
          typeKey,
          typeName: getTypeText(typeKey),
          count: 0
        }
      }
      stats[typeKey].count++
    }
  })
  return Object.values(stats).sort((a, b) => {
    if (typeof a.typeKey === 'number' && typeof b.typeKey === 'number') {
      return a.typeKey - b.typeKey
    }
    return String(a.typeKey).localeCompare(String(b.typeKey))
  })
})

// 加载错题列表
const loadWrongQuestions = async () => {
  if (!isStudentIdValid.value) {
    console.warn('studentId 无效，跳过加载错题列表')
    return
  }

  try {
    loading.value = true

    const response = await wrongQuestionApi.getWrongQuestions(props.studentId)
    wrongQuestions.value = response.data || []

    // 为选择题加载选项和图片（如果后端没有返回）
    for (const question of wrongQuestions.value) {
      const typeId = question.type_id || question.type
      const needsOptions = (typeId === 1 || typeId === 2) && (!question.options || question.options.length === 0)
      const needsImages = !question.images || question.images.length === 0
      
      // 如果需要加载选项或图片，则获取题目详情
      if (needsOptions || needsImages) {
        try {
          const detailResponse = await questionApi.getQuestionById(question.question_id || question.id)
          if (detailResponse.data) {
            if (needsOptions) {
              question.options = detailResponse.data.options || []
            }
            if (needsImages) {
              question.images = detailResponse.data.images || []
            }
          }
        } catch (error) {
          console.warn('加载题目详情失败:', error)
        }
      }
    }

    console.log('加载的错题数据:', wrongQuestions.value)

    // 数据更新会自动触发 watch，从而调用 forceRefreshChart()
  } catch (error) {
    ElMessage.error('加载错题列表失败: ' + (error.message || '未知错误'))
    wrongQuestions.value = []
  } finally {
    loading.value = false
  }
}

// 格式化学生答案显示（带选项内容）
const formatStudentAnswerWithContent = (question) => {
  const answer = question.wrong_answer
  if (answer === null || answer === undefined || answer === '') return '未作答'
  
  // 如果是选择题，显示选项键和内容
  if (isChoiceQuestion(question) && question.options && question.options.length > 0) {
    const answerKeys = Array.isArray(answer) ? answer : (typeof answer === 'string' && answer.includes(',') ? answer.split(',').map(s => s.trim()) : [String(answer)])
    const answerTexts = answerKeys.map(key => {
      const option = question.options.find(opt => (opt.optionKey || opt.option_key) === key)
      return option ? `${key}. ${option.content}` : key
    })
    return answerTexts.join(', ')
  }
  
  return String(answer)
}

// 格式化正确答案显示（带选项内容）
const formatCorrectAnswerWithContent = (question) => {
  const answer = question.correct_answer || question.answer
  if (answer === null || answer === undefined || answer === '') return '无答案'
  
  // 如果是选择题，显示选项键和内容
  if (isChoiceQuestion(question) && question.options && question.options.length > 0) {
    const answerKeys = Array.isArray(answer) ? answer : (typeof answer === 'string' && answer.includes(',') ? answer.split(',').map(s => s.trim()) : [String(answer)])
    const answerTexts = answerKeys.map(key => {
      const option = question.options.find(opt => (opt.optionKey || opt.option_key) === key)
      return option ? `${key}. ${option.content}` : key
    })
    return answerTexts.join(', ')
  }
  
  // 如果是数组，转换为逗号分隔的字符串
  if (Array.isArray(answer)) {
    return answer.join(', ')
  }
  return String(answer)
}

// 格式化学生答案显示（简单版本，用于其他地方）
const formatStudentAnswer = (answer) => {
  if (answer === null || answer === undefined || answer === '') return '未作答'
  return String(answer)
}

// 格式化正确答案显示（简单版本，用于其他地方）
const formatCorrectAnswer = (answer) => {
  if (answer === null || answer === undefined || answer === '') return '无答案'
  if (Array.isArray(answer)) {
    return answer.join(', ')
  }
  return String(answer)
}

// 解析答案（支持多种格式：数字、分数、文本等）
// 返回字符串格式，用于比较
const parseAnswer = (answer) => {
  if (answer === null || answer === undefined || answer === '') return null

  // 如果是数字，转换为字符串
  if (typeof answer === 'number') {
    return String(answer)
  }

  // 如果是字符串，直接返回（去除首尾空格）
  if (typeof answer === 'string') {
    return answer.trim()
  }

  // 其他类型转换为字符串
  return String(answer)
}

// 比较答案（支持字符串、数字、分数等多种格式）
const compareAnswers = (studentAnswer, correctAnswer) => {
  if (!studentAnswer || !correctAnswer) return false

  // 转换为字符串并去除首尾空格
  const studentStr = String(studentAnswer).trim()
  const correctStr = String(correctAnswer).trim()

  // 精确匹配（区分大小写）
  if (studentStr === correctStr) {
    return true
  }

  // 对于数字答案，进行数值比较（考虑浮点数精度）
  const studentNum = parseFloat(studentStr)
  const correctNum = parseFloat(correctStr)
  if (!isNaN(studentNum) && !isNaN(correctNum)) {
    // 如果都是有效数字，进行数值比较（考虑精度）
    return Math.abs(studentNum - correctNum) < 0.01
  }

  // 对于分数格式，进行分数比较
  if (studentStr.includes('/') && correctStr.includes('/')) {
    const studentParts = studentStr.split('/')
    const correctParts = correctStr.split('/')
    if (studentParts.length === 2 && correctParts.length === 2) {
      const studentNum = parseFloat(studentParts[0])
      const studentDen = parseFloat(studentParts[1])
      const correctNum = parseFloat(correctParts[0])
      const correctDen = parseFloat(correctParts[1])
      if (!isNaN(studentNum) && !isNaN(studentDen) && !isNaN(correctNum) && !isNaN(correctDen) && studentDen !== 0 && correctDen !== 0) {
        return Math.abs(studentNum / studentDen - correctNum / correctDen) < 0.01
      }
    }
  }

  // 不区分大小写的字符串比较
  if (studentStr.toLowerCase() === correctStr.toLowerCase()) {
    return true
  }

  return false
}

// 强制刷新图表（处理容器被销毁重建的情况）
const forceRefreshChart = () => {
  // 如果没有错题数据，不需要初始化图表
  if (wrongQuestions.value.length === 0) {
    console.log('没有错题数据，跳过图表初始化')
    return
  }

  // 如果实例存在，先销毁
  if (chartInstance) {
    try {
      chartInstance.dispose()
      chartInstance = null
      console.log('销毁旧图表实例')
    } catch (error) {
      console.error('销毁图表失败:', error)
    }
  }

  // 延迟后重新初始化（确保 DOM 已挂载并计算好尺寸）
  nextTick(() => {
    setTimeout(() => {
      console.log('准备调用 updateChart，chartRef 是否存在:', !!chartRef.value)
      updateChart()
    }, 500)
  })
}

// 更新饼图
const updateChart = () => {
  console.log('chartRef 尺寸 - height:', chartRef.value?.offsetHeight, 'width:', chartRef.value?.offsetWidth)

  if (!chartRef.value) {
    console.warn('chartRef.value 不存在，跳过图表更新')
    return
  }

  // 检查 DOM 是否可见 - 如果尺寸为 0，延迟重试
  if (chartRef.value.offsetHeight === 0 || chartRef.value.offsetWidth === 0) {
    setTimeout(() => {
      updateChart()
    }, 200)
    return
  }

  // 如果实例存在但 DOM 容器不同（容器被重新创建），需要重新初始化
  if (chartInstance && chartInstance.getDom() !== chartRef.value) {
    try {
      chartInstance.dispose()
      chartInstance = null
      console.log('旧图表实例已销毁，准备重新初始化')
    } catch (error) {
      console.error('销毁旧图表实例失败:', error)
      chartInstance = null
    }
  }

  if (!chartInstance) {
    try {
      chartInstance = echarts.init(chartRef.value)
      console.log('图表实例初始化成功')
    } catch (error) {
      console.error('初始化图表失败:', error)
      return
    }
  }

  // 统计各类型错题数量（完全动态）
  const typeData = {}

  wrongQuestions.value.forEach(question => {
    const typeText = getTypeText(question.type_id || question.type)
    if (!typeData[typeText]) {
      typeData[typeText] = { name: typeText, value: 0 }
    }
    typeData[typeText].value++
  })

  const chartData = Object.values(typeData).filter(item => item.value > 0)
  console.log('图表数据:', chartData)

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 10,
      top: 'center',
      data: chartData.map(item => item.name)
    },
    series: [
      {
        name: '错题类型',
        type: 'pie',
        radius: ['50%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: '18',
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: chartData
      }
    ]
  }

  try {
    chartInstance.setOption(option)
    console.log('图表配置设置成功')
  } catch (error) {
    console.error('设置图表配置失败:', error)
  }
}

// 移除错题
const handleRemoveWrongQuestion = async (questionId) => {
  if (!isStudentIdValid.value) {
    ElMessage.warning('学生信息无效，无法移除错题')
    return
  }

  try {
    await ElMessageBox.confirm('确定要从错题集中移除这道题目吗？', '确认移除', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await wrongQuestionApi.removeWrongQuestion(props.studentId, questionId)
    ElMessage.success('题目已从错题集中移除')
    // 移除成功后重新加载数据
    await loadWrongQuestions()
  } catch (error) {
    if (error.message && !error.message.includes('cancel')) {
      ElMessage.error('移除题目失败: ' + error.message)
    }
  }
}

// 清空错题集
const handleClearAll = async () => {
  if (!isStudentIdValid.value) {
    ElMessage.warning('学生信息无效，无法清空错题集')
    return
  }

  try {
    await ElMessageBox.confirm('确定要清空整个错题集吗？此操作不可恢复！', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    clearing.value = true
    await wrongQuestionApi.clearWrongQuestions(props.studentId)
    ElMessage.success('错题集已清空')
    loadWrongQuestions()
  } catch (error) {
    if (error.message && !error.message.includes('cancel')) {
      ElMessage.error('清空错题集失败: ' + error.message)
    }
  } finally {
    clearing.value = false
  }
}

// 生成练习试卷
const generatePracticePaper = async () => {
  if (!isStudentIdValid.value) {
    ElMessage.warning('学生信息无效，无法生成练习试卷')
    return
  }

  try {
    if (wrongQuestions.value.length === 0) {
      ElMessage.warning('错题集为空，无法生成练习试卷')
      return
    }

    generating.value = true

    const questionIds = wrongQuestions.value.map(q => q.question_id || q.id)
    const paperData = {
      title: `错题专项练习 - ${formatDate(new Date())}`,
      studentId: props.studentId,
      questionIds: questionIds.slice(0, 10) // 最多10道题
    }

    await paperApi.generatePaper(paperData)
    ElMessage.success('练习试卷生成成功！')

    // 通知父组件
    emit('practice-generated')

  } catch (error) {
    ElMessage.error('生成练习试卷失败: ' + error.message)
  } finally {
    generating.value = false
  }
}

// 判断是否为选择题
const isChoiceQuestion = (question) => {
  const typeId = question.type_id || question.type
  return typeId === 1 || typeId === 2
}

// 获取排序后的选项
const getSortedOptions = (options) => {
  if (!options || !Array.isArray(options)) return []
  return [...options].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
}

// 判断是否为正确答案选项
const isCorrectOption = (optionKey, question) => {
  const correctAnswer = question.correct_answer || question.answer
  if (!correctAnswer) return false
  if (Array.isArray(correctAnswer)) {
    return correctAnswer.includes(optionKey)
  }
  return String(correctAnswer) === String(optionKey)
}

// 获取正确答案的选项键列表
const getCorrectAnswerKeys = (question) => {
  const correctAnswer = question.correct_answer || question.answer
  if (!correctAnswer) return []
  if (Array.isArray(correctAnswer)) {
    return correctAnswer
  }
  if (typeof correctAnswer === 'string' && correctAnswer.includes(',')) {
    return correctAnswer.split(',').map(s => s.trim())
  }
  return [String(correctAnswer)]
}

// 根据选项键获取选项内容
const getOptionContent = (optionKey, options) => {
  if (!options || !Array.isArray(options)) return ''
  const option = options.find(opt => opt.optionKey === optionKey || opt.option_key === optionKey)
  return option?.content || ''
}

// 获取图片完整URL
const getImageUrl = (path) => {
  if (!path) return ''
  return path.startsWith('http') ? path : `${request.defaults.baseURL}${path}`
}

// 预览图片
const previewImage = (path) => {
  window.open(getImageUrl(path), '_blank')
}

// 复习题目
const reviewQuestion = async (question) => {
  // 如果是选择题且没有选项数据，加载题目详情
  if (isChoiceQuestion(question) && (!question.options || question.options.length === 0)) {
    try {
      const detailResponse = await questionApi.getQuestionById(question.question_id || question.id)
      if (detailResponse.data) {
        Object.assign(question, detailResponse.data)
      }
    } catch (error) {
      console.warn('加载题目详情失败:', error)
    }
  }
  
  reviewQuestions.value = [question]
  reviewQuestionIndex.value = 0
  currentReviewQuestion.value = question
  reviewAnswer.value = ''
  showResult.value = false
  isAnswerCorrect.value = false
  showReviewDialog.value = true
}

// 检查答案
const checkAnswer = () => {
  if (!reviewAnswer.value || reviewAnswer.value.trim() === '') {
    ElMessage.warning('请输入答案')
    return
  }

  // 获取正确答案
  const correctAnswer = currentReviewQuestion.value.correct_answer || currentReviewQuestion.value.answer

  if (!correctAnswer) {
    ElMessage.error('无法获取正确答案')
    return
  }

  // 使用新的比较函数进行答案比较
  isAnswerCorrect.value = compareAnswers(reviewAnswer.value, correctAnswer)

  if (isAnswerCorrect.value) {
    resultMessage.value = '回答正确！太棒了！'
    // 如果回答正确，自动从错题集中移除
    setTimeout(() => {
      handleRemoveWrongQuestion(currentReviewQuestion.value.question_id || currentReviewQuestion.value.id)
      showReviewDialog.value = false
    }, 1500)
  } else {
    resultMessage.value = '回答错误，再想想看！'
  }

  showResult.value = true
}

// 显示答案
const showAnswer = () => {
  const correctAnswer = currentReviewQuestion.value.correct_answer || currentReviewQuestion.value.answer
  if (correctAnswer !== null && correctAnswer !== undefined) {
    // 直接使用字符串格式的答案
    reviewAnswer.value = String(correctAnswer)
  }
  isAnswerCorrect.value = false
  resultMessage.value = '这是正确答案，请记住它！'
  showResult.value = true
}

// 下一题
const nextQuestion = () => {
  if (reviewQuestionIndex.value < reviewQuestions.value.length - 1) {
    reviewQuestionIndex.value++
    currentReviewQuestion.value = reviewQuestions.value[reviewQuestionIndex.value]
    reviewAnswer.value = ''
    showResult.value = false
    isAnswerCorrect.value = false
  } else {
    showReviewDialog.value = false
    ElMessage.success('复习完成！')
  }
}

// 统计各类型错题数量
const getTypeCount = (type) => {
  return wrongQuestions.value.filter(q => {
    const typeText = getTypeText(q.type_id || q.type)
    return typeText === type
  }).length
}

// 工具函数 - 智能映射，支持数字 id 和字符串 key
// 智能类型名称映射：支持数字 id 和字符串 key，统一委托到 utils/type.js
const getTypeText = (input) => {
  if (input === null || input === undefined || input === '') return '未知类型'
  if (typeof input === 'number') return utilGetTypeName(input)
  if (typeof input === 'string') {
    if (/^\d+$/.test(input)) return utilGetTypeName(parseInt(input))
    return getTypeTextByKey(input)
  }
  return String(input)
}

// 智能类型标签样式映射：支持数字 id 和字符串 key
const getTypeTagType = (input) => {
  if (input === null || input === undefined || input === '') return 'info'
  if (typeof input === 'number') return utilGetTypeTagType(input)
  if (typeof input === 'string') {
    if (/^\d+$/.test(input)) return utilGetTypeTagType(parseInt(input))
    return getTypeTagTypeByKey(input)
  }
  return 'info'
}

// 智能难度名称映射：支持数字 id 和字符串 key
const getDifficultyText = (input) => {
  if (input === null || input === undefined || input === '') return '未知难度'
  if (typeof input === 'number') return utilGetDifficultyName(input)
  if (typeof input === 'string') {
    if (/^\d+$/.test(input)) return utilGetDifficultyName(parseInt(input))
    return getDifficultyTextByKey(input)
  }
  return String(input)
}

// 智能难度标签样式映射：支持数字 id 和字符串 key
const getDifficultyTagType = (input) => {
  if (input === null || input === undefined || input === '') return 'info'
  if (typeof input === 'number') return utilGetDifficultyTagType(input)
  if (typeof input === 'string') {
    if (/^\d+$/.test(input)) return utilGetDifficultyTagType(parseInt(input))
    return getDifficultyTagTypeByKey(input)
  }
  return 'info'
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '未知'

  try {
    const date = new Date(dateString)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

// 定义 resize 事件处理函数（需要保持引用以便后续移除）
const handleWindowResize = () => {
  if (chartInstance) {
    try {
      chartInstance.resize()
    } catch (error) {
      console.error('图表 resize 失败:', error)
    }
  }
}

// 监听 studentId 变化
watch(
  () => props.studentId,
  (newStudentId) => {
    console.log('studentId 发生变化:', newStudentId, '当前错题数:', wrongQuestions.value.length)
    if (newStudentId && newStudentId > 0) {
      // 如果已经有错题数据，说明这是组件被重新挂载（比如从其他标签切回来）
      // 需要确保图表被重新初始化
      if (wrongQuestions.value.length > 0) {
        console.log('重新挂载时已有错题数据，强制刷新图表')
        nextTick(() => {
          setTimeout(() => {
            forceRefreshChart()
          }, 200)
        })
      } else {
        // 否则加载新数据
        loadWrongQuestions()
      }
    }
  },
  { immediate: true }
)

// 监听错题数据变化，重新渲染图表
watch(
  () => wrongQuestions.value.length,
  (newLength) => {
    console.log('wrongQuestions 数据长度变化:', newLength)
    // 当数据长度变化时，强制刷新图表
    // 注意：如果从 0 变为 > 0，DOM 被显示出来需要一个渲染周期
    nextTick(() => {
      setTimeout(() => {
        forceRefreshChart()
      }, 200)
    })
  }
)

onMounted(() => {
  console.log('WrongQuestions 组件已挂载, studentId:', props.studentId, '已有错题数:', wrongQuestions.value.length)

  // 监听窗口大小变化
  window.addEventListener('resize', handleWindowResize)

  // 如果 studentId 有效
  if (isStudentIdValid.value) {
    // 如果已经有错题数据（从缓存），立即初始化图表
    if (wrongQuestions.value.length > 0) {
      console.log('已有错题数据，立即初始化图表')
      nextTick(() => {
        setTimeout(() => {
          forceRefreshChart()
        }, 500)
      })
    } else {
      // 否则加载错题列表
      loadWrongQuestions()
    }
  }
})

// 处理 keep-alive 组件激活时的情况
import { onActivated, onDeactivated } from 'vue'
onActivated(() => {
  console.log('WrongQuestions 组件已激活（从隐藏状态恢复）')
  // 组件被激活时，重新调整图表大小并重新渲染
  if (chartInstance) {
    try {
      // 尝试调用 resize 来适应当前容器
      chartInstance.resize()
      console.log('图表已 resize')
    } catch (error) {
      console.warn('图表 resize 失败，重新初始化:', error)
      // 如果 resize 失败，销毁后重新初始化
      try {
        chartInstance.dispose()
      } catch (e) {
        console.error('销毁图表失败:', e)
      }
      chartInstance = null
      forceRefreshChart()
    }
  } else if (wrongQuestions.value.length > 0) {
    console.log('图表实例不存在，重新初始化')
    forceRefreshChart()
  }
})

onDeactivated(() => {
  console.log('WrongQuestions 组件已停用（被隐藏）')
  // 停用时保留图表实例，不销毁
})

// 组件卸载时销毁图表实例
import { onUnmounted } from 'vue'
onUnmounted(() => {
  console.log('WrongQuestions 组件卸载')
  // 移除 resize 事件监听
  window.removeEventListener('resize', handleWindowResize)

  // 销毁图表实例
  if (chartInstance) {
    try {
      chartInstance.dispose()
      chartInstance = null
      console.log('组件卸载时销毁图表')
    } catch (error) {
      console.error('销毁图表失败:', error)
      chartInstance = null
    }
  }

  // 清空数据，确保重新挂载时可以重新加载
  // 注意：不要清空 wrongQuestions，因为如果使用了 keep-alive 会需要它
})
</script>

<style scoped>
.wrong-questions {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.toolbar-actions {
  display: flex;
  gap: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.question-content {
  padding: 8px 0;
}

.question-text {
  font-size: 16px;
  font-weight: 500;
  margin-bottom: 8px;
}

.question-meta {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}

.wrong-answer {
  color: #f56c6c;
  font-size: 14px;
}

.correct-answer {
  color: #67c23a;
  font-size: 14px;
}

.record-time {
  color: #909399;
  font-size: 12px;
}

.empty-state {
  padding: 40px 0;
}

.loading-state {
  padding: 40px 0;
  text-align: center;
}

.review-content {
  padding: 10px;
}

.question-header {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.answer-input {
  margin: 20px 0;
}

.review-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.result-section {
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 8px;
}

.choice-options-section {
  margin: 20px 0;
}

.option-item {
  padding: 8px;
  margin: 5px 0;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  transition: all 0.3s;
}

.option-item:hover {
  background-color: #f5f7fa;
}

.option-item.correct-option {
  background-color: #f0f9ff;
  border-color: #67c23a;
}

.question-images {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin: 15px 0;
}

.question-image {
  max-width: 300px;
  max-height: 300px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
}

.question-image:hover {
  border-color: #409eff;
}

.question-images-list {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin: 10px 0;
}

.question-image-thumb {
  max-width: 150px;
  max-height: 150px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
  object-fit: contain;
}

.question-image-thumb:hover {
  border-color: #409eff;
  transform: scale(1.05);
  transition: all 0.3s;
}
</style>