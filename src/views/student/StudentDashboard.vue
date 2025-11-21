<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
    CircleClose,
    Document,
    CircleCheck,
    Clock,
    Star,
    Refresh,
    Warning,
    TrendCharts,
    EditPen
} from '@element-plus/icons-vue'
import { paperApi } from '@/api/paper'
import { wrongQuestionApi } from '@/api/wrongQuestion'
import { questionApi } from '@/api/question'
import { useUserStore } from '@/stores/user'
import WrongQuestions from './components/WrongQuestions.vue'
import { getTypeName, getDifficultyName, getTypeTagType, getDifficultyTagType, getTypeTextByKey } from '@/utils/type'
import request from '@/utils/request'

const router = useRouter()
const userStore = useUserStore()
const userInfo = ref({})
const papers = ref([])
const loading = ref(false)
const showPaperDialog = ref(false)
const submitting = ref(false)
const currentPaper = ref(null)
const currentPaperDetail = ref(null)
const studentAnswers = ref({})
const examTime = ref(0)
const activeTab = ref('papers')
let timer = null

// 获取图片完整URL
const getImageUrl = (path) => {
  if (!path) return ''
  return path.startsWith('http') ? path : `${request.defaults.baseURL}${path}`
}

// 预览图片
const previewImage = (path) => {
  window.open(getImageUrl(path), '_blank')
}

// 错题统计
const wrongQuestionStats = ref({
    total: 0,
    weakType: '',
    practiceCount: 0
})

// 统计
const paperStats = computed(() => {
    const total = papers.value.length
    const completed = papers.value.filter(p => p.score !== null && p.score !== undefined).length
    const pending = total - completed
    const completedPapers = papers.value.filter(p => p.score !== null && p.score !== undefined)
    const avgScore = completedPapers.length > 0
        ? Math.round(completedPapers.reduce((sum, p) => sum + (p.score || 0), 0) / completedPapers.length)
        : 0

    return { total, completed, pending, avgScore }
})

// 获取排序后的选项（按sortOrder排序）
const getSortedOptions = (options) => {
  if (!options || !Array.isArray(options)) return []
  return [...options].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
}

const answeredCount = computed(() => {
    return Object.values(studentAnswers.value).filter(answer => {
        if (answer === null || answer === undefined) return false
        if (typeof answer === 'string' && answer.trim() === '') return false
        if (Array.isArray(answer) && answer.length === 0) return false
        return true
    }).length
})

const formatExamTime = computed(() => {
    const minutes = Math.floor(examTime.value / 60)
    const seconds = examTime.value % 60
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
})

// 增强题目信息，获取完整详情（包括选项、答案、图片）
const enhanceQuestionsWithDetails = async (questions) => {
    for (const question of questions) {
        if (!question.options || !question.images) {
            try {
                const detail = await questionApi.getQuestionById(question.id)
                if (detail.data) {
                    const studentAnswer = question.studentAnswer
                    Object.assign(question, detail.data)
                    question.studentAnswer = studentAnswer
                }
            } catch (error) {
                console.warn(`获取题目 ${question.id} 详情失败:`, error)
            }
        }
    }
}

// 加载学生试卷
const loadPapers = async () => {
    try {
        loading.value = true
        const response = await paperApi.getStudentPapers(userInfo.value.id)
        papers.value = response.data || []
    } catch (error) {
        ElMessage.error('加载试卷失败: ' + error.message)
        papers.value = []
    } finally {
        loading.value = false
    }
}

// 加载错题统计
const loadWrongQuestionStats = async () => {
    try {
        const response = await wrongQuestionApi.getWrongQuestions(userInfo.value.id)
        const wrongQuestions = response.data || []

        wrongQuestionStats.value.total = wrongQuestions.length

        // 计算薄弱题型
        const typeCount = {}
        wrongQuestions.forEach(q => {
            const typeKey = q.type_id || q.type
            if (typeKey !== null && typeKey !== undefined && typeKey !== '') {
                typeCount[typeKey] = (typeCount[typeKey] || 0) + 1
            }
        })

        let maxCount = 0
        let weakType = ''
        const getTypeText = (input) => {
            if (input === null || input === undefined || input === '') return '未知类型'
            if (typeof input === 'number') return getTypeName(input)
            if (typeof input === 'string') {
                if (/^\d+$/.test(input)) return getTypeName(parseInt(input))
                return getTypeTextByKey(input)
            }
            return String(input)
        }

        Object.keys(typeCount).forEach(type => {
            if (typeCount[type] > maxCount) {
                maxCount = typeCount[type]
                weakType = getTypeText(type)
            }
        })

        wrongQuestionStats.value.weakType = weakType
        wrongQuestionStats.value.practiceCount = Math.min(wrongQuestions.length, 10)

    } catch (error) {
        console.error('加载错题统计失败:', error)
    }
}

// 从错题集生成练习试卷
const generatePracticeFromWrongQuestions = async () => {
    try {
        const response = await wrongQuestionApi.getWrongQuestions(userInfo.value.id)
        const wrongQuestions = response.data || []

        if (wrongQuestions.length === 0) {
            ElMessage.warning('错题集为空，无法生成练习试卷')
            return
        }

        const questionIds = wrongQuestions.map(q => q.question_id).slice(0, 10)
        const paperData = {
            title: `错题专项练习 - ${formatDate(new Date())}`,
            studentId: userInfo.value.id,
            questionIds: questionIds
        }

        const paperResponse = await paperApi.generatePaper(paperData)
        ElMessage.success('练习试卷生成成功！')

        await loadPapers()

        ElMessageBox.confirm('练习试卷已生成，是否立即开始答题？', '提示', {
            confirmButtonText: '开始答题',
            cancelButtonText: '稍后再说',
            type: 'success'
        }).then(() => {
            const newPaper = papers.value.find(p => p.id === paperResponse.data.id)
            if (newPaper) {
                startPaper(newPaper)
            }
        })

    } catch (error) {
        ElMessage.error('生成练习试卷失败: ' + error.message)
    }
}

// 处理练习试卷生成事件
const handlePracticeGenerated = () => {
    loadPapers()
    activeTab.value = 'papers'
}

// 开始答题
const startPaper = async (paper) => {
    try {
        if (paper.score !== null && paper.score !== undefined) {
            ElMessage.warning('该试卷已完成，无法再次答题')
            return
        }

        const response = await paperApi.getPaperDetail(paper.id)
        currentPaperDetail.value = response.data
        currentPaper.value = paper

        studentAnswers.value = {}

        // 初始化学生答案（选择题使用选项键A/B/C/D，其他类型使用字符串）
        if (currentPaperDetail.value.questions) {
            currentPaperDetail.value.questions.forEach(question => {
                const answerValue = question.studentAnswer
                if (question.typeId === 2) {
                    // 多选题：选项键数组（如 ['A', 'B']）
                    if (answerValue !== null && answerValue !== undefined) {
                        studentAnswers.value[question.id] = Array.isArray(answerValue) 
                            ? answerValue 
                            : (typeof answerValue === 'string' && answerValue ? answerValue.split(',').map(s => s.trim()) : [])
                    } else {
                        studentAnswers.value[question.id] = []
                    }
                } else if (question.typeId === 1) {
                    // 单选题：选项键字符串（如 'A'）
                    studentAnswers.value[question.id] = answerValue !== null && answerValue !== undefined ? String(answerValue) : ''
                } else {
                    // 其他类型：字符串
                    studentAnswers.value[question.id] = answerValue !== null && answerValue !== undefined ? String(answerValue) : ''
                }
            })
        }

        examTime.value = 0
        timer = setInterval(() => {
            examTime.value++
        }, 1000)

        showPaperDialog.value = true
    } catch (error) {
        ElMessage.error('加载试卷详情失败: ' + error.message)
    }
}

// 答案变化处理
const handleAnswerChange = (questionId) => {
    console.log(`题目 ${questionId} 答案更新为:`, studentAnswers.value[questionId])
}

// 提交试卷
const submitPaper = async () => {
    try {
        if (answeredCount.value < currentPaper.value.totalQuestions) {
            ElMessage.warning(`请完成所有题目后再提交！还有 ${currentPaper.value.totalQuestions - answeredCount.value} 题未作答`)
            return
        }

        submitting.value = true

        // 格式化答案：选择题使用选项键，其他类型使用字符串
        const formattedAnswers = {}
        Object.keys(studentAnswers.value).forEach(questionId => {
            const answer = studentAnswers.value[questionId]
            const question = currentPaperDetail.value.questions.find(q => q.id === parseInt(questionId))
            
            if (answer !== null && answer !== undefined && answer !== '') {
                if (question && (question.typeId === 1 || question.typeId === 2)) {
                    // 选择题：多选题转换为逗号分隔的选项键字符串
                    formattedAnswers[questionId] = question.typeId === 2 && Array.isArray(answer)
                        ? answer.filter(a => a).join(',')
                        : String(answer)
                } else {
                    // 其他类型：去除首尾空格
                    formattedAnswers[questionId] = String(answer).trim()
                }
            } else {
                formattedAnswers[questionId] = ''
            }
        })

        const submitData = {
            answers: formattedAnswers,
            timeSpent: examTime.value
        }

        console.log('提交试卷数据:', submitData)

        const response = await paperApi.submitPaper(currentPaper.value.id, submitData)

        const score = response.data.score ? Math.round(response.data.score) : 0
        ElMessage.success(`试卷提交成功！得分: ${score}分`)
        showPaperDialog.value = false

        if (timer) {
            clearInterval(timer)
            timer = null
        }

        await loadPapers()
        await loadWrongQuestionStats()
    } catch (error) {
        console.error('提交试卷错误:', error)
        
        // 检查是否是类型转换错误
        if (error.message && error.message.includes('Cannot deserialize value of type')) {
            ElMessage.error('提交失败：后端暂不支持文本类型答案，请联系管理员更新后端接口以支持字符串类型答案')
        } else {
            ElMessage.error('提交试卷失败: ' + (error.message || '网络错误'))
        }
    } finally {
        submitting.value = false
    }
}

// 查看试卷详情 - 关键修改
const viewPaperDetail = async (paper) => {
    try {
        const response = await paperApi.getPaperDetail(paper.id)
        currentPaperDetail.value = response.data
        currentPaper.value = paper

        console.log('试卷详情数据:', currentPaperDetail.value)

        // 重新初始化学生答案 - 从试卷详情中获取
        studentAnswers.value = {}
        if (currentPaperDetail.value.questions) {
            currentPaperDetail.value.questions.forEach(question => {
                // 获取学生答案：优先从 question.studentAnswer 获取
                let answerValue = question.studentAnswer
                
                // 如果 studentAnswer 不存在，尝试从其他位置获取
                if ((answerValue === null || answerValue === undefined) && question.paper_question) {
                    answerValue = question.paper_question.student_answer
                }
                
                // 根据题目类型处理答案格式（选择题使用选项键）
                if (answerValue !== null && answerValue !== undefined) {
                    // 处理数字类型（后端可能返回数字，需要转换为选项键）
                    if (typeof answerValue === 'number') {
                        if (question.typeId === 1 || question.typeId === 2) {
                            // 选择题：将数字转换为选项键（1=A, 2=B, 3=C, 4=D）
                            const optionIndex = Math.round(answerValue)
                            if (optionIndex >= 1 && optionIndex <= 26) {
                                answerValue = String.fromCharCode(65 + optionIndex - 1) // 'A' + index - 1
                            }
                        }
                    }
                    
                    if (question.typeId === 2) {
                        // 多选题：选项键数组（如 ['A', 'B']）
                        studentAnswers.value[question.id] = Array.isArray(answerValue) 
                            ? answerValue 
                            : (typeof answerValue === 'string' && answerValue ? answerValue.split(',').map(s => s.trim()) : [])
                    } else if (question.typeId === 1) {
                        // 单选题：选项键字符串（如 'A'）
                        studentAnswers.value[question.id] = String(answerValue)
                    } else {
                        // 其他类型：字符串或数字
                        studentAnswers.value[question.id] = String(answerValue)
                    }
                } else {
                    // 多选题初始化为空数组，其他类型初始化为空字符串
                    studentAnswers.value[question.id] = question.typeId === 2 ? [] : ''
                }
            })
        }

        console.log('学生答案数据:', studentAnswers.value)

        // 增强题目信息，获取正确答案等
        if (currentPaperDetail.value.questions) {
            await enhanceQuestionsWithDetails(currentPaperDetail.value.questions)
        }

        showPaperDialog.value = true
    } catch (error) {
        ElMessage.error('加载试卷详情失败: ' + error.message)
    }
}
// 获取题目正确答案（统一返回字符串格式）
const getQuestionAnswer = (answers) => {
    if (!answers || answers.length === 0) return '无答案'

    // 查找正确答案（isCorrect为true的答案）
    const correctAnswer = answers.find(answer => answer.isCorrect)
    if (correctAnswer) {
        // 统一转换为字符串格式，支持所有类型的答案
        return String(correctAnswer.content || '')
    }

    // 如果没有标记正确答案，返回第一个答案
    const firstAnswer = answers[0]?.content
    return firstAnswer !== null && firstAnswer !== undefined ? String(firstAnswer) : '无答案'
}

// 格式化正确答案用于显示
const formatCorrectAnswerForDisplay = (question) => {
    if (!question) return '无答案'
    if (question.typeId === 1 || question.typeId === 2) {
        const correctAnswers = question.answers?.filter(a => a.isCorrect)?.map(a => a.content) || []
        return question.typeId === 1 ? (correctAnswers[0] || '无答案') : correctAnswers.sort().join(', ')
    }
    return question.answers?.find(a => a.isCorrect)?.content || '无答案'
}

// 格式化学生答案用于显示
// 格式化得分（保留整数）
const formatScore = (score) => {
    if (score === null || score === undefined) return 0
    return Math.round(Number(score))
}

// 格式化学生答案用于显示（支持选择题）
const formatStudentAnswerForDisplay = (studentAnswer, question) => {
    // 检查答案是否为空
    if (studentAnswer === null || studentAnswer === undefined || 
        studentAnswer === '' || 
        (Array.isArray(studentAnswer) && studentAnswer.length === 0)) {
        return '未作答'
    }
    
    // 处理选择题
    if (question && (question.typeId === 1 || question.typeId === 2)) {
        // 如果是数字，转换为选项键（1=A, 2=B, 3=C, 4=D）
        if (typeof studentAnswer === 'number') {
            const optionIndex = Math.round(studentAnswer)
            if (optionIndex >= 1 && optionIndex <= 26) {
                return String.fromCharCode(65 + optionIndex - 1)
            }
        }
        return Array.isArray(studentAnswer) ? studentAnswer.sort().join(', ') : String(studentAnswer)
    }
    
    return String(studentAnswer)
}

// 工具函数
const getStatusType = (paper) => {
    if (paper.score !== null && paper.score !== undefined) return 'success'
    return 'warning'
}

const getStatusText = (paper) => {
    if (paper.score !== null && paper.score !== undefined) return '已完成'
    return '待完成'
}

const formatTime = (seconds) => {
    if (!seconds) return '0秒'
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    if (minutes > 0) {
        return `${minutes}分${remainingSeconds}秒`
    }
    return `${remainingSeconds}秒`
}

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

// 使用工具函数库提供的类型/难度映射和标签样式
const getTypeText = getTypeName

const handleLogout = async () => {
    try {
        await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
        })

        userStore.clearUserInfo()
        ElMessage.success('已退出登录')
        router.push('/login?_=' + Date.now())
    } catch {
        // 用户取消退出
    }
}

onMounted(() => {
    if (!userStore.isLoggedIn) {
        router.push('/login')
        return
    }
    userInfo.value = userStore.userInfo
    loadPapers()
    loadWrongQuestionStats()
})
</script>

<template>
    <div class="student-dashboard">
        <el-container>
            <el-header class="header">
                <div class="header-content">
                    <h2>学生学习中心</h2>
                    <div class="user-info">
                        <span>欢迎，{{ userInfo.username }}</span>
                        <el-button type="primary" :icon="CircleClose" @click="handleLogout">退出登录</el-button>
                    </div>
                </div>
            </el-header>

            <el-main>
                <!-- 统计卡片 -->
                <el-row :gutter="20">
                    <el-col :span="6">
                        <el-card class="stats-card">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #ecf5ff;">
                                    <el-icon>
                                        <Document />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ paperStats.total }}</div>
                                    <div class="stats-label">总试卷数</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>

                    <el-col :span="6">
                        <el-card class="stats-card">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #f0f9ff;">
                                    <el-icon>
                                        <CircleCheck />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ paperStats.completed }}</div>
                                    <div class="stats-label">已完成</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>

                    <el-col :span="6">
                        <el-card class="stats-card">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #fdf6ec;">
                                    <el-icon>
                                        <Clock />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ paperStats.pending }}</div>
                                    <div class="stats-label">待完成</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>

                    <el-col :span="6">
                        <el-card class="stats-card">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #f0f9eb;">
                                    <el-icon>
                                        <Star />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ paperStats.avgScore }}</div>
                                    <div class="stats-label">平均分</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                </el-row>

                <!-- 错题集统计卡片 -->
                <el-row :gutter="20" style="margin-top: 20px;">
                    <el-col :span="8">
                        <el-card class="stats-card" @click="activeTab = 'wrong-questions'" style="cursor: pointer;">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #fef0f0;">
                                    <el-icon>
                                        <Warning />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ wrongQuestionStats.total }}</div>
                                    <div class="stats-label">错题总数</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>

                    <el-col :span="8">
                        <el-card class="stats-card" @click="activeTab = 'wrong-questions'" style="cursor: pointer;">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #f0f9ff;">
                                    <el-icon>
                                        <TrendCharts />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ wrongQuestionStats.weakType || '无' }}</div>
                                    <div class="stats-label">薄弱题型</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>

                    <el-col :span="8">
                        <el-card class="stats-card" @click="generatePracticeFromWrongQuestions"
                            style="cursor: pointer;">
                            <div class="stats-content">
                                <div class="stats-icon" style="background-color: #f0f9eb;">
                                    <el-icon>
                                        <EditPen />
                                    </el-icon>
                                </div>
                                <div class="stats-info">
                                    <div class="stats-number">{{ wrongQuestionStats.practiceCount }}</div>
                                    <div class="stats-label">可练习题目</div>
                                </div>
                            </div>
                        </el-card>
                    </el-col>
                </el-row>

                <!-- 标签页 -->
                <el-tabs v-model="activeTab" style="margin-top: 20px;">
                    <!-- 试卷列表 -->
                    <el-tab-pane label="我的试卷" name="papers">
                        <el-card class="paper-list-card">
                            <template #header>
                                <div class="card-header">
                                    <span>我的试卷</span>
                                    <el-button type="primary" @click="loadPapers" :loading="loading">
                                        <el-icon>
                                            <Refresh />
                                        </el-icon>
                                        刷新
                                    </el-button>
                                </div>
                            </template>

                            <el-table :data="papers" v-loading="loading">
                                <el-table-column prop="id" label="试卷ID" width="100" />
                                <el-table-column prop="title" label="试卷标题" />
                                <el-table-column prop="totalQuestions" label="题目数量" width="100" />
                                <el-table-column prop="score" label="得分" width="100">
                                    <template #default="{ row }">
                                        <span v-if="row.score !== null && row.score !== undefined"
                                            :class="{ 'high-score': row.score >= 90, 'medium-score': row.score >= 60 && row.score < 90, 'low-score': row.score < 60 }">
                                            {{ formatScore(row.score) }} 分
                                        </span>
                                        <el-tag v-else type="warning" size="small">未完成</el-tag>
                                    </template>
                                </el-table-column>
                                <el-table-column prop="timeSpent" label="用时" width="100">
                                    <template #default="{ row }">
                                        {{ row.timeSpent ? formatTime(row.timeSpent) : '--' }}
                                    </template>
                                </el-table-column>
                                <el-table-column prop="createdAt" label="创建时间" width="180">
                                    <template #default="{ row }">
                                        {{ formatDate(row.createdAt) }}
                                    </template>
                                </el-table-column>
                                <el-table-column label="状态" width="100">
                                    <template #default="{ row }">
                                        <el-tag :type="getStatusType(row)">
                                            {{ getStatusText(row) }}
                                        </el-tag>
                                    </template>
                                </el-table-column>
                                <el-table-column label="操作" width="200">
                                    <template #default="{ row }">
                                        <el-button type="primary" size="small" @click="startPaper(row)"
                                            :disabled="row.score !== null && row.score !== undefined">
                                            {{ (row.score !== null && row.score !== undefined) ? '已完成' : '开始答题' }}
                                        </el-button>
                                        <el-button type="info" size="small" @click="viewPaperDetail(row)"
                                            :disabled="row.score === null || row.score === undefined">
                                            查看详情
                                        </el-button>
                                    </template>
                                </el-table-column>
                            </el-table>
                        </el-card>
                    </el-tab-pane>

                    <!-- 错题集 -->
                    <el-tab-pane label="我的错题集" name="wrong-questions">
                        <WrongQuestions :student-id="userInfo.id" @practice-generated="handlePracticeGenerated" />
                    </el-tab-pane>
                </el-tabs>

                <!-- 个人信息 -->
                <el-card class="info-card" style="margin-top: 20px;">
                    <template #header>
                        <div class="card-header">
                            <span>个人信息</span>
                        </div>
                    </template>
                    <el-descriptions :column="2" border>
                        <el-descriptions-item label="用户名">{{ userInfo.username }}</el-descriptions-item>
                        <el-descriptions-item label="角色">{{ userInfo.role === 'student' ? '学生' : userInfo.role
                        }}</el-descriptions-item>
                        <el-descriptions-item label="班级">{{ userInfo.userClass || '未设置' }}</el-descriptions-item>
                        <el-descriptions-item label="注册时间">{{ formatDate(userInfo.createdAt) }}</el-descriptions-item>
                    </el-descriptions>
                </el-card>
            </el-main>
        </el-container>

        <!-- 答题对话框 - 关键修改 -->
        <el-dialog v-model="showPaperDialog"
            :title="`${currentPaper?.score ? '试卷详情' : '正在答题'} - ${currentPaper?.title}`" width="800px" fullscreen>
            <div v-if="currentPaperDetail" class="paper-exam">
                <div class="exam-header">
                    <div class="exam-info">
                        <h3>{{ currentPaper.title }}</h3>
                        <div class="exam-stats">
                            <span>题目数量: {{ currentPaper.totalQuestions }}</span>
                            <span v-if="currentPaper.score">得分: {{ formatScore(currentPaper.score) }} 分</span>
                            <span v-if="currentPaper.score">正确题数: {{ currentPaper.correctCount }}/{{
                                currentPaper.totalQuestions
                            }}</span>
                            <span v-else>已答: {{ answeredCount }}/{{ currentPaper.totalQuestions }}</span>
                            <span>用时: {{ formatTime(currentPaper.score ? currentPaper.timeSpent : examTime) }}</span>
                        </div>
                    </div>
                    <div v-if="!currentPaper.score" class="timer" :class="{ 'warning': examTime > 1800 }">
                        <el-icon>
                            <Clock />
                        </el-icon>
                        {{ formatExamTime }}
                    </div>
                </div>

                <div class="questions-container">
                    <div v-for="(question, index) in currentPaperDetail.questions" :key="question.id"
                        class="question-item">
                        <div class="question-header">
                            <span class="question-number">第 {{ index + 1 }} 题</span>
                            <el-tag size="small" :type="getDifficultyTagType(question.difficultyId)">
                                {{ getDifficultyName(question.difficultyId) }}
                            </el-tag>
                            <el-tag size="small" :type="getTypeTagType(question.typeId)">
                                {{ getTypeName(question.typeId) }}
                            </el-tag>
                            <span v-if="currentPaper.score" class="answer-status">
                                <el-tag :type="question.isCorrect ? 'success' : 'danger'" size="small">
                                    {{ question.isCorrect ? '正确' : '错误' }}
                                </el-tag>
                            </span>
                        </div>

                        <div class="question-content">
                            <p class="question-text">{{ question.content }}</p>
                            <!-- 显示题目图片 -->
                            <div v-if="question.images && question.images.length > 0" class="question-images">
                                <img v-for="(img, idx) in question.images" :key="idx" 
                                     :src="getImageUrl(img.imagePath)" 
                                     class="question-image" 
                                     @click="previewImage(img.imagePath)" />
                            </div>

                            <!-- 答题状态：根据题目类型显示不同的答题方式 -->
                            <div v-if="!currentPaper.score" class="answer-input">
                                <!-- 单选题：单选按钮组 -->
                                <div v-if="question.typeId === 1 && question.options?.length" class="choice-options">
                                    <el-radio-group v-model="studentAnswers[question.id]" @change="handleAnswerChange(question.id)">
                                        <el-radio 
                                            v-for="option in getSortedOptions(question.options)" 
                                            :key="option.optionKey" 
                                            :label="option.optionKey"
                                            class="choice-option">
                                            <span class="option-label">{{ option.optionKey }}.</span>
                                            <span v-html="option.content"></span>
                                        </el-radio>
                                    </el-radio-group>
                                </div>

                                <!-- 多选题：复选框组 -->
                                <div v-else-if="question.typeId === 2 && question.options?.length" class="choice-options">
                                    <el-checkbox-group v-model="studentAnswers[question.id]" @change="handleAnswerChange(question.id)">
                                        <el-checkbox 
                                            v-for="option in getSortedOptions(question.options)" 
                                            :key="option.optionKey" 
                                            :label="option.optionKey"
                                            class="choice-option">
                                            <span class="option-label">{{ option.optionKey }}.</span>
                                            <span v-html="option.content"></span>
                                        </el-checkbox>
                                    </el-checkbox-group>
                                </div>

                                <!-- 其他类型：文本输入框 -->
                                <el-input 
                                    v-else
                                    v-model="studentAnswers[question.id]" 
                                    placeholder="请输入答案"
                                    style="width: 300px;" 
                                    @change="handleAnswerChange(question.id)" />
                            </div>

                            <!-- 显示正确答案和学生答案（如果试卷已完成） -->
                            <div v-if="currentPaper.score" class="answer-review">
                                <div class="correct-answer-section">
                                    <p><strong>正确答案:</strong> {{ formatCorrectAnswerForDisplay(question) }}</p>
                                    <p><strong>你的答案:</strong>
                                        <span :class="question.isCorrect ? 'correct-text' : 'wrong-text'">
                                            {{ formatStudentAnswerForDisplay(studentAnswers[question.id], question) }}
                                        </span>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="exam-footer">
                    <el-button @click="showPaperDialog = false">关闭</el-button>
                    <el-button v-if="!currentPaper.score" type="primary" @click="submitPaper" :loading="submitting"
                        :disabled="answeredCount < currentPaper.totalQuestions">
                        提交试卷 ({{ answeredCount }}/{{ currentPaper.totalQuestions }})
                    </el-button>
                </div>
            </div>
        </el-dialog>
    </div>
</template>

<style scoped>
.student-dashboard {
    height: 100vh;
}

.header {
    background: #409eff;
    color: white;
    display: flex;
    align-items: center;
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 10px;
}

.stats-card {
    border-radius: 12px;
    border: none;
    transition: transform 0.3s ease;
}

.stats-card:hover {
    transform: translateY(-5px);
}

.stats-content {
    display: flex;
    align-items: center;
    padding: 20px 10px;
}

.stats-icon {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 15px;
    font-size: 24px;
    color: #409eff;
}

.stats-info {
    flex: 1;
}

.stats-number {
    font-size: 28px;
    font-weight: bold;
    color: #303133;
    margin-bottom: 5px;
}

.stats-label {
    color: #909399;
    font-size: 14px;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.high-score {
    color: #67c23a;
    font-weight: bold;
}

.medium-score {
    color: #e6a23c;
    font-weight: bold;
}

.low-score {
    color: #f56c6c;
    font-weight: bold;
}

/* 答题界面样式 */
.paper-exam {
    height: 80vh;
    display: flex;
    flex-direction: column;
}

.exam-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    background: #f5f7fa;
    border-radius: 8px;
    margin-bottom: 20px;
}

.exam-info h3 {
    margin: 0 0 10px 0;
    color: #303133;
}

.exam-stats {
    display: flex;
    gap: 20px;
    color: #606266;
    font-size: 14px;
}

.timer {
    font-size: 24px;
    font-weight: bold;
    color: #409eff;
    display: flex;
    align-items: center;
    gap: 8px;
}

.timer.warning {
    color: #e6a23c;
}

.questions-container {
    flex: 1;
    overflow-y: auto;
    padding: 0 20px;
}

.question-item {
    background: white;
    border: 1px solid #e4e7ed;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
}

.question-header {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #f0f0f0;
}

.question-number {
    font-weight: bold;
    color: #303133;
}

.answer-status {
    margin-left: auto;
}

.question-text {
    font-size: 16px;
    color: #303133;
    margin-bottom: 15px;
}

.question-images {
    margin-top: 10px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
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

.answer-input {
    margin-top: 15px;
}

.answer-review {
    margin-top: 15px;
}

.correct-answer-section {
    padding: 10px;
    background: #f8f9fa;
    border-radius: 4px;
}

.correct-text {
    color: #67c23a;
    font-weight: bold;
}

.wrong-text {
    color: #f56c6c;
    font-weight: bold;
}

.exam-footer {
    padding: 20px;
    background: #f5f7fa;
    border-top: 1px solid #e4e7ed;
    text-align: right;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.exam-footer .el-button {
    margin-left: 10px;
}

/* 选择题选项样式 */
.choice-options {
    margin-top: 15px;
}

.choice-option {
    display: block;
    margin-bottom: 12px;
    padding: 8px;
    border-radius: 4px;
    transition: background-color 0.3s;
}

.choice-option:hover {
    background-color: #f5f7fa;
}

.option-label {
    font-weight: bold;
    margin-right: 8px;
    color: #409eff;
}
</style>