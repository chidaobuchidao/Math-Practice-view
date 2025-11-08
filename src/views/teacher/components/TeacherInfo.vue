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
        </div>
      </template>
      <el-timeline>
        <el-timeline-item v-for="(activity, index) in recentActivities" :key="index" :timestamp="activity.time"
          :type="activity.type">
          {{ activity.content }}
        </el-timeline-item>
      </el-timeline>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
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

// 最近活动
const recentActivities = ref([
  {
    content: '登录系统',
    time: '刚刚',
    type: 'primary'
  }
])

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

  // 添加登录活动记录
  const now = new Date()
  recentActivities.value.unshift({
    content: `教师 ${userStore.userInfo?.username} 登录系统`,
    time: now.toLocaleTimeString('zh-CN'),
    type: 'success'
  })
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
</style>