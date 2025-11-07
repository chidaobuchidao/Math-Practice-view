<template>
    <div class="login-container">
        <el-card class="login-card">
            <template #header>
                <div class="login-header">
                    <h2>数学练习系统</h2>
                    <p>欢迎登录</p>
                </div>
            </template>

            <el-form :model="loginForm" :rules="loginRules" ref="loginFormRef" @submit.prevent="handleLogin">
                <el-form-item prop="username">
                    <el-input v-model="loginForm.username" placeholder="请输入用户名" size="large" prefix-icon="User" />
                </el-form-item>

                <el-form-item prop="password">
                    <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" size="large"
                        prefix-icon="Lock" show-password />
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" size="large" :loading="loading" @click="handleLogin" style="width: 100%">
                        {{ loading ? '登录中...' : '登录' }}
                    </el-button>
                </el-form-item>
            </el-form>

            <div class="login-footer">
                <el-button type="text" @click="goToRegister">
                    还没有账号？立即注册
                </el-button>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login } from '../api/user.js'  // 或相对路径调整

const router = useRouter()
const loading = ref(false)
const loginFormRef = ref()

const loginForm = reactive({
    username: '',
    password: ''
})

const loginRules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
    ]
}

const handleLogin = async () => {
    if (!loginFormRef.value) return

    try {
        await loginFormRef.value.validate()
        loading.value = true

        const response = await login(loginForm)
        const userData = response.data

        // 保存用户信息到本地存储
        localStorage.setItem('currentUser', JSON.stringify(userData))

        ElMessage.success(`欢迎回来，${userData.username}！`)

        // 根据角色跳转到不同页面
        if (userData.role === 'student') {
            router.push('/student')
        } else if (userData.role === 'teacher') {
            router.push('/teacher')
        }

    } catch (error) {
        console.error('登录失败:', error)
        ElMessage.error(error.message || '登录失败，请检查用户名和密码')
    } finally {
        loading.value = false
    }
}

const goToRegister = () => {
    router.push('/register')
}
</script>

<style scoped>
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
    width: 400px;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.login-header {
    text-align: center;
}

.login-header h2 {
    margin: 0;
    color: #333;
}

.login-header p {
    margin: 10px 0 0;
    color: #666;
}

.login-footer {
    text-align: center;
    margin-top: 20px;
}
</style>