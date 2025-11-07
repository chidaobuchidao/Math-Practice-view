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
                <el-row :gutter="20">
                    <el-col :span="8">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>开始练习</span>
                                </div>
                            </template>
                            <p>选择题目类型和难度开始数学练习</p>
                            <el-button type="primary">开始练习</el-button>
                        </el-card>
                    </el-col>

                    <el-col :span="8">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>历史成绩</span>
                                </div>
                            </template>
                            <p>查看以往的练习成绩和错题</p>
                            <el-button type="success">查看成绩</el-button>
                        </el-card>
                    </el-col>

                    <el-col :span="8">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>错题本</span>
                                </div>
                            </template>
                            <p>复习做错的题目，巩固知识</p>
                            <el-button type="warning">查看错题</el-button>
                        </el-card>
                    </el-col>
                </el-row>

                <el-card class="info-card" style="margin-top: 20px;">
                    <template #header>
                        <div class="card-header">
                            <span>个人信息</span>
                        </div>
                    </template>
                    <el-descriptions :column="2" border>
                        <el-descriptions-item label="用户名">{{ userInfo.username }}</el-descriptions-item>
                        <el-descriptions-item label="角色">{{ userInfo.role }}</el-descriptions-item>
                        <el-descriptions-item label="班级">{{ userInfo.userClass || '未设置' }}</el-descriptions-item>
                        <el-descriptions-item label="注册时间">{{ userInfo.createdAt }}</el-descriptions-item>
                    </el-descriptions>
                </el-card>
            </el-main>
        </el-container>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'

import { CircleClose, User, Document, Collection } from '@/utils/icons'

const router = useRouter()
const userInfo = ref({})

onMounted(() => {
    const user = JSON.parse(localStorage.getItem('currentUser') || '{}')
    if (!user.id) {
        router.push('/login')
        return
    }
    userInfo.value = user
})

const handleLogout = async () => {
    try {
        await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
        })

        localStorage.removeItem('currentUser')
        ElMessage.success('已退出登录')
        // 添加时间戳参数避免缓存
        router.push('/login?_=' + Date.now())
    } catch {
        // 用户取消退出
    }
}
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

.dashboard-card {
    text-align: center;
    height: 200px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
</style>