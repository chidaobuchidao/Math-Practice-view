<template>
  <div class="question-management">
    <div class="toolbar">
      <h3>题目管理</h3>
    </div>

    <!-- 顶部工具栏 - 修改后的扁平样式 -->
    <el-card class="filter-card" style="margin-bottom: 20px;">
      <div class="filters-container">
        <div class="filters-left"></div> <!-- 左侧占位，用于将内容推到右侧 -->
        <div class="toolbar-actions">
          <el-dropdown @command="handleGenerateCommand">
            <el-button type="primary">
              <el-icon>
                <Plus />
              </el-icon>
              生成题目
              <el-icon class="el-icon--right">
                <arrow-down />
              </el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="manual">手动添加题目</el-dropdown-item>
                <el-dropdown-item command="auto">自动生成题目</el-dropdown-item>
                <el-dropdown-item command="quick" divided>快速生成10题</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
        <div class="filters-right">
          <el-select v-model="filterType" placeholder="题目类型" clearable class="filter-item">
            <el-option label="加减运算" value="AddAndSub" />
            <el-option label="乘除运算" value="MulAndDiv" />
            <el-option label="混合运算" value="Mixed" />
          </el-select>

          <el-select v-model="filterDifficulty" placeholder="难度" clearable class="filter-item">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
          </el-select>

          <el-button type="primary" @click="loadQuestions" class="filter-item">
            <el-icon>
              <Search />
            </el-icon>
            筛选
          </el-button>
          <el-button @click="resetFilters" class="filter-item">
            <el-icon>
              <Refresh />
            </el-icon>
            重置
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 统计信息 -->
    <el-row gutter="20" style="margin-top: 20px; margin-bottom: 20px;">
      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #ecf5ff;">
              <el-icon>
                <Collection />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ questions.length }}</div>
              <div class="stats-label">总题目数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #f0f9ff;">
              <el-icon>
                <TrendCharts />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ typeCount }}</div>
              <div class="stats-label">题目类型数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #fdf6ec;">
              <el-icon>
                <DataAnalysis />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ difficultyCount }}</div>
              <div class="stats-label">难度等级数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 题目列表 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>题目列表</span>
          <div class="header-stats">
            共 <el-tag type="primary">{{ questions.length }}</el-tag> 道题目
          </div>
        </div>
      </template>

      <el-table :data="questions" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="content" label="题目内容" />
        <el-table-column prop="type" label="类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.type)">
              {{ getTypeText(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="difficulty" label="难度" width="100">
          <template #default="{ row }">
            <el-tag :type="getDifficultyTagType(row.difficulty)">
              {{ getDifficultyText(row.difficulty) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="answer" label="答案" width="100" />
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="handleDelete(row.id)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 手动添加/编辑题目对话框 -->
    <el-dialog v-model="showManualDialog" :title="dialogTitle" width="500px">
      <el-form :model="formData" :rules="questionRules" ref="questionFormRef">
        <el-form-item label="题目内容" prop="content">
          <el-input v-model="formData.content" placeholder="请输入题目内容" />
        </el-form-item>

        <el-form-item label="题目类型" prop="type">
          <el-select v-model="formData.type" placeholder="请选择类型">
            <el-option label="加减运算" value="AddAndSub" />
            <el-option label="乘除运算" value="MulAndDiv" />
            <el-option label="混合运算" value="Mixed" />
          </el-select>
        </el-form-item>

        <el-form-item label="难度" prop="difficulty">
          <el-select v-model="formData.difficulty" placeholder="请选择难度">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
          </el-select>
        </el-form-item>

        <el-form-item label="答案" prop="answer">
          <el-input-number v-model="formData.answer" :precision="2" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showManualDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          {{ isEditing ? '保存修改' : '确认添加' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 自动生成题目对话框 -->
    <el-dialog v-model="showAutoDialog" title="自动生成题目" width="600px">
      <el-form :model="generateForm" :rules="generateRules" ref="generateFormRef" label-width="120px">
        <el-form-item label="题目数量" prop="count">
          <el-input-number 
            v-model="generateForm.count" 
            :min="1" 
            :max="100" 
            placeholder="请输入生成题目数量" 
            style="width: 200px;" />
          <div class="form-tip">单次最多生成100道题目</div>
        </el-form-item>

        <el-form-item label="题目类型" prop="types">
          <el-checkbox-group v-model="generateForm.types">
            <el-checkbox label="AddAndSub">加减运算</el-checkbox>
            <el-checkbox label="MulAndDiv">乘除运算</el-checkbox>
            <el-checkbox label="Mixed">混合运算</el-checkbox>
          </el-checkbox-group>
        </el-form-item>

        <el-form-item label="难度等级" prop="difficulties">
          <el-checkbox-group v-model="generateForm.difficulties">
            <el-checkbox label="easy">简单</el-checkbox>
            <el-checkbox label="medium">中等</el-checkbox>
            <el-checkbox label="hard">困难</el-checkbox>
          </el-checkbox-group>
        </el-form-item>

        <el-collapse v-model="activeCollapse" style="margin: 20px 0;">
          <el-collapse-item title="高级设置（数字范围）" name="advanced">
            <el-form-item label="加减法范围">
              <el-input-number v-model="generateForm.numberRange.addSubMin" :min="1" :max="generateForm.numberRange.addSubMax" />
              <span style="margin: 0 10px;">至</span>
              <el-input-number v-model="generateForm.numberRange.addSubMax" :min="generateForm.numberRange.addSubMin" :max="1000" />
            </el-form-item>

            <el-form-item label="乘法范围">
              <el-input-number v-model="generateForm.numberRange.multiplicationMin" :min="1" :max="generateForm.numberRange.multiplicationMax" />
              <span style="margin: 0 10px;">至</span>
              <el-input-number v-model="generateForm.numberRange.multiplicationMax" :min="generateForm.numberRange.multiplicationMin" :max="100" />
            </el-form-item>

            <el-form-item label="除法范围">
              <el-input-number v-model="generateForm.numberRange.divisionMin" :min="1" :max="generateForm.numberRange.divisionMax" />
              <span style="margin: 0 10px;">至</span>
              <el-input-number v-model="generateForm.numberRange.divisionMax" :min="generateForm.numberRange.divisionMin" :max="100" />
            </el-form-item>

            <el-form-item label="混合运算范围">
              <el-input-number v-model="generateForm.numberRange.mixedMin" :min="1" :max="generateForm.numberRange.mixedMax" />
              <span style="margin: 0 10px;">至</span>
              <el-input-number v-model="generateForm.numberRange.mixedMax" :min="generateForm.numberRange.mixedMin" :max="1000" />
            </el-form-item>
          </el-collapse-item>
        </el-collapse>

        <el-form-item label="预览设置">
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="题目数量">{{ generateForm.count }}</el-descriptions-item>
            <el-descriptions-item label="题目类型">
              {{ generateForm.types.map(type => getTypeText(type)).join('、') }}
            </el-descriptions-item>
            <el-descriptions-item label="难度等级">
              {{ generateForm.difficulties.map(diff => getDifficultyText(diff)).join('、') }}
            </el-descriptions-item>
            <el-descriptions-item label="总类型组合">
              {{ generateForm.types.length * generateForm.difficulties.length }} 种
            </el-descriptions-item>
          </el-descriptions>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showAutoDialog = false">取消</el-button>
        <el-button @click="resetGenerateForm" :disabled="generating">重置</el-button>
        <el-button type="primary" @click="handleGenerate" :loading="generating">
          开始生成
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh, Search, Collection, TrendCharts, DataAnalysis, ArrowDown } from '@element-plus/icons-vue'
import { questionApi } from '@/api/question'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const questions = ref([])
const loading = ref(false)
const showManualDialog = ref(false)
const showAutoDialog = ref(false)
const submitting = ref(false)
const generating = ref(false)
const isEditing = ref(false)
const filterType = ref('')
const filterDifficulty = ref('')
const activeCollapse = ref([])

const questionFormRef = ref()
const generateFormRef = ref()

// 手动添加表单数据
const formData = reactive({
  id: null,
  content: '',
  type: '',
  difficulty: '',
  answer: 0,
  createdBy: userStore.userInfo?.id
})

// 自动生成表单数据
const generateForm = reactive({
  count: 10,
  types: ['AddAndSub', 'MulAndDiv', 'Mixed'],
  difficulties: ['easy', 'medium', 'hard'],
  createdBy: userStore.userInfo?.id,
  numberRange: {
    addSubMin: 1,
    addSubMax: 100,
    multiplicationMin: 1,
    multiplicationMax: 12,
    divisionMin: 1,
    divisionMax: 12,
    mixedMin: 1,
    mixedMax: 100
  }
})

// 计算对话框标题
const dialogTitle = computed(() => {
  return isEditing.value ? '编辑题目' : '手动添加题目'
})

// 计算统计信息
const typeCount = computed(() => {
  const types = new Set(questions.value.map(question => question.type).filter(Boolean))
  return types.size
})

const difficultyCount = computed(() => {
  const difficulties = new Set(questions.value.map(question => question.difficulty).filter(Boolean))
  return difficulties.size
})

// 验证规则
const questionRules = {
  content: [{ required: true, message: '请输入题目内容', trigger: 'blur' }],
  type: [{ required: true, message: '请选择题目类型', trigger: 'change' }],
  difficulty: [{ required: true, message: '请选择难度', trigger: 'change' }],
  answer: [{ required: true, message: '请输入答案', trigger: 'blur' }]
}

const generateRules = {
  count: [
    { required: true, message: '请输入题目数量', trigger: 'blur' },
    { type: 'number', min: 1, max: 100, message: '题目数量范围为1-100', trigger: 'blur' }
  ],
  types: [
    { required: true, message: '请至少选择一种题目类型', trigger: 'change' }
  ],
  difficulties: [
    { required: true, message: '请至少选择一种难度等级', trigger: 'change' }
  ]
}

// 处理生成命令
const handleGenerateCommand = (command) => {
  switch (command) {
    case 'manual':
      showManualDialog.value = true
      break
    case 'auto':
      showAutoDialog.value = true
      break
    case 'quick':
      handleQuickGenerate()
      break
  }
}

// 快速生成10题
const handleQuickGenerate = async () => {
  try {
    generating.value = true
    const response = await questionApi.generateQuickQuestions(10, userStore.userInfo?.id)
    
    if (response.code === 200) {
      ElMessage.success(`成功生成 ${response.data.length} 道题目`)
      loadQuestions()
    } else {
      ElMessage.error(response.message || '生成题目失败')
    }
  } catch (error) {
    ElMessage.error('快速生成题目失败: ' + error.message)
  } finally {
    generating.value = false
  }
}

// 自动生成题目
const handleGenerate = async () => {
  try {
    await generateFormRef.value.validate()
    generating.value = true

    const requestData = {
      ...generateForm,
      createdBy: userStore.userInfo?.id
    }

    const response = await questionApi.generateQuestions(requestData)
    
    if (response.code === 200) {
      ElMessage.success(`成功生成 ${response.data.length} 道题目`)
      showAutoDialog.value = false
      loadQuestions()
    } else {
      ElMessage.error(response.message || '生成题目失败')
    }
  } catch (error) {
    if (error.message) {
      ElMessage.error('生成题目失败: ' + error.message)
    }
  } finally {
    generating.value = false
  }
}

// 重置生成表单
const resetGenerateForm = () => {
  Object.assign(generateForm, {
    count: 10,
    types: ['AddAndSub', 'MulAndDiv', 'Mixed'],
    difficulties: ['easy', 'medium', 'hard'],
    numberRange: {
      addSubMin: 1,
      addSubMax: 100,
      multiplicationMin: 1,
      multiplicationMax: 12,
      divisionMin: 1,
      divisionMax: 12,
      mixedMin: 1,
      mixedMax: 100
    }
  })
  generateFormRef.value?.clearValidate()
}

// 重置筛选条件
const resetFilters = () => {
  filterType.value = ''
  filterDifficulty.value = ''
  loadQuestions()
}

// 加载题目列表
const loadQuestions = async () => {
  try {
    loading.value = true
    const params = {}
    if (filterType.value) params.type = filterType.value
    if (filterDifficulty.value) params.difficulty = filterDifficulty.value

    const response = await questionApi.getQuestionBank(params)
    // 按 id 升序排列
    questions.value = (response.data || []).sort((a, b) => a.id - b.id)

    // 只在有筛选条件时显示消息
    if (filterType.value || filterDifficulty.value) {
      ElMessage.success(`已筛选出 ${questions.value.length} 道题目`)
    }
  } catch (error) {
    ElMessage.error('加载题目失败: ' + error.message)
    questions.value = []
  } finally {
    loading.value = false
  }
}

// 编辑题目
const handleEdit = (row) => {
  Object.assign(formData, {
    id: row.id,
    content: row.content,
    type: row.type,
    difficulty: row.difficulty,
    answer: row.answer,
    createdBy: userStore.userInfo?.id
  })
  isEditing.value = true
  showManualDialog.value = true
}

// 提交表单（添加或编辑）
const handleSubmit = async () => {
  try {
    await questionFormRef.value.validate()
    submitting.value = true

    if (isEditing.value) {
      await questionApi.updateQuestion(formData.id, formData)
      ElMessage.success('题目修改成功')
    } else {
      await questionApi.addQuestion(formData)
      ElMessage.success('题目添加成功')
    }

    showManualDialog.value = false
    resetForm()
    loadQuestions()
  } catch (error) {
    if (error.message) {
      ElMessage.error(isEditing.value ? '修改题目失败: ' + error.message : '添加题目失败: ' + error.message)
    }
  } finally {
    submitting.value = false
  }
}

// 重置表单
const resetForm = () => {
  Object.assign(formData, {
    id: null,
    content: '',
    type: '',
    difficulty: '',
    answer: 0,
    createdBy: userStore.userInfo?.id
  })
  isEditing.value = false
  questionFormRef.value?.clearValidate()
}

// 删除题目
const handleDelete = async (questionId) => {
  try {
    const question = questions.value.find(q => q.id === questionId)
    if (!question) return

    await ElMessageBox.confirm('确定要删除这个题目吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await questionApi.deleteQuestion(questionId)
    ElMessage.success('题目删除成功')
    loadQuestions()
  } catch (error) {
    if (error.message && !error.message.includes('cancel')) {
      ElMessage.error('删除题目失败: ' + error.message)
    }
  }
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
    'AddAndSub': 'success',
    'MulAndDiv': 'primary',
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

onMounted(() => {
  loadQuestions()
})
</script>

<style scoped>
.question-management {
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
  margin-right: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* 筛选工具栏样式 */
.filter-card {
  border: 1px solid #ebeef5;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  border-radius: 4px;
}

.filter-card :deep(.el-card__body) {
  padding: 20px;
}

.filters-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.filters-left {
  flex: 1;
}

.filters-right {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: nowrap;
}

.filter-item {
  margin: 0 !important;
}

/* 确保选择器有合适的宽度 */
.filters-right :deep(.el-select) {
  width: 120px;
}

/* 统计卡片样式保持不变 */
.header-stats {
  font-size: 14px;
  color: #666;
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

/* 表单提示样式 */
.form-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}

/* 下拉菜单样式调整 */
:deep(.el-dropdown) {
  margin-right: 10px;
}
</style>