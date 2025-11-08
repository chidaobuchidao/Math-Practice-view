<template>
  <div class="student-management">
    <div class="toolbar">
      <h3>学生管理</h3>
      <div class="toolbar-actions">
        <el-button type="primary" @click="loadStudents" :loading="loading">
          <el-icon>
            <Refresh />
          </el-icon>
          刷新
        </el-button>
        <el-button type="success" @click="showAddDialog = true">
          <el-icon>
            <Plus />
          </el-icon>

          添加学生
        </el-button>
      </div>
    </div>

    <!-- 统计信息 -->
    <el-row :gutter="20" style="margin-top: 20px; margin-bottom: 20px;">
      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #ecf5ff;">
              <el-icon>
                <User />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ students.length }}</div>
              <div class="stats-label">总学生数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #f0f9ff;">
              <el-icon>
                <School />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ classCount }}</div>
              <div class="stats-label">班级数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #fdf6ec;">
              <el-icon>
                <Document />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ totalPapers }}</div>
              <div class="stats-label">总试卷数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 学生列表 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>学生列表</span>
          <div class="header-stats">
            共 <el-tag type="primary">{{ students.length }}</el-tag> 名学生
          </div>
        </div>
      </template>
      <!-- 学生列表表格 -->
      <el-table :data="students" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="学生ID" width="100" align="center" fixed="left" />
        <el-table-column prop="username" label="用户名" width="150" fixed="left" />
        <el-table-column prop="userClass" label="班级" width="150" fixed="left">
          <template #default="{ row }">
            <el-tag v-if="row.userClass" type="success">{{ row.userClass }}</el-tag>
            <el-tag v-else type="info">未设置</el-tag>
          </template>
        </el-table-column>
        <!-- 调整注册时间的固定宽度，让它自适应 -->
        <el-table-column prop="createdAt" label="注册时间" min-width="180">
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default>
            <el-tag type="success">正常</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="viewStudentPapers(row)">
              查看试卷
            </el-button>
            <el-button type="danger" size="small" @click="handleDeleteStudent(row.id)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加学生对话框 -->
    <el-dialog v-model="showAddDialog" title="添加学生" width="500px">
      <el-form :model="newStudent" :rules="studentRules" ref="studentFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="newStudent.username" placeholder="请输入用户名" />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input v-model="newStudent.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>

        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="newStudent.confirmPassword" type="password" placeholder="请再次输入密码" show-password />
        </el-form-item>

        <el-form-item label="班级" prop="userClass">
          <el-input v-model="newStudent.userClass" placeholder="请输入班级" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleAddStudent" :loading="adding">
          确认添加
        </el-button>
      </template>
    </el-dialog>

    <!-- 学生试卷对话框 -->
    <el-dialog v-model="showPapersDialog" :title="`${selectedStudent?.username}的试卷列表`" width="800px">
      <el-table :data="studentPapers" v-loading="papersLoading">
        <el-table-column prop="id" label="试卷ID" width="100" />
        <el-table-column prop="title" label="试卷标题" />
        <el-table-column prop="totalQuestions" label="题目数量" width="100" />
        <el-table-column prop="score" label="得分" width="100">
          <template #default="{ row }">
            {{ row.score || '未批改' }}
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="viewPaperDetail(row.id)">
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <template #footer>
        <el-button @click="showPapersDialog = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 试卷详情对话框 -->
    <el-dialog v-model="showPaperDetailDialog" :title="`试卷详情 - ${currentPaperDetail?.paper?.title || '未知试卷'}`"
      width="900px">
      <div v-if="currentPaperDetail">
        <!-- 试卷基本信息 -->
        <el-card style="margin-bottom: 20px;">
          <template #header>
            <div class="card-header">
              <span>试卷信息</span>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="试卷ID">{{ currentPaperDetail.paper.id }}</el-descriptions-item>
            <el-descriptions-item label="试卷标题">{{ currentPaperDetail.paper.title }}</el-descriptions-item>
            <el-descriptions-item label="总题数">{{ currentPaperDetail.paper.totalQuestions }}</el-descriptions-item>
            <el-descriptions-item label="正确题数">{{ currentPaperDetail.paper.correctCount }}</el-descriptions-item>
            <el-descriptions-item label="得分">{{ currentPaperDetail.paper.score }}</el-descriptions-item>
            <el-descriptions-item label="用时">{{ currentPaperDetail.paper.timeSpent }}秒</el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ formatDate(currentPaperDetail.paper.createdAt)
            }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
        <!-- 题目列表 -->
        <el-card>
          <template #header>
            <div class="card-header">
              <span>题目列表 (共 {{ currentPaperDetail.questions.length }} 题)</span>
            </div>
          </template>
          <el-table :data="currentPaperDetail.questions" style="width: 100%">
            <el-table-column prop="id" label="题目ID" width="80" align="center" />
            <el-table-column prop="content" label="题目内容" min-width="200" />
            <el-table-column prop="type" label="类型" width="120">
              <template #default="{ row }">
                <el-tag :type="getTypeTagType(row.type)">
                  {{ getTypeText(row.type) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="difficulty" label="难度" width="100">
              <template #default="{ row }">
                <el-tag
                  :type="row.difficulty === 'easy' ? 'success' : row.difficulty === 'medium' ? 'warning' : 'danger'">
                  {{ row.difficulty === 'easy' ? '简单' : row.difficulty === 'medium' ? '中等' : '困难' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="answer" label="答案" width="100" align="center">
              <template #default="{ row }">
                <strong>{{ row.answer }}</strong>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>

      <template #footer>
        <el-button @click="showPaperDetailDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Plus, User, School, Document } from '@element-plus/icons-vue'
import { userApi } from '@/api/user'
import { paperApi } from '@/api/paper'

const students = ref([])
const loading = ref(false)
const adding = ref(false)
const showAddDialog = ref(false)
const showPapersDialog = ref(false)
const showPaperDetailDialog = ref(false) // 新增：试卷详情对话框
const papersLoading = ref(false)
const studentPapers = ref([])
const selectedStudent = ref(null)
const currentPaperDetail = ref(null) // 新增：当前试卷详情

const studentFormRef = ref()

const newStudent = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  userClass: '',
  role: 'student'
})

// 验证规则
const validateConfirmPassword = (rule, value, callback) => {
  if (value !== newStudent.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const studentRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, message: '用户名长度不能少于3位', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

// 计算班级数量
const classCount = computed(() => {
  const classes = new Set(students.value.map(student => student.userClass).filter(Boolean))
  return classes.size
})

// 总试卷数（模拟数据）
const totalPapers = computed(() => {
  return students.value.length * 2 // 模拟每个学生有2份试卷
})

// 加载学生列表
const loadStudents = async () => {
  try {
    loading.value = true
    const response = await userApi.getStudents()
    students.value = response.data || []
  } catch (error) {
    ElMessage.error('加载学生列表失败: ' + error.message)
    students.value = []
  } finally {
    loading.value = false
  }
}

// 添加学生
const handleAddStudent = async () => {
  try {
    await studentFormRef.value.validate()
    adding.value = true

    await userApi.addUser(newStudent)
    ElMessage.success('学生添加成功')
    showAddDialog.value = false
    loadStudents() // 重新加载列表

    // 重置表单
    Object.assign(newStudent, {
      username: '',
      password: '',
      confirmPassword: '',
      userClass: '',
      role: 'student'
    })
  } catch (error) {
    if (error.message) {
      ElMessage.error('添加学生失败: ' + error.message)
    }
  } finally {
    adding.value = false
  }
}

// 删除学生
const handleDeleteStudent = async (studentId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个学生吗？此操作不可恢复！', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await userApi.deleteUser(studentId)
    ElMessage.success('学生删除成功')
    loadStudents() // 重新加载列表
  } catch (error) {
    if (error.message && !error.message.includes('cancel')) {
      ElMessage.error('删除学生失败: ' + error.message)
    }
  }
}

// 查看学生试卷
const viewStudentPapers = async (student) => {
  try {
    selectedStudent.value = student
    papersLoading.value = true
    showPapersDialog.value = true

    const response = await paperApi.getStudentPapers(student.id)
    studentPapers.value = response.data || []
  } catch (error) {
    ElMessage.error('加载学生试卷失败: ' + error.message)
    studentPapers.value = []
  } finally {
    papersLoading.value = false
  }
}

// 查看试卷详情
const viewPaperDetail = async (paperId) => {
  try {
    const response = await paperApi.getPaperDetail(paperId)
    currentPaperDetail.value = response.data // 保存完整的试卷详情
    showPaperDetailDialog.value = true // 打开详情对话框

    ElMessage.success('试卷详情加载成功')
  } catch (error) {
    ElMessage.error('加载试卷详情失败: ' + error.message)
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
      minute: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

onMounted(() => {
  loadStudents()
})
</script>

<style scoped>
.student-management {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.toolbar-actions {
  display: flex;
  gap: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

.header-stats {
  font-size: 14px;
  color: #666;
}
</style>