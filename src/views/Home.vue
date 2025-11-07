<template>
    <div class="home-container">
        <el-container>
            <el-header>
                <div class="header-content">
                    <h1>数学练习系统</h1>
                    <div class="user-info">
                        <span>欢迎，{{ user?.username }}</span>
                        <el-button type="text" @click="handleLogout">退出登录</el-button>
                    </div>
                </div>
            </el-header>

            <el-main>
                <div class="welcome-content">
                    <h2>欢迎使用数学练习系统</h2>
                    <p>当前角色：{{ user?.role === 'student' ? '学生' : '老师' }}</p>
                    <p v-if="user?.userClass">班级：{{ user.userClass }}</p>
                </div>
            </el-main>
        </el-container>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import type { User } from '@/api/user'

const router = useRouter()
const user = ref<User>()

onMounted(() => {
    const userStr = localStorage.getItem('user')
    if (userStr) {
        user.value = JSON.parse(userStr)
    }
})

const handleLogout = async () => {
    try {
        await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
            type: 'warning'
        })
        localStorage.removeItem('user')
        router.push('/login')
    } catch {
        // 用户取消退出
    }
}
</script>

<style scoped>
.home-container {
    height: 100vh;
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: 100%;
}

.header-content h1 {
    margin: 0;
    color: #409eff;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 10px;
}

.welcome-content {
    text-align: center;
    padding: 50px;
}

.welcome-content h2 {
    color: #303133;
    margin-bottom: 20px;
}

.welcome-content p {
    color: #606266;
    margin: 10px 0;
}
</style>