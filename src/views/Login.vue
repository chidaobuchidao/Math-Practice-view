<template>
    <div class="login-container">
        <el-card class="login-card">
            <template #header>
                <div class="login-header">
                    <h2>数学练习系统</h2>
                    <p>欢迎登录</p>
                </div>
            </template>

            <el-form :model="loginForm" :rules="loginRules" ref="loginFormRef">
                <el-form-item prop="username">
                    <el-input v-model="loginForm.username" placeholder="请输入用户名" size="large" :prefix-icon="User" />
                </el-form-item>

                <el-form-item prop="password">
                    <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" size="large"
                        :prefix-icon="Lock" show-password />
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" size="large" style="width: 100%" :loading="loading" @click="handleLogin">
                        登录
                    </el-button>
                </el-form-item>

                <div class="login-footer">
                    <el-button type="text" @click="showRegister = true">
                        没有账号？立即注册
                    </el-button>
                </div>
            </el-form>
        </el-card>

        <!-- 注册对话框 -->
        <el-dialog v-model="showRegister" title="用户注册" width="500px">
            <el-form :model="registerForm" :rules="registerRules" ref="registerFormRef">
                <el-form-item label="用户名" prop="username">
                    <el-input v-model="registerForm.username" placeholder="请输入用户名" />
                </el-form-item>

                <el-form-item label="密码" prop="password">
                    <el-input v-model="registerForm.password" type="password" placeholder="请输入密码" show-password />
                </el-form-item>

                <el-form-item label="确认密码" prop="confirmPassword">
                    <el-input v-model="registerForm.confirmPassword" type="password" placeholder="请再次输入密码"
                        show-password />
                </el-form-item>

                <el-form-item label="角色" prop="role">
                    <el-radio-group v-model="registerForm.role">
                        <el-radio label="student">学生</el-radio>
                        <el-radio label="teacher">老师</el-radio>
                    </el-radio-group>
                </el-form-item>

                <el-form-item label="班级" prop="userClass" v-if="registerForm.role === 'student'">
                    <el-input v-model="registerForm.userClass" placeholder="请输入班级" />
                </el-form-item>
            </el-form>

            <template #footer>
                <el-button @click="showRegister = false">取消</el-button>
                <el-button type="primary" :loading="registerLoading" @click="handleRegister">
                    注册
                </el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { login, register, type User as UserType, type LoginRequest } from '@/api/user'

const router = useRouter()

// 登录相关
const loginFormRef = ref<FormInstance>()
const loginForm = reactive({
    username: '',
    password: ''
})
const loading = ref(false)

const loginRules: FormRules = {
    username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
    password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
    if (!loginFormRef.value) return

    const valid = await loginFormRef.value.validate()
    if (!valid) return

    loading.value = true
    try {
        const response = await login(loginForm as LoginRequest)
        if (response.success) {
            ElMessage.success('登录成功')
            // 保存用户信息到本地存储
            localStorage.setItem('user', JSON.stringify(response.data))
            // 跳转到首页
            router.push('/')
        } else {
            ElMessage.error(response.message || '登录失败')
        }
    } catch (error: any) {
        // 错误信息已经在拦截器中显示
        console.error('Login error:', error)
    } finally {
        loading.value = false
    }
}

// 注册相关
const showRegister = ref(false)
const registerFormRef = ref<FormInstance>()
const registerForm = reactive({
    username: '',
    password: '',
    confirmPassword: '',
    role: 'student',
    userClass: ''
})
const registerLoading = ref(false)

const validateConfirmPassword = (rule: any, value: string, callback: any) => {
    if (value !== registerForm.password) {
        callback(new Error('两次输入的密码不一致'))
    } else {
        callback()
    }
}

const registerRules: FormRules = {
    username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
    password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
    confirmPassword: [
        { required: true, message: '请确认密码', trigger: 'blur' },
        { validator: validateConfirmPassword, trigger: 'blur' }
    ],
    role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const handleRegister = async () => {
    if (!registerFormRef.value) return

    const valid = await registerFormRef.value.validate()
    if (!valid) return

    registerLoading.value = true
    try {
        // 构造注册数据
        const registerData: UserType = {
            username: registerForm.username,
            password: registerForm.password,
            role: registerForm.role,
            userClass: registerForm.role === 'student' ? registerForm.userClass : undefined
        }

        const response = await register(registerData)
        if (response.success) {
            ElMessage.success('注册成功')
            showRegister.value = false
            // 清空表单
            registerFormRef.value.resetFields()
        } else {
            ElMessage.error(response.message || '注册失败')
        }
    } catch (error: any) {
        console.error('Register error:', error)
    } finally {
        registerLoading.value = false
    }
}
</script>

<style scoped>
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
    width: 400px;
}

.login-header {
    text-align: center;
}

.login-header h2 {
    margin: 0;
    color: #409eff;
}

.login-header p {
    margin: 10px 0 0;
    color: #909399;
}

.login-footer {
    text-align: center;
    margin-top: 20px;
}
</style>