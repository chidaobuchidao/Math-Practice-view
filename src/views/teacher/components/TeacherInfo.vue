<template>
  <div class="teacher-info">
    <el-card class="info-card">
      <template #header>
        <div class="card-header">
          <span>教师基本信息</span>
        </div>
      </template>

      <el-descriptions :column="1" border>
        <el-descriptions-item label="教师ID">
          {{ userStore.userInfo?.id }}
        </el-descriptions-item>

        <el-descriptions-item label="用户名">
          {{ userStore.userInfo?.username }}
        </el-descriptions-item>

        <el-descriptions-item label="角色">
          <el-tag type="success">教师</el-tag>
        </el-descriptions-item>

        <el-descriptions-item label="注册时间">
          {{ formatDate(userStore.userInfo?.createdAt) }}
        </el-descriptions-item>

      </el-descriptions>
    </el-card>

    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="8">
        <el-card class="dashboard-card" shadow="hover" @click="goToQuestions">
          <div class="dashboard-content">
            <div class="dashboard-icon" style="background-color: #ecf5ff;">
              <i class="el-icon-collection"></i>
            </div>
            <div class="dashboard-info">
              <div class="dashboard-number">{{ questionStats.total }}</div>
              <div class="dashboard-label">总题目数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="dashboard-card" shadow="hover" @click="goToPapers">
          <div class="dashboard-content">
            <div class="dashboard-icon" style="background-color: #fdf6ec;">
              <i class="el-icon-document"></i>
            </div>
            <div class="dashboard-info">
              <div class="dashboard-number">{{ paperStats.total }}</div>
              <div class="dashboard-label">生成试卷数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="dashboard-card" shadow="hover" @click="goToStudents">
          <div class="dashboard-content">
            <div class="dashboard-icon" style="background-color: #f0f9ff;">
              <i class="el-icon-user"></i>
            </div>
            <div class="dashboard-info">
              <div class="dashboard-number">{{ studentStats.total }}</div>
              <div class="dashboard-label">管理学生数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近活动 -->
    <el-card style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span>最近活动</span>
          <el-button type="text" @click="clearActivities" size="small">清空记录</el-button>
        </div>
      </template>

      <div v-if="recentActivities.length === 0" class="empty-activities">
        <el-empty description="暂无活动记录" />
      </div>

      <el-timeline v-else>
        <el-timeline-item v-for="(activity, index) in recentActivities" :key="activity.id"
          :timestamp="formatActivityTime(activity.timestamp)" :type="getActivityType(activity.type)"
          :hollow="index === 0">
          <div class="activity-content">
            <span class="activity-text">{{ activity.content }}</span>
            <el-tag v-if="activity.module" size="small" :type="getModuleTagType(activity.module)">
              {{ getModuleText(activity.module) }}
            </el-tag>
          </div>
        </el-timeline-item>
      </el-timeline>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { userApi } from '@/api/user'
import { questionApi } from '@/api/question'
import { paperApi } from '@/api/paper'

const userStore = useUserStore()
// 定义 emits
const emit = defineEmits(['navigate'])

// 统计数据
const questionStats = reactive({
  total: 0
})

const paperStats = reactive({
  total: 0
})

const studentStats = reactive({
  total: 0
})

// 最近活动
const recentActivities = ref([])

// 活动类型常量
const ACTIVITY_TYPES = {
  LOGIN: 'login',
  CREATE_QUESTION: 'create_question',
  UPDATE_QUESTION: 'update_question',
  DELETE_QUESTION: 'delete_question',
  GENERATE_PAPER: 'generate_paper',
  DELETE_PAPER: 'delete_paper',
  ADD_STUDENT: 'add_student',
  DELETE_STUDENT: 'delete_student'
}

// 模块类型常量
const MODULE_TYPES = {
  QUESTION: 'question',
  PAPER: 'paper',
  STUDENT: 'student',
  SYSTEM: 'system'
}

// 跳转到题目管理 - 改为发射事件
const goToQuestions = () => {
  emit('navigate', 'questions')
}

// 跳转到试卷管理 - 改为发射事件
const goToPapers = () => {
  emit('navigate', 'papers')
}

// 跳转到学生管理 - 改为发射事件
const goToStudents = () => {
  emit('navigate', 'students')
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
      minute: '2-digit',
      second: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

// 格式化活动时间
const formatActivityTime = (timestamp) => {
  const now = new Date()
  const activityTime = new Date(timestamp)
  const diffInMinutes = Math.floor((now - activityTime) / (1000 * 60))

  if (diffInMinutes < 1) {
    return '刚刚'
  } else if (diffInMinutes < 60) {
    return `${diffInMinutes} 分钟前`
  } else if (diffInMinutes < 24 * 60) {
    const hours = Math.floor(diffInMinutes / 60)
    return `${hours} 小时前`
  } else {
    return formatDate(timestamp)
  }
}

// 获取活动类型对应的Element Plus类型
const getActivityType = (activityType) => {
  const typeMap = {
    [ACTIVITY_TYPES.LOGIN]: 'success',
    [ACTIVITY_TYPES.CREATE_QUESTION]: 'primary',
    [ACTIVITY_TYPES.UPDATE_QUESTION]: 'warning',
    [ACTIVITY_TYPES.DELETE_QUESTION]: 'danger',
    [ACTIVITY_TYPES.GENERATE_PAPER]: 'primary',
    [ACTIVITY_TYPES.DELETE_PAPER]: 'danger',
    [ACTIVITY_TYPES.ADD_STUDENT]: 'success',
    [ACTIVITY_TYPES.DELETE_STUDENT]: 'danger'
  }
  return typeMap[activityType] || 'info'
}

// 获取模块文本
const getModuleText = (module) => {
  const moduleMap = {
    [MODULE_TYPES.QUESTION]: '题目管理',
    [MODULE_TYPES.PAPER]: '试卷管理',
    [MODULE_TYPES.STUDENT]: '学生管理',
    [MODULE_TYPES.SYSTEM]: '系统'
  }
  return moduleMap[module] || module
}

// 获取模块标签类型
const getModuleTagType = (module) => {
  const typeMap = {
    [MODULE_TYPES.QUESTION]: 'primary',
    [MODULE_TYPES.PAPER]: 'success',
    [MODULE_TYPES.STUDENT]: 'warning',
    [MODULE_TYPES.SYSTEM]: 'info'
  }
  return typeMap[module] || 'info'
}

// 记录活动
const recordActivity = (activity) => {
  const newActivity = {
    id: Date.now(), // 使用时间戳作为ID
    type: activity.type,
    content: activity.content,
    module: activity.module || MODULE_TYPES.SYSTEM,
    timestamp: new Date().toISOString()
  }

  // 添加到活动列表开头
  recentActivities.value.unshift(newActivity)

  // 只保留最近5条记录
  if (recentActivities.value.length > 5) {
    recentActivities.value = recentActivities.value.slice(0, 5)
  }

  // 保存到本地存储
  saveActivitiesToStorage()
}

// 从本地存储加载活动记录
const loadActivitiesFromStorage = () => {
  try {
    const stored = localStorage.getItem(`teacher_activities_${userStore.userInfo?.id}`)
    if (stored) {
      const activities = JSON.parse(stored)
      // 确保只显示最近5条
      recentActivities.value = activities.slice(0, 5)
    }
  } catch (error) {
    console.error('加载活动记录失败:', error)
    recentActivities.value = []
  }
}

// 保存活动记录到本地存储
const saveActivitiesToStorage = () => {
  try {
    localStorage.setItem(`teacher_activities_${userStore.userInfo?.id}`, JSON.stringify(recentActivities.value))
  } catch (error) {
    console.error('保存活动记录失败:', error)
  }
}

// 清空活动记录
const clearActivities = async () => {
  try {
    await ElMessageBox.confirm('确定要清空所有活动记录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    recentActivities.value = []
    localStorage.removeItem(`teacher_activities_${userStore.userInfo?.id}`)
    ElMessage.success('活动记录已清空')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('清空活动记录失败')
    }
  }
}

// 加载统计数据
const loadStats = async () => {
  try {
    // 加载题目统计
    const questionsResponse = await questionApi.getAllQuestions()
    questionStats.total = questionsResponse.data?.length || 0

    // 加载学生统计
    const studentsResponse = await userApi.getStudents()
    studentStats.total = studentsResponse.data?.length || 0

    // 加载试卷统计
    const papersResponse = await paperApi.getAllPapers()
    paperStats.total = papersResponse.data?.length || 0

  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

onMounted(() => {
  loadStats()
  loadActivitiesFromStorage()

  // 记录登录活动
  recordActivity({
    type: ACTIVITY_TYPES.LOGIN,
    content: `教师 ${userStore.userInfo?.username} 登录系统`,
    module: MODULE_TYPES.SYSTEM
  })
})

// 暴露方法给父组件使用
defineExpose({
  recordActivity,
  ACTIVITY_TYPES,
  MODULE_TYPES
})
</script>

<style scoped>
.teacher-info {
  padding: 20px;
}

.info-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stats-card {
  text-align: center;
  height: 120px;
}

.stats-content {
  padding: 10px 0;
}

.stats-number {
  font-size: 2rem;
  font-weight: bold;
  color: #409eff;
  margin-bottom: 8px;
}

.stats-label {
  color: #666;
  font-size: 0.9rem;
}

:deep(.el-descriptions__label) {
  font-weight: bold;
  width: 100px;
}

:deep(.el-descriptions__content) {
  padding-left: 20px;
}

.dashboard-card {
  border: 1px solid #ebeef5;
  /* 添加边框 */
  border-radius: 12px;
  transition: transform 0.3s ease;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  /* 添加阴影效果 */
}

.dashboard-card:hover {
  transform: translateY(-5px);
  border-color: #31333534;
  /* 悬停时改变边框颜色 */
}

.dashboard-content {
  display: flex;
  align-items: center;
  padding: 20px 10px;
}

.dashboard-icon {
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

.dashboard-info {
  flex: 1;
}

.dashboard-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.dashboard-label {
  color: #909399;
  font-size: 14px;
}

.activity-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.activity-text {
  flex: 1;
  margin-right: 10px;
}

.empty-activities {
  padding: 20px 0;
}
</style>