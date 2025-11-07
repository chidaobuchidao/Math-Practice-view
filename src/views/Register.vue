<template>
    <div class="register-container">
        <el-card class="register-card">
            <template #header>
                <div class="register-header">
                    <h2>用户注册</h2>
                    <p>创建您的账户</p>
                </div>
            </template>

            <el-form :model="registerForm" :rules="registerRules" ref="registerFormRef" label-width="80px">
                <el-form-item label="用户名" prop="username">
                    <el-input v-model="registerForm.username" placeholder="请输入用户名">
                        <template #append>
                            <el-button @click="checkUsername" :loading="checkingUsername">
                                检查
                            </el-button>
                        </template>
                    </el-input>
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
                        <el-radio label="teacher">教师</el-radio>
                    </el-radio-group>
                </el-form-item>

                <el-form-item label="班级" prop="userClass" v-if="registerForm.role === 'student'">
                    <el-input v-model="registerForm.userClass" placeholder="请输入班级" />
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" :loading="loading" @click="handleRegister" style="width: 100%">
                        {{ loading ? '注册中...' : '注册' }}
                    </el-button>
                </el-form-item>
            </el-form>

            <div class="register-footer">
                <el-button type="text" @click="goToLogin">
                    已有账号？立即登录
                </el-button>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { userApi } from '@/api/user'

const router = useRouter()
const loading = ref(false)
const checkingUsername = ref(false)
const registerFormRef = ref()
const usernameAvailable = ref(false)

const registerForm = reactive({
    username: '',
    password: '',
    confirmPassword: '',
    role: 'student',
    userClass: ''
})

const validateConfirmPassword = (rule, value, callback) => {
    if (value !== registerForm.password) {
        callback(new Error('两次输入的密码不一致'))
    } else {
        callback()
    }
}

const registerRules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
    ],
    confirmPassword: [
        { required: true, message: '请确认密码', trigger: 'blur' },
        { validator: validateConfirmPassword, trigger: 'blur' }
    ],
    role: [
        { required: true, message: '请选择角色', trigger: 'change' }
    ]
}

// 检查用户名是否可用 - 修复逻辑
const checkUsername = async () => {
    if (!registerForm.username) {
        ElMessage.warning('请输入用户名')
        return false
    }

    try {
        checkingUsername.value = true
        const response = await userApi.checkUsername(registerForm.username)
        usernameAvailable.value = !response.data
        
        if (usernameAvailable.value) {
            ElMessage.success('用户名可用')
        } else {
            ElMessage.error('用户名已存在')
        }
        return usernameAvailable.value
    } catch (error) {
        console.error('检查用户名失败:', error)
        ElMessage.error('检查用户名失败，请重试')
        return false
    } finally {
        checkingUsername.value = false
    }
}

// 修复注册处理逻辑
// 修复注册处理逻辑
const handleRegister = async () => {
    if (!registerFormRef.value) return

    try {
        // 验证表单
        await registerFormRef.value.validate()

        // 检查用户名可用性
        if (!usernameAvailable.value) {
            // 如果还没有检查过用户名，先检查
            if (registerForm.username) {
                await checkUsername()
                if (!usernameAvailable.value) {
                    ElMessage.warning('用户名已存在，请更换用户名')
                    return
                }
            } else {
                ElMessage.warning('请先输入并检查用户名')
                return
            }
        }

        loading.value = true

        // 准备注册数据 - 确保字段名与后端一致
        const registerData = {
            username: registerForm.username,
            password: registerForm.password,
            role: registerForm.role,
            userClass: registerForm.userClass || '' // 确保即使为空也发送
        }

        console.log('发送注册数据:', registerData)

        // 发送注册请求
        const response = await userApi.register(registerData)
        
        console.log('注册响应:', response)

        // 注册成功
        ElMessage.success(response.message || '注册成功！')

        // 注册成功后跳转到登录页面
        setTimeout(() => {
            router.push('/login')
        }, 1500)

    } catch (error) {
        console.error('注册失败:', error)
        // 显示具体的错误信息
        if (error.message && error.message.includes('用户名已存在')) {
            ElMessage.error('用户名已存在，请更换用户名')
            usernameAvailable.value = false
        } else {
            ElMessage.error(error.message || '注册失败，请重试')
        }
    } finally {
        loading.value = false
    }
}

const goToLogin = () => {
    router.push('/login')
}

// 监听用户名变化，重置检查状态
watch(() => registerForm.username, () => {
    usernameAvailable.value = false
})
</script>

<style scoped>
.register-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.register-card {
    width: 500px;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.register-header {
    text-align: center;
}

.register-header h2 {
    margin: 0;
    color: #333;
}

.register-header p {
    margin: 10px 0 0;
    color: #666;
}

.register-footer {
    text-align: center;
    margin-top: 20px;
}
</style>