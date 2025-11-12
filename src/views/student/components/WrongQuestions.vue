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
        <el-col :span="6">
          <el-statistic title="加减运算错题" :value="getTypeCount('AddAndSub')" />
        </el-col>
        <el-col :span="6">
          <el-statistic title="乘除运算错题" :value="getTypeCount('MulAndDiv')" />
        </el-col>
        <el-col :span="6">
          <el-statistic title="混合运算错题" :value="getTypeCount('Mixed')" />
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
          <div v-if="wrongQuestions.length === 0" style="position: absolute; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; color: #909399; top: 0; left: 0; z-index: 10; background: white;">
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
                <el-option label="加减运算" value="AddAndSub" />
                <el-option label="乘除运算" value="MulAndDiv" />
                <el-option label="混合运算" value="Mixed" />
              </el-select>
              <el-select v-model="filterDifficulty" placeholder="按难度筛选" clearable style="width: 120px;">
                <el-option label="简单" value="easy" />
                <el-option label="中等" value="medium" />
                <el-option label="困难" value="hard" />
              </el-select>
            </div>
          </div>
        </template>

        <el-table :data="filteredWrongQuestions" v-loading="loading" style="width: 100%">
          <el-table-column prop="id" label="错题ID" width="100" align="center" />
          <el-table-column label="题目内容">
            <template #default="{ row }">
              <div class="question-content">
                <div class="question-text">{{ row.content }}</div>
                <div class="question-meta">
                  <el-tag size="small" :type="getTypeTagType(row.type)">
                    {{ getTypeText(row.type) }}
                  </el-tag>
                  <el-tag size="small" :type="getDifficultyTagType(row.difficulty)">
                    {{ getDifficultyText(row.difficulty) }}
                  </el-tag>
                  <span class="wrong-answer">我的答案: {{ row.wrong_answer || '未作答' }}</span>
                  <span class="correct-answer">正确答案: {{ row.answer }}</span>
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
              <el-button type="danger" size="small" @click="handleRemoveWrongQuestion(row.question_id)">
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
            <el-tag size="small" :type="getTypeTagType(currentReviewQuestion.type)">
              {{ getTypeText(currentReviewQuestion.type) }}
            </el-tag>
            <el-tag size="small" :type="getDifficultyTagType(currentReviewQuestion.difficulty)">
              {{ getDifficultyText(currentReviewQuestion.difficulty) }}
            </el-tag>
          </div>
          
          <div class="question-text" style="font-size: 16px; margin: 20px 0;">
            {{ currentReviewQuestion.content }}
          </div>

          <div class="answer-input">
            <el-input-number 
              v-model="reviewAnswer" 
              :precision="2"
              placeholder="请输入你的答案" 
              style="width: 200px;"
              :controls="false" />
          </div>

          <div class="review-actions" style="margin-top: 20px;">
            <el-button @click="checkAnswer" type="primary" :disabled="!reviewAnswer">
              检查答案
            </el-button>
            <el-button @click="showAnswer" type="link">
              显示答案
            </el-button>
          </div>

          <div v-if="showResult" class="result-section" style="margin-top: 20px;">
            <el-alert 
              :title="resultMessage" 
              :type="isAnswerCorrect ? 'success' : 'error'"
              :closable="false"
              show-icon>
            </el-alert>
            <div v-if="!isAnswerCorrect" style="margin-top: 10px;">
              <span style="color: #67c23a;">正确答案: {{ currentReviewQuestion.answer }}</span>
            </div>
          </div>
        </div>

        <template #footer>
          <el-button @click="showReviewDialog = false">关闭</el-button>
          <el-button 
            v-if="reviewQuestions.length > 1"
            @click="nextQuestion" 
            type="primary"
            :disabled="!showResult">
            {{ reviewQuestionIndex < reviewQuestions.length - 1 ? '下一题' : '完成复习' }}
          </el-button>
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
const reviewAnswer = ref(null)
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

  if (filterType.value) {
    filtered = filtered.filter(q => q.type === filterType.value)
  }

  if (filterDifficulty.value) {
    filtered = filtered.filter(q => q.difficulty === filterDifficulty.value)
  }

  return filtered
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
       
    // 数据更新会自动触发 watch，从而调用 forceRefreshChart()
  } catch (error) {
    ElMessage.error('加载错题列表失败: ' + (error.message || '未知错误'))
    wrongQuestions.value = []
  } finally {
    loading.value = false
  }
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
  // 使用更长的延迟确保布局完成
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

  // 统计各类型错题数量
  const typeData = {
    'AddAndSub': { name: '加减运算', value: 0 },
    'MulAndDiv': { name: '乘除运算', value: 0 },
    'Mixed': { name: '混合运算', value: 0 }
  }

  wrongQuestions.value.forEach(question => {
    if (typeData[question.type]) {
      typeData[question.type].value++
    }
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

    const questionIds = wrongQuestions.value.map(q => q.question_id)
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

// 复习题目
const reviewQuestion = (question) => {
  reviewQuestions.value = [question]
  reviewQuestionIndex.value = 0
  currentReviewQuestion.value = question
  reviewAnswer.value = null
  showResult.value = false
  showReviewDialog.value = true
}

// 检查答案
const checkAnswer = () => {
  if (reviewAnswer.value === null || reviewAnswer.value === undefined) {
    ElMessage.warning('请输入答案')
    return
  }

  const correctAnswer = currentReviewQuestion.value.answer
  isAnswerCorrect.value = Math.abs(reviewAnswer.value - correctAnswer) < 0.01
  
  if (isAnswerCorrect.value) {
    resultMessage.value = '回答正确！太棒了！'
    // 如果回答正确，自动从错题集中移除
    setTimeout(() => {
      handleRemoveWrongQuestion(currentReviewQuestion.value.question_id)
    }, 1000)
  } else {
    resultMessage.value = '回答错误，再想想看！'
  }
  
  showResult.value = true
}

// 显示答案
const showAnswer = () => {
  reviewAnswer.value = currentReviewQuestion.value.answer
  isAnswerCorrect.value = false
  resultMessage.value = '这是正确答案，请记住它！'
  showResult.value = true
}

// 下一题
const nextQuestion = () => {
  if (reviewQuestionIndex.value < reviewQuestions.value.length - 1) {
    reviewQuestionIndex.value++
    currentReviewQuestion.value = reviewQuestions.value[reviewQuestionIndex.value]
    reviewAnswer.value = null
    showResult.value = false
  } else {
    showReviewDialog.value = false
    ElMessage.success('复习完成！')
  }
}

// 统计各类型错题数量
const getTypeCount = (type) => {
  return wrongQuestions.value.filter(q => q.type === type).length
}

// 工具函数
const getTypeText = (type) => {
  const map = {
    'AddAndSub': '加减运算',
    'MulAndDiv': '乘除运算',
    'Mixed': '混合运算'
  }
  return map[type] || type
}

const getTypeTagType = (type) => {
  const map = {
    'AddAndSub': 'success',
    'MulAndDiv': 'primary',
    'Mixed': 'warning'
  }
  return map[type] || 'info'
}

const getDifficultyText = (difficulty) => {
  const map = {
    'easy': '简单',
    'medium': '中等',
    'hard': '困难'
  }
  return map[difficulty] || difficulty
}

const getDifficultyTagType = (difficulty) => {
  const map = {
    'easy': 'success',
    'medium': 'warning',
    'hard': 'danger'
  }
  return map[difficulty] || 'info'
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
</style>