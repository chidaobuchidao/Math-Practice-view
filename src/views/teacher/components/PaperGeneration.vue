<template>
  <div class="paper-generation">
    <div class="toolbar">
      <h3>试卷生成</h3>
      <el-button type="primary" @click="showGenerateDialog = true">
        <el-icon>
          <Plus />
        </el-icon>
        生成新试卷
      </el-button>
    </div>

    <!-- 试卷列表 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>已生成的试卷</span>
          <div class="header-stats">
            共 <el-tag type="primary">{{ papers.length }}</el-tag> 份试卷
          </div>
        </div>
      </template>

      <el-table :data="papers" v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="试卷ID" width="100" align="center" />
        <el-table-column prop="title" label="试卷标题" />
        <el-table-column prop="studentId" label="学生ID" width="100" align="center" />
        <el-table-column label="学生姓名" width="120">
          <template #default="{ row }">
            {{ getStudentName(row.studentId) }}
          </template>
        </el-table-column>
        <el-table-column prop="totalQuestions" label="题目数量" width="100" align="center" />
        <el-table-column prop="score" label="得分" width="100" align="center">
          <template #default="{ row }">
            <span v-if="row.score !== null && row.score !== undefined">
              {{ row.score }} 分
            </span>
            <el-tag v-else type="info" size="small">未批改</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="viewPaperDetail(row.id)">
              查看详情
            </el-button>
            <el-button type="danger" size="small" @click="handleDeletePaper(row.id)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 生成试卷对话框 -->
    <el-dialog v-model="showGenerateDialog" title="生成新试卷" width="800px">
      <el-form :model="paperForm" :rules="paperRules" ref="paperFormRef" label-width="100px">
        <el-form-item label="试卷标题" prop="title">
          <el-input v-model="paperForm.title" placeholder="请输入试卷标题，如：三年级数学期中测试" />
        </el-form-item>

        <el-form-item label="选择学生" prop="studentId">
          <el-select v-model="paperForm.studentId" placeholder="请选择学生" style="width: 100%">
            <el-option v-for="student in students" :key="student.id"
              :label="`${student.username} (${student.userClass || '未设置班级'})`" :value="student.id" />
          </el-select>
        </el-form-item>

        <!-- 移除这里的 template 标签 -->

        <el-form-item label="选择题目" prop="questionIds">
          <div class="questions-selector">
            <div class="selector-header">
              <span>已选择 {{ paperForm.questionIds.length }} 道题目</span>
              <el-button type="text" @click="selectAllQuestions">全选</el-button>
              <el-button type="text" @click="clearSelection">清空</el-button>
            </div>

            <!-- 在这里添加随机选择控件 -->
            <div class="random-selector" v-if="availableQuestions.length > 0">
              <el-form :model="randomSelectForm" inline>
                <el-form-item label="随机选择">
                  <el-input-number v-model="randomSelectForm.count" :min="1" :max="availableQuestions.length"
                    size="small" style="width: 100px" />
                </el-form-item>

                <el-form-item label="难度">
                  <el-select v-model="randomSelectForm.difficulty" clearable size="small" style="width: 100px">
                    <el-option label="不限" value=""></el-option>
                    <el-option label="简单" value="easy"></el-option>
                    <el-option label="中等" value="medium"></el-option>
                    <el-option label="困难" value="hard"></el-option>
                  </el-select>
                </el-form-item>

                <el-form-item label="类型">
                  <el-select v-model="randomSelectForm.type" clearable size="small" style="width: 120px">
                    <el-option label="不限" value=""></el-option>
                    <el-option label="加减运算" value="AddAdnSub"></el-option>
                    <el-option label="乘除运算" value="MulAndDiv"></el-option>
                    <el-option label="混合运算" value="Mixed"></el-option>
                  </el-select>
                </el-form-item>

                <el-form-item>
                  <el-button type="primary" size="small" @click="randomSelectQuestions">
                    随机选择
                  </el-button>
                </el-form-item>
              </el-form>
            </div>

            <div class="questions-list">
              <el-checkbox-group v-model="paperForm.questionIds" style="width: 100%">
                <div class="question-item" v-for="question in availableQuestions" :key="question.id">
                  <el-checkbox :label="question.id">
                    <div class="question-content">
                      <span class="question-text">{{ question.content }}</span>
                      <div class="question-meta">
                        <el-tag size="small" :type="getTypeTagType(question.type)">
                          {{ getTypeText(question.type) }}
                        </el-tag>
                        <el-tag size="small" :type="getDifficultyTagType(question.difficulty)">
                          {{ getDifficultyText(question.difficulty) }}
                        </el-tag>
                        <span class="answer">答案: {{ question.answer }}</span>
                      </div>
                    </div>
                  </el-checkbox>
                </div>
              </el-checkbox-group>
            </div>

            <div class="selector-footer" v-if="availableQuestions.length === 0">
              <el-empty description="暂无题目，请先添加题目" />
            </div>
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showGenerateDialog = false">取消</el-button>
        <el-button type="primary" @click="handleGeneratePaper" :loading="generating">
          生成试卷
        </el-button>
      </template>
    </el-dialog>

    <!-- 试卷详情对话框 -->
    <el-dialog v-model="showDetailDialog" :title="`试卷详情 - ${currentPaper?.title}`" width="900px">
      <div v-if="currentPaperDetail">
        <el-descriptions :column="2" border style="margin-bottom: 20px;">
          <el-descriptions-item label="试卷ID">{{ currentPaperDetail.paper.id }}</el-descriptions-item>
          <el-descriptions-item label="学生">{{ getStudentName(currentPaperDetail.paper.studentId)
            }}</el-descriptions-item>
          <el-descriptions-item label="题目数量">{{ currentPaperDetail.paper.totalQuestions }}</el-descriptions-item>
          <el-descriptions-item label="得分">
            <span v-if="currentPaperDetail.paper.score !== null && currentPaperDetail.paper.score !== undefined">
              {{ currentPaperDetail.paper.score }} 分
            </span>
            <el-tag v-else type="info" size="small">未批改</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDate(currentPaperDetail.paper.createdAt) }}</el-descriptions-item>
        </el-descriptions>

        <h4>题目列表</h4>
        <el-table :data="currentPaperDetail.questions" style="width: 100%">
          <el-table-column prop="id" label="题目ID" width="80" />
          <el-table-column prop="content" label="题目内容" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag size="small" :type="getTypeTagType(row.type)">
                {{ getTypeText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="difficulty" label="难度" width="80">
            <template #default="{ row }">
              <el-tag size="small" :type="getDifficultyTagType(row.difficulty)">
                {{ getDifficultyText(row.difficulty) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="answer" label="答案" width="100" />
        </el-table>
      </div>

      <template #footer>
        <el-button @click="showDetailDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { userApi } from '@/api/user'
import { questionApi } from '@/api/question'
import { paperApi } from '@/api/paper'

const papers = ref([])
const loading = ref(false)
const generating = ref(false)
const showGenerateDialog = ref(false)
const showDetailDialog = ref(false)
const students = ref([])
const availableQuestions = ref([])
const currentPaper = ref(null)
const currentPaperDetail = ref(null)

const paperFormRef = ref()

const paperForm = reactive({
  title: '',
  studentId: null,
  questionIds: []
})

const paperRules = {
  title: [
    { required: true, message: '请输入试卷标题', trigger: 'blur' }
  ],
  studentId: [
    { required: true, message: '请选择学生', trigger: 'change' }
  ],
  questionIds: [
    { required: true, message: '请至少选择一道题目', trigger: 'change' }
  ]
}

// 加载试卷列表
const loadPapers = async () => {
  try {
    loading.value = true
    // 调用 API 获取所有试卷列表
    const response = await paperApi.getAllPapers()
    papers.value = response.data || []
    ElMessage.success(`成功加载 ${papers.value.length} 份试卷`)
  } catch (error) {
    ElMessage.error('加载试卷列表失败: ' + error.message)
    papers.value = []
  } finally {
    loading.value = false
  }
}

// 加载学生列表
const loadStudents = async () => {
  try {
    const response = await userApi.getStudents()
    students.value = response.data || []
  } catch (error) {
    ElMessage.error('加载学生列表失败: ' + error.message)
  }
}

// 加载可用题目
const loadAvailableQuestions = async () => {
  try {
    const response = await questionApi.getAllQuestions()
    availableQuestions.value = response.data || []
  } catch (error) {
    ElMessage.error('加载题目失败: ' + error.message)
  }
}

// 添加随机选择表单
const randomSelectForm = reactive({
  count: 5,
  difficulty: '',
  type: ''
})

// 随机选择题目方法
const randomSelectQuestions = () => {
  // 获取符合条件的题目
  let filteredQuestions = [...availableQuestions.value]

  // 根据难度过滤
  if (randomSelectForm.difficulty) {
    filteredQuestions = filteredQuestions.filter(q => q.difficulty === randomSelectForm.difficulty)
  }

  // 根据类型过滤
  if (randomSelectForm.type) {
    filteredQuestions = filteredQuestions.filter(q => q.type === randomSelectForm.type)
  }

  if (filteredQuestions.length === 0) {
    ElMessage.warning('没有符合条件的题目')
    return
  }

  // 如果选择数量超过符合条件的题目数量，则调整为最大数量
  const count = Math.min(randomSelectForm.count, filteredQuestions.length)

  // 随机打乱数组
  const shuffled = [...filteredQuestions].sort(() => 0.5 - Math.random())

  // 取前count个题目
  const selectedQuestions = shuffled.slice(0, count)

  // 更新选择的题目ID
  paperForm.questionIds = selectedQuestions.map(q => q.id)

  ElMessage.success(`成功随机选择了 ${count} 道题目`)
}
// 生成试卷
const handleGeneratePaper = async () => {
  try {
    await paperFormRef.value.validate()

    if (paperForm.questionIds.length === 0) {
      ElMessage.warning('请至少选择一道题目')
      return
    }

    generating.value = true

    const response = await paperApi.generatePaper(paperForm)
    ElMessage.success('试卷生成成功')
    showGenerateDialog.value = false

    // 重置表单
    Object.assign(paperForm, {
      title: '',
      studentId: null,
      questionIds: []
    })

    // 重新加载试卷列表
    loadPapers()
  } catch (error) {
    ElMessage.error('生成试卷失败: ' + error.message)
  } finally {
    generating.value = false
  }
}

// 删除试卷
const handleDeletePaper = async (paperId) => {
  try {
    await ElMessageBox.confirm('确定要删除这份试卷吗？此操作不可恢复！', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await paperApi.deletePaper(paperId)
    ElMessage.success('试卷删除成功')
    loadPapers() // 重新加载列表
  } catch (error) {
    if (error.message && !error.message.includes('cancel')) {
      ElMessage.error('删除试卷失败: ' + error.message)
    }
  }
}

// 查看试卷详情
const viewPaperDetail = async (paperId) => {
  try {
    const response = await paperApi.getPaperDetail(paperId)
    currentPaperDetail.value = response.data
    currentPaper.value = response.data.paper
    showDetailDialog.value = true
  } catch (error) {
    ElMessage.error('加载试卷详情失败: ' + error.message)
  }
}

// 全选题目
const selectAllQuestions = () => {
  paperForm.questionIds = availableQuestions.value.map(q => q.id)
}

// 清空选择
const clearSelection = () => {
  paperForm.questionIds = []
}

// 根据学生ID获取学生姓名
const getStudentName = (studentId) => {
  const student = students.value.find(s => s.id === studentId)
  return student ? student.username : '未知'
}

// 工具函数
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
    'AddAdnSub': 'primary',
    'MulAndDiv': 'success',
    'Mixed': 'warning'
  }
  return map[type] || 'info'
}

const getDifficultyText = (difficulty) => {
  const map = {
    'easy': '简单',
    'medium': '中等',
    'hard': '困难'
  }
  return map[difficulty] || difficulty
}

const getDifficultyTagType = (difficulty) => {
  const map = {
    'easy': 'success',
    'medium': 'warning',
    'hard': 'danger'
  }
  return map[difficulty] || 'info'
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
  loadPapers()
  loadStudents()
  loadAvailableQuestions()
})
</script>

<style scoped>
.paper-generation {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
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

.questions-selector {
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  max-height: 400px;
  overflow: auto;
}

.selector-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 15px;
  background-color: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
}

.questions-list {
  padding: 10px;
}

.question-item {
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.question-item:last-child {
  border-bottom: none;
}

.question-content {
  margin-left: 8px;
}

.question-text {
  display: block;
  margin-bottom: 4px;
  font-weight: 500;
}

.question-meta {
  display: flex;
  gap: 8px;
  align-items: center;
}

.answer {
  font-size: 12px;
  color: #666;
}

.selector-footer {
  padding: 20px;
  text-align: center;
}

.random-selector {
  padding: 10px 15px;
  background-color: #f9f9f9;
  border-bottom: 1px solid #e4e7ed;
}

.random-selector .el-form-item {
  margin-bottom: 0;
  margin-right: 15px;
}

.random-selector .el-form-item:last-child {
  margin-right: 0;
}
</style>