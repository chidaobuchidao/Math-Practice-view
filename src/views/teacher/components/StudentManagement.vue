<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, Plus, User, School, Document, Search } from '@element-plus/icons-vue'
import { userApi } from '@/api/user'
import { paperApi } from '@/api/paper'
import { questionApi } from '@/api/question'
import { getTypeName, getTypeTagType, getDifficultyTagType, getDifficultyName } from '@/utils/type'

const allStudents = ref([]) // 存储所有学生
const filteredStudents = ref([]) // 存储筛选后的学生
const loading = ref(false)
const adding = ref(false)
const showAddDialog = ref(false)
const showPapersDialog = ref(false)
const showPaperDetailDialog = ref(false)
const papersLoading = ref(false)
const studentPapers = ref([])
const selectedStudent = ref(null)
const currentPaperDetail = ref(null)

// 搜索和筛选条件
const searchName = ref('')
const filterClass = ref('')

// 分页配置
const pagination = reactive({
  currentPage: 1,
  pageSize: 50,
  total: 0
})

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
    { min: 1, message: '用户名不能为空', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 1, message: '密码不能为空', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

// 当前页显示的学生
const currentPageStudents = computed(() => {
  const start = (pagination.currentPage - 1) * pagination.pageSize
  const end = start + pagination.pageSize
  return filteredStudents.value.slice(start, end)
})

// 计算班级数量
const classCount = computed(() => {
  const classes = new Set(allStudents.value.map(student => student.userClass).filter(Boolean))
  return classes.size
})

// 班级列表
const classList = computed(() => {
  const classes = new Set(allStudents.value.map(student => student.userClass).filter(Boolean))
  return Array.from(classes).sort()
})

// 总试卷数（模拟数据）
const totalPapers = computed(() => {
  return allStudents.value.length * 2 // 模拟每个学生有2份试卷
})

// 加载学生列表
const loadStudents = async () => {
  try {
    loading.value = true
    const response = await userApi.getStudents()
    // 按ID排序
    allStudents.value = (response.data || []).sort((a, b) => a.id - b.id)

    // 初始化筛选后的数据
    applyFilters()
  } catch (error) {
    ElMessage.error('加载学生列表失败: ' + error.message)
    allStudents.value = []
    filteredStudents.value = []
  } finally {
    loading.value = false
  }
}

// 应用筛选条件
const applyFilters = () => {
  let filtered = [...allStudents.value]

  // 姓名搜索
  if (searchName.value) {
    filtered = filtered.filter(student =>
      student.username && student.username.toLowerCase().includes(searchName.value.toLowerCase())
    )
  }

  // 班级筛选
  if (filterClass.value) {
    filtered = filtered.filter(student => student.userClass === filterClass.value)
  }

  filteredStudents.value = filtered
  pagination.total = filteredStudents.value.length
  pagination.currentPage = 1 // 重置到第一页
}

// 处理搜索
const handleSearch = () => {
  applyFilters()
}

// 重置搜索
const resetSearch = () => {
  searchName.value = ''
  filterClass.value = ''
  applyFilters()
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
    // 按ID排序
    studentPapers.value = (response.data || []).sort((a, b) => a.id - b.id)
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
    currentPaperDetail.value = response.data

    // 确保题目信息完整
    if (currentPaperDetail.value.questions) {
      await enhanceQuestionsWithDetails(currentPaperDetail.value.questions)
    }

    showPaperDetailDialog.value = true
    ElMessage.success('试卷详情加载成功')
  } catch (error) {
    ElMessage.error('加载试卷详情失败: ' + error.message)
  }
}

// 增强题目信息，获取类型和答案等详细信息
const enhanceQuestionsWithDetails = async (questions) => {
  try {
    for (let question of questions) {
      // 如果题目信息不完整，获取完整题目详情
      if (!question.typeId || !question.answers) {
        try {
          const questionDetail = await questionApi.getQuestionById(question.id)
          if (questionDetail.data) {
            // 合并题目详情
            Object.assign(question, questionDetail.data)
          }
        } catch (error) {
          console.warn(`获取题目 ${question.id} 详情失败:`, error)
        }
      }
    }
  } catch (error) {
    console.warn('增强题目信息失败:', error)
  }
}

// 使用工具库中的名称函数以保持一致
const getTypeText = getTypeName

// 使用共享工具库提供的标签样式函数 (getTypeTagType 已导入)

// 使用工具库中的难度名称和标签样式
const getDifficultyText = getDifficultyName

// 获取题目答案（从答案表中获取正确答案）
const getQuestionAnswer = (answers) => {
  if (!answers || answers.length === 0) return '无答案'

  // 查找正确答案
  const correctAnswer = answers.find(answer => answer.isCorrect)
  if (correctAnswer) {
    return correctAnswer.content
  }

  // 如果没有标记正确答案，返回第一个答案
  return answers[0]?.content || '无答案'
}

// 分页大小改变
const handleSizeChange = (newSize) => {
  pagination.pageSize = newSize
  pagination.currentPage = 1
}

// 当前页改变
const handleCurrentChange = (newPage) => {
  pagination.currentPage = newPage
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

<template>
  <div class="student-management">
    <div class="toolbar">
      <h3>学生管理</h3>
    </div>

    <!-- 筛选工具栏 -->
    <div class="filter-toolbar">
      <div class="toolbar-actions">
        <el-button type="primary" @click="loadStudents" :loading="loading">
          <el-icon>
            <Refresh />
          </el-icon>
          刷新
        </el-button>
        <el-button type="success" @click="showAddDialog = true" style="margin-right: 25px;">
          <el-icon>
            <Plus />
          </el-icon>
          添加学生
        </el-button>
      </div>
      <el-input v-model="searchName" placeholder="搜索学生姓名" clearable style="width: 200px; margin-right: 10px;"
        @clear="handleSearch" @keyup.enter="handleSearch">
        <template #prefix>
          <el-icon>
            <Search />
          </el-icon>
        </template>
      </el-input>

      <el-select v-model="filterClass" placeholder="选择班级" clearable style="width: 150px; margin-right: 10px;">
        <el-option label="全部班级" value=""></el-option>
        <el-option v-for="className in classList" :key="className" :label="className" :value="className" />
      </el-select>

      <el-button type="primary" @click="handleSearch">
        <el-icon>
          <Search />
        </el-icon>
        搜索
      </el-button>
      <el-button @click="resetSearch">
        <el-icon>
          <Refresh />
        </el-icon>
        重置
      </el-button>
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
              <div class="stats-number">{{ pagination.total }}</div>
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
            共 <el-tag type="primary">{{ pagination.total }}</el-tag> 名学生
            <span v-if="filteredStudents.length !== allStudents.length" class="filtered-count">
              (筛选出 {{ filteredStudents.length }} 名)
            </span>
          </div>
        </div>
      </template>

      <!-- 学生列表表格 -->
      <el-table :data="currentPageStudents" v-loading="loading" style="width: 100%">
        <el-table-column type="index" label="序号" width="60" align="center" fixed="left" />
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

      <!-- 分页组件 -->
      <div class="pagination-container">
        <el-pagination v-model:current-page="pagination.currentPage" v-model:page-size="pagination.pageSize"
          :page-sizes="[20, 50, 100, 200]" :total="pagination.total" layout="sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange" @current-change="handleCurrentChange" />
      </div>
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
          <el-select v-model="newStudent.userClass" placeholder="请选择班级" style="width: 100%">
            <el-option label="未设置班级" value=""></el-option>
            <el-option v-for="className in classList" :key="className" :label="className" :value="className" />
            <el-option label="添加新班级" value="__new__">
              <span style="float: left">添加新班级</span>
              <span style="float: right; color: #8492a6; font-size: 13px">+</span>
            </el-option>
          </el-select>
          <el-input v-if="newStudent.userClass === '__new__'" v-model="newClass" placeholder="请输入新班级名称"
            style="margin-top: 8px" />
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
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="id" label="试卷ID" width="100" />
        <el-table-column prop="title" label="试卷标题" />
        <el-table-column prop="totalQuestions" label="题目数量" width="100" />
        <el-table-column prop="score" label="得分" width="100">
          <template #default="{ row }">
            {{ row.score !== null && row.score !== undefined ? row.score + ' 分' : '未批改' }}
          </template>
        </el-table-column>
        <el-table-column prop="correctCount" label="正确题数" width="100">
          <template #default="{ row }">
            {{ row.correctCount !== null && row.correctCount !== undefined ? row.correctCount + '/' + row.totalQuestions
              : '--' }}
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
            <el-table-column type="index" label="序号" width="60" align="center" />
            <el-table-column prop="id" label="题目ID" width="80" align="center" />
            <el-table-column prop="content" label="题目内容" min-width="200" />
            <el-table-column label="类型" width="120">
              <template #default="{ row }">
                <el-tag :type="getTypeTagType(row.typeId)">
                  {{ getTypeText(row.typeId) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="难度" width="100">
              <template #default="{ row }">
                <el-tag :type="getDifficultyTagType(row.difficultyId)">
                  {{ getDifficultyText(row.difficultyId) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="正确答案" width="120" align="center">
              <template #default="{ row }">
                <strong>{{ getQuestionAnswer(row.answers) }}</strong>
              </template>
            </el-table-column>
            <el-table-column label="学生答案" width="120" align="center">
              <template #default="{ row }">
                <span :class="{ 'correct-answer': row.isCorrect, 'wrong-answer': !row.isCorrect }">
                  {{ row.studentAnswer || '未作答' }}
                </span>
              </template>
            </el-table-column>
            <el-table-column label="是否正确" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="row.isCorrect ? 'success' : 'danger'">
                  {{ row.isCorrect ? '正确' : '错误' }}
                </el-tag>
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

.header-stats {
  font-size: 14px;
  color: #666;
}

.filtered-count {
  color: #409eff;
  font-weight: 500;
  margin-left: 8px;
}

/* 筛选工具栏 */
.filter-toolbar {
  margin-bottom: 15px;
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  border: 1px solid #ebeef5;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  border-radius: 4px;
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

/* 分页样式 */
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
  padding: 20px 0;
}

.correct-answer {
  color: #67c23a;
  font-weight: bold;
}

.wrong-answer {
  color: #f56c6c;
  font-weight: bold;
}
</style>