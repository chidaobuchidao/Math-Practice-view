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

                <!-- 试卷列表 -->
                <el-card class="paper-list-card" style="margin-top: 20px;">
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
                                    {{ row.score }} 分
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
                        <el-table-column label="操作" width="120">
                            <template #default="{ row }">
                                <el-button type="primary" size="small" @click="startPaper(row)"
                                    :disabled="row.score !== null && row.score !== undefined">
                                    {{ (row.score !== null && row.score !== undefined) ? '已完成' : '开始答题' }}
                                </el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-card>

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

        <!-- 答题对话框 -->
        <el-dialog v-model="showPaperDialog" :title="`正在答题 - ${currentPaper?.title}`" width="800px" fullscreen>
            <div v-if="currentPaperDetail" class="paper-exam">
                <div class="exam-header">
                    <div class="exam-info">
                        <h3>{{ currentPaper.title }}</h3>
                        <div class="exam-stats">
                            <span>题目数量: {{ currentPaper.totalQuestions }}</span>
                            <span>已答: {{ answeredCount }}/{{ currentPaper.totalQuestions }}</span>
                            <span>用时: {{ formatTime(examTime) }}</span>
                        </div>
                    </div>
                    <div class="timer" :class="{ 'warning': examTime > 1800 }">
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
                            <el-tag size="small" :type="getDifficultyTagType(question.difficulty)">
                                {{ getDifficultyText(question.difficulty) }}
                            </el-tag>
                            <el-tag size="small" :type="getTypeTagType(question.type)">
                                {{ getTypeText(question.type) }}
                            </el-tag>
                        </div>

                        <div class="question-content">
                            <p class="question-text">{{ question.content }}</p>

                            <div class="answer-input">
                                <el-input-number v-model="studentAnswers[question.id]" :precision="2"
                                    placeholder="请输入答案" style="width: 200px;"
                                    @change="handleAnswerChange(question.id)" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="exam-footer">
                    <el-button @click="showPaperDialog = false">取消</el-button>
                    <el-button type="primary" @click="submitPaper" :loading="submitting"
                        :disabled="answeredCount < currentPaper.totalQuestions">
                        提交试卷 ({{ answeredCount }}/{{ currentPaper.totalQuestions }})
                    </el-button>
                </div>
            </div>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import {
    CircleClose,
    Document,
    CircleCheck,
    Clock,
    Star,
    Refresh
} from '@element-plus/icons-vue'
import { paperApi } from '@/api/paper'
import { useUserStore } from '@/stores/user' // 引入 userStore

const router = useRouter()
const userStore = useUserStore() // 使用 userStore
const userInfo = ref({})
const papers = ref([])
const loading = ref(false)
const showPaperDialog = ref(false)
const submitting = ref(false)
const currentPaper = ref(null)
const currentPaperDetail = ref(null)
const studentAnswers = ref({})
const examTime = ref(0) // 考试用时（秒）
let timer = null

// 统计
const paperStats = computed(() => {
    // 计算试卷总数
    const total = papers.value.length

    // 只有 score 不为 null 且不为 undefined 才算已完成
    const completed = papers.value.filter(p => p.score !== null && p.score !== undefined).length

    // 待完成试卷数量 = 总数 - 已完成
    const pending = total - completed

    // 筛选出已完成的试卷（用于计算平均分）
    const completedPapers = papers.value.filter(p => p.score !== null && p.score !== undefined)

    // 计算平均分：已完成试卷分数总和 / 已完成试卷数量，保留一位小数
    const avgScore = completedPapers.length > 0
        ? (completedPapers.reduce((sum, p) => sum + p.score, 0) / completedPapers.length).toFixed(1)
        : 0

    // 返回统计信息对象
    return { total, completed, pending, avgScore }
})

const answeredCount = computed(() => {
    return Object.values(studentAnswers.value).filter(answer =>
        answer !== null && answer !== undefined && answer !== ''
    ).length
})

const formatExamTime = computed(() => {
    const minutes = Math.floor(examTime.value / 60)
    const seconds = examTime.value % 60
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
})

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

// 修改开始答题方法，添加更严格的检查
const startPaper = async (paper) => {
    try {
        // 严格检查：只有 score 为 null 或 undefined 才能开始答题
        if (paper.score !== null && paper.score !== undefined) {
            ElMessage.warning('该试卷已完成，无法再次答题')
            return
        }

        const response = await paperApi.getPaperDetail(paper.id)
        currentPaperDetail.value = response.data
        currentPaper.value = paper

        // 初始化答案
        studentAnswers.value = {}
        currentPaperDetail.value.questions.forEach(question => {
            studentAnswers.value[question.id] = null
        })

        // 开始计时
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
        // 验证是否所有题目都已作答
        if (answeredCount.value < currentPaper.value.totalQuestions) {
            ElMessage.warning(`请完成所有题目后再提交！还有 ${currentPaper.value.totalQuestions - answeredCount.value} 题未作答`)
            return
        }

        submitting.value = true

        // 计算得分
        let correctCount = 0
        currentPaperDetail.value.questions.forEach(question => {
            const studentAnswer = studentAnswers.value[question.id]
            if (studentAnswer !== null && studentAnswer !== undefined &&
                Math.abs(studentAnswer - question.answer) < 0.01) {
                correctCount++
            }
        })

        const score = (correctCount / currentPaperDetail.value.questions.length * 100).toFixed(1)

        // 调用提交试卷的API
        const submitData = {
            answers: studentAnswers.value,
            timeSpent: examTime.value,
            score: parseFloat(score)
        }

        console.log('提交试卷数据:', submitData)

        const response = await paperApi.submitPaper(currentPaper.value.id, submitData)

        ElMessage.success(`试卷提交成功！得分: ${score}分`)
        showPaperDialog.value = false

        // 清除计时器
        if (timer) {
            clearInterval(timer)
            timer = null
        }

        // 重新加载试卷列表
        await loadPapers()
    } catch (error) {
        console.error('提交试卷错误:', error)
        ElMessage.error('提交试卷失败: ' + (error.message || '网络错误'))
    } finally {
        submitting.value = false
    }
}

// 工具函数
// 判断逻辑
const getStatusType = (paper) => {
    // 只有 score 不为 null 且不为 undefined 才认为是已完成
    if (paper.score !== null && paper.score !== undefined) return 'success'
    return 'warning'
}

const getStatusText = (paper) => {
    // 只有 score 不为 null 且不为 undefined 才认为是已完成
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

const handleLogout = async () => {
    try {
        await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
        })

        userStore.clearUserInfo() // 使用 userStore 的方法
        ElMessage.success('已退出登录')
        router.push('/login?_=' + Date.now())
    } catch {
        // 用户取消退出
    }
}

onMounted(() => {
    // 使用 userStore 来获取用户信息
    if (!userStore.isLoggedIn) {
        router.push('/login')
        return
    }
    userInfo.value = userStore.userInfo
    loadPapers()
})
</script>

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

.question-text {
    font-size: 16px;
    color: #303133;
    margin-bottom: 15px;
}

.answer-input {
    margin-top: 15px;
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
</style>