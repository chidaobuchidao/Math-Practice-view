<template>
  <div class="teacher-dashboard">
    <el-container>
      <el-header class="header">
        <div class="header-content">
          <h2>教师管理后台</h2>
          <div class="user-info">
            <span>欢迎，{{ userStore.userInfo?.username }}老师</span>
            <el-button type="warning" :icon="CircleClose" @click="handleLogout">退出登录</el-button>
          </div>
        </div>
      </el-header>

      <el-main>
        <el-tabs v-model="activeTab">
          <!-- 教师信息 -->
          <el-tab-pane label="教师信息" name="info">
            <TeacherInfo @navigate="handleNavigation" />
          </el-tab-pane>

          <!-- 题目管理 -->
          <el-tab-pane label="题目管理" name="questions">
            <QuestionManagement />
          </el-tab-pane>

          <!-- 试卷生成 -->
          <el-tab-pane label="试卷生成" name="papers">
            <PaperGeneration />
          </el-tab-pane>

          <!-- 学生管理 -->
          <el-tab-pane label="学生管理" name="students">
            <StudentManagement />
          </el-tab-pane>
        </el-tabs>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessageBox, ElMessage } from 'element-plus'
import TeacherInfo from './components/TeacherInfo.vue'
import QuestionManagement from './components/QuestionManagement.vue'
import PaperGeneration from './components/PaperGeneration.vue'
import StudentManagement from './components/StudentManagement.vue'

import { CircleClose, User, Document, Collection } from '@/utils/icons'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 设置默认激活的标签页，优先使用路由参数
const activeTab = ref('info')

// 处理子组件导航事件
const handleNavigation = (tabName) => {
  activeTab.value = tabName
}

// 监听路由参数变化
watch(
  () => route.query.tab,
  (newTab) => {
    if (newTab && ['info', 'questions', 'papers', 'students'].includes(newTab)) {
      activeTab.value = newTab
    } else {
      activeTab.value = 'info'
    }
  },
  { immediate: true }
)

onMounted(() => {
  // 检查用户权限
  if (!userStore.isTeacher) {
    ElMessage.error('无权限访问教师页面')
    router.push('/student')
  }
})

const handleLogout = async () => {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    userStore.clearUserInfo()
    ElMessage.success('已退出登录')
    router.push('/login')
  } catch {
    // 用户取消退出
  }
}
</script>

<style scoped>
.teacher-dashboard {
  height: 100vh;
}

.header {
  background: #e6a23c;
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
</style>