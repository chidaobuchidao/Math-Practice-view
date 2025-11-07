<template>
    <div class="teacher-dashboard">
        <el-container>
            <el-header class="header">
                <div class="header-content">
                    <h2>教师管理后台</h2>
                    <div class="user-info">
                        <span>欢迎，{{ userInfo.username }}老师</span>
                        <el-button type="text" @click="handleLogout">退出登录</el-button>
                    </div>
                </div>
            </el-header>

            <el-main>
                <el-row :gutter="20">
                    <el-col :span="6">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>题目管理</span>
                                </div>
                            </template>
                            <p>添加、编辑和删除数学题目</p>
                            <el-button type="primary">管理题目</el-button>
                        </el-card>
                    </el-col>

                    <el-col :span="6">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>学生管理</span>
                                </div>
                            </template>
                            <p>查看和管理学生信息</p>
                            <el-button type="success">管理学生</el-button>
                        </el-card>
                    </el-col>

                    <el-col :span="6">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>成绩统计</span>
                                </div>
                            </template>
                            <p>查看学生成绩和统计报告</p>
                            <el-button type="warning">查看统计</el-button>
                        </el-card>
                    </el-col>

                    <el-col :span="6">
                        <el-card class="dashboard-card">
                            <template #header>
                                <div class="card-header">
                                    <span>试卷生成</span>
                                </div>
                            </template>
                            <p>创建和管理练习试卷</p>
                            <el-button type="danger">生成试卷</el-button>
                        </el-card>
                    </el-col>
                </el-row>

                <el-card class="info-card" style="margin-top: 20px;">
                    <template #header>
                        <div class="card-header">
                            <span>教师信息</span>
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

.dashboard-card {
    text-align: center;
    height: 180px;
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