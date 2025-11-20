<template>
  <div class="question-management">
    <div class="toolbar">
      <h3>题目管理</h3>
    </div>

    <!-- 顶部工具栏 -->
    <el-card class="filter-card" style="margin-bottom: 20px;">
      <div class="filters-container">
        <div class="filters-left"></div>
        <div class="toolbar-actions">
          <el-dropdown @command="handleGenerateCommand">
            <el-button type="primary">
              <el-icon>
                <Plus />
              </el-icon>
              添加题目
              <el-icon class="el-icon--right">
                <arrow-down />
              </el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="manual">手动添加题目</el-dropdown-item>
                <el-dropdown-item command="auto">自动生成题目</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
        <div class="filters-right">
          <!-- 科目筛选 -->
          <el-select v-model="filterSubject" placeholder="科目筛选" clearable class="filter-item">
            <el-option label="全部科目" value=""></el-option>
            <el-option v-for="subject in subjectList" :key="subject" :label="subject" :value="subject" />
          </el-select>

          <el-select v-model="filterType" placeholder="题目类型" clearable class="filter-item">
            <el-option v-for="type in questionTypes" :key="type.id" :label="type.name" :value="type.id" />
          </el-select>

          <el-select v-model="filterDifficulty" placeholder="难度" clearable class="filter-item">
            <el-option v-for="difficulty in difficultyLevels" :key="difficulty.id" :label="difficulty.name"
              :value="difficulty.id" />
          </el-select>

          <el-button type="primary" @click="handleFilter" class="filter-item">
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
    <el-row :gutter="20" style="margin-top: 20px; margin-bottom: 20px;">
      <el-col :span="8">
        <el-card class="stats-card">
          <div class="stats-content">
            <div class="stats-icon" style="background-color: #ecf5ff;">
              <el-icon>
                <Collection />
              </el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number">{{ pagination.total }}</div>
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
              <div class="stats-number">{{ subjectCount }}</div>
              <div class="stats-label">科目数量</div>
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
            共 <el-tag type="primary">{{ pagination.total }}</el-tag> 道题目
            <span v-if="filteredQuestions.length !== allQuestions.length" class="filtered-count">
              (筛选出 {{ filteredQuestions.length }} 道)
            </span>
          </div>
        </div>
      </template>

      <el-table :data="currentPageQuestions" v-loading="loading" :default-sort="{ prop: 'id', order: 'ascending' }">
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="id" label="题目ID" width="80" align="center" sortable />
        <el-table-column prop="content" label="题目内容" min-width="200" />
        <el-table-column prop="subject" label="科目" width="120" sortable>
          <template #default="{ row }">
            <el-tag>{{ row.subject || '数学' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="knowledgePoint" label="知识点" width="150">
          <template #default="{ row }">
            {{ row.knowledgePoint || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.typeId)">
              {{ getTypeName(row.typeId) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="难度" width="100">
          <template #default="{ row }">
            <el-tag :type="getDifficultyTagType(row.difficultyId)">
              {{ getDifficultyName(row.difficultyId) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="答案" width="120">
          <template #default="{ row }">
            {{ getQuestionAnswer(row.answers) }}
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" sortable>
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
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

      <!-- 分页组件 -->
      <div class="pagination-container">
        <el-pagination v-model:current-page="pagination.currentPage" v-model:page-size="pagination.pageSize"
          :page-sizes="[20, 50, 100, 200]" :total="pagination.total" layout="sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange" @current-change="handleCurrentChange" />
      </div>
    </el-card>

    <!-- 手动添加/编辑题目对话框 -->
    <el-dialog v-model="showManualDialog" :title="dialogTitle" width="600px">
      <el-form :model="formData" :rules="questionRules" ref="questionFormRef" label-width="100px">
        <el-form-item label="题目内容" prop="content">
          <el-input v-model="formData.content" type="textarea" :rows="3" placeholder="请输入题目内容" />
        </el-form-item>

        <el-form-item label="科目" prop="subject">
          <el-select v-model="formData.subject" placeholder="请选择科目" style="width: 100%">
            <el-option v-for="subject in subjectList" :key="subject" :label="subject" :value="subject" />
            <el-option label="添加新科目" value="__new__">
              <span style="float: left">添加新科目</span>
              <span style="float: right; color: #8492a6; font-size: 13px">+</span>
            </el-option>
          </el-select>
          <el-input v-if="formData.subject === '__new__'" v-model="newSubject" placeholder="请输入新科目名称"
            style="margin-top: 8px" @blur="handleNewSubject" />
        </el-form-item>

        <el-form-item label="题目类型" prop="typeId">
          <el-select v-model="formData.typeId" placeholder="请选择类型" style="width: 100%">
            <el-option v-for="type in questionTypes" :key="type.id" :label="type.name" :value="type.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="难度" prop="difficultyId">
          <el-select v-model="formData.difficultyId" placeholder="请选择难度" style="width: 100%">
            <el-option v-for="difficulty in difficultyLevels" :key="difficulty.id" :label="difficulty.name"
              :value="difficulty.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="知识点" prop="knowledgePoint">
          <el-input v-model="formData.knowledgePoint" placeholder="请输入知识点，如：加法运算" />
        </el-form-item>

        <el-form-item label="答案" prop="answerContent">
          <el-input v-model="formData.answerContent" placeholder="请输入答案" />
          <div class="form-tip">对于数值答案直接输入数字，对于文本答案输入文本内容</div>
        </el-form-item>

        <el-form-item label="答案类型" prop="answerType">
          <el-select v-model="formData.answerType" placeholder="请选择答案类型" style="width: 100%">
            <el-option label="数值" value="number" />
            <el-option label="文本" value="text" />
            <el-option label="分数" value="fraction" />
            <el-option label="单选" value="single" />
            <el-option label="多选" value="multiple" />
          </el-select>
        </el-form-item>

        <el-form-item label="解析" prop="analysis">
          <el-input v-model="formData.analysis" type="textarea" :rows="3" placeholder="请输入题目解析" />
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
          <el-input-number v-model="generateForm.count" :min="1" :max="50" placeholder="请输入生成题目数量"
            style="width: 200px;" />
          <div class="form-tip">单次最多生成50道题目</div>
        </el-form-item>

        <el-form-item label="科目" prop="subject">
          <el-select v-model="generateForm.subject" placeholder="请选择科目" style="width: 100%">
            <el-option v-for="subject in subjectList" :key="subject" :label="subject" :value="subject" />
          </el-select>
        </el-form-item>

        <el-form-item label="题目类型" prop="typeId">
          <el-select v-model="generateForm.typeId" placeholder="请选择题目类型" style="width: 100%">
            <el-option v-for="type in questionTypes" :key="type.id" :label="type.name" :value="type.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="难度等级" prop="difficultyId">
          <el-select v-model="generateForm.difficultyId" placeholder="请选择难度" style="width: 100%">
            <el-option v-for="difficulty in difficultyLevels" :key="difficulty.id" :label="difficulty.name"
              :value="difficulty.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="知识点" prop="knowledgePoint">
          <el-input v-model="generateForm.knowledgePoint" placeholder="请输入知识点，如：四则运算" />
        </el-form-item>

        <el-collapse v-model="activeCollapse" style="margin: 20px 0;">
          <el-collapse-item title="高级设置（数字范围）" name="advanced">
            <el-form-item label="数字范围">
              <el-input-number v-model="generateForm.numberRange.min" :min="1" :max="generateForm.numberRange.max" />
              <span style="margin: 0 10px;">至</span>
              <el-input-number v-model="generateForm.numberRange.max" :min="generateForm.numberRange.min" :max="1000" />
            </el-form-item>

            <el-form-item label="运算类型">
              <el-checkbox-group v-model="generateForm.operations">
                <el-checkbox label="addition">加法</el-checkbox>
                <el-checkbox label="subtraction">减法</el-checkbox>
                <el-checkbox label="multiplication">乘法</el-checkbox>
                <el-checkbox label="division">除法</el-checkbox>
              </el-checkbox-group>
            </el-form-item>
          </el-collapse-item>
        </el-collapse>

        <el-form-item label="预览设置">
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="题目数量">{{ generateForm.count }}</el-descriptions-item>
            <el-descriptions-item label="科目">
              {{ generateForm.subject }}
            </el-descriptions-item>
            <el-descriptions-item label="题目类型">
              {{ getSelectedTypeText() }}
            </el-descriptions-item>
            <el-descriptions-item label="难度等级">
              {{ getSelectedDifficultyText() }}
            </el-descriptions-item>
            <el-descriptions-item label="数字范围">
              {{ generateForm.numberRange.min }} - {{ generateForm.numberRange.max }}
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
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh, Search, Collection, TrendCharts, DataAnalysis, ArrowDown } from '@element-plus/icons-vue'
import { questionApi } from '@/api/question'
import { useUserStore } from '@/stores/user'
import { getTypeTagType, getDifficultyTagType } from '@/utils/type'

const userStore = useUserStore()

const allQuestions = ref([]) // 存储所有题目
const filteredQuestions = ref([]) // 存储筛选后的题目
const loading = ref(false)
const showManualDialog = ref(false)
const showAutoDialog = ref(false)
const submitting = ref(false)
const generating = ref(false)
const isEditing = ref(false)
const filterType = ref('')
const filterDifficulty = ref('')
const filterSubject = ref('') // 科目筛选
const activeCollapse = ref([])
const questionTypes = ref([])
const difficultyLevels = ref([])
const newSubject = ref('') // 新科目输入

// 分页配置
const pagination = reactive({
  currentPage: 1,
  pageSize: 50,
  total: 0
})

const questionFormRef = ref()
const generateFormRef = ref()

// 手动添加表单数据
const formData = reactive({
  id: null,
  content: '',
  subject: '数学',
  typeId: null,
  difficultyId: null,
  knowledgePoint: '',
  analysis: '',
  answerContent: '',
  answerType: 'number',
  createdBy: userStore.userInfo?.id
})

// 自动生成表单数据
const generateForm = reactive({
  count: 10,
  typeId: null,
  difficultyId: null,
  subject: '数学',
  knowledgePoint: '四则运算',
  createdBy: userStore.userInfo?.id,
  numberRange: {
    min: 1,
    max: 100
  },
  operations: ['addition', 'subtraction']
})

// 计算属性
// 科目列表
const subjectList = computed(() => {
  const subjects = new Set(allQuestions.value.map(question => question.subject).filter(Boolean))
  return Array.from(subjects).sort()
})

// 当前页显示的题目
const currentPageQuestions = computed(() => {
  const start = (pagination.currentPage - 1) * pagination.pageSize
  const end = start + pagination.pageSize
  return filteredQuestions.value.slice(start, end)
})

// 科目数量统计
const subjectCount = computed(() => {
  return subjectList.value.length
})

// 计算对话框标题
const dialogTitle = computed(() => {
  return isEditing.value ? '编辑题目' : '添加题目'
})

// 计算统计信息
const typeCount = computed(() => {
  const types = new Set(allQuestions.value.map(question => question.typeId).filter(Boolean))
  return types.size
})

// 获取题目类型和难度等级
const loadQuestionTypesAndDifficulties = async () => {
  try {
    const [typesResponse, difficultiesResponse] = await Promise.all([
      questionApi.getQuestionTypes(),
      questionApi.getDifficultyLevels()
    ])

    questionTypes.value = typesResponse.data || []
    difficultyLevels.value = difficultiesResponse.data || []

    // 设置默认值
    if (questionTypes.value.length > 0 && !generateForm.typeId) {
      generateForm.typeId = questionTypes.value[0].id
      formData.typeId = questionTypes.value[0].id
    }
    if (difficultyLevels.value.length > 0 && !generateForm.difficultyId) {
      generateForm.difficultyId = difficultyLevels.value[0].id
      formData.difficultyId = difficultyLevels.value[0].id
    }
  } catch (error) {
    ElMessage.error('加载题目类型和难度失败: ' + error.message)
  }
}

// 根据类型ID获取类型名称
const getTypeName = (typeId) => {
  const type = questionTypes.value.find(t => t.id === typeId)
  return type ? type.name : '未知类型'
}

// 根据难度ID获取难度名称
const getDifficultyName = (difficultyId) => {
  const difficulty = difficultyLevels.value.find(d => d.id === difficultyId)
  return difficulty ? difficulty.name : '未知难度'
}

// 获取题目答案
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

// 获取选中的类型文本
const getSelectedTypeText = () => {
  const type = questionTypes.value.find(t => t.id === generateForm.typeId)
  return type ? type.name : '未选择'
}

// 获取选中的难度文本
const getSelectedDifficultyText = () => {
  const difficulty = difficultyLevels.value.find(d => d.id === generateForm.difficultyId)
  return difficulty ? difficulty.name : '未选择'
}

// 验证规则
const questionRules = {
  content: [{ required: true, message: '请输入题目内容', trigger: 'blur' }],
  subject: [{ required: true, message: '请输入科目', trigger: 'change' }],
  typeId: [{ required: true, message: '请选择题目类型', trigger: 'change' }],
  difficultyId: [{ required: true, message: '请选择难度', trigger: 'change' }],
  answerContent: [{ required: true, message: '请输入答案', trigger: 'blur' }],
  answerType: [{ required: true, message: '请选择答案类型', trigger: 'change' }]
}

const generateRules = {
  count: [
    { required: true, message: '请输入题目数量', trigger: 'blur' },
    { type: 'number', min: 1, max: 50, message: '题目数量范围为1-50', trigger: 'blur' }
  ],
  typeId: [
    { required: true, message: '请选择题目类型', trigger: 'change' }
  ],
  difficultyId: [
    { required: true, message: '请选择难度等级', trigger: 'change' }
  ],
  subject: [
    { required: true, message: '请输入科目', trigger: 'change' }
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
  }
}

// 自动生成题目
const handleGenerate = async () => {
  try {
    await generateFormRef.value.validate()
    generating.value = true

    // 构建生成请求数据
    const requestData = {
      count: generateForm.count,
      typeId: generateForm.typeId,
      difficultyId: generateForm.difficultyId,
      subject: generateForm.subject,
      knowledgePoint: generateForm.knowledgePoint,
      numberRange: generateForm.numberRange,
      operations: generateForm.operations,
      createdBy: userStore.userInfo?.id
    }

    // 调用生成接口 - 这里需要根据实际后端接口调整
    // 暂时模拟生成过程
    await new Promise(resolve => setTimeout(resolve, 2000))

    ElMessage.success(`成功生成 ${generateForm.count} 道题目`)
    showAutoDialog.value = false
    loadQuestions()

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
    typeId: questionTypes.value[0]?.id || null,
    difficultyId: difficultyLevels.value[0]?.id || null,
    subject: '数学',
    knowledgePoint: '四则运算',
    numberRange: {
      min: 1,
      max: 100
    },
    operations: ['addition', 'subtraction']
  })
  generateFormRef.value?.clearValidate()
}

// 处理筛选
const handleFilter = () => {
  applyFilters()
}

// 应用筛选条件
const applyFilters = () => {
  let filtered = [...allQuestions.value]

  // 科目筛选
  if (filterSubject.value) {
    filtered = filtered.filter(question => question.subject === filterSubject.value)
  }

  // 类型筛选
  if (filterType.value) {
    filtered = filtered.filter(question => question.typeId == filterType.value)
  }

  // 难度筛选
  if (filterDifficulty.value) {
    filtered = filtered.filter(question => question.difficultyId == filterDifficulty.value)
  }

  filteredQuestions.value = filtered
  pagination.total = filteredQuestions.value.length
  pagination.currentPage = 1 // 重置到第一页
}

// 重置筛选条件
const resetFilters = () => {
  filterSubject.value = ''
  filterType.value = ''
  filterDifficulty.value = ''
  applyFilters()
}

// 加载题目列表
const loadQuestions = async () => {
  try {
    loading.value = true

    // 使用能获取答案的API，或者修改现有API
    const response = await questionApi.getAllQuestions()

    // 按ID排序
    allQuestions.value = (response.data || []).sort((a, b) => a.id - b.id)

    console.log('题目数据:', allQuestions.value)

    // 如果还是没有答案，尝试使用试卷详情的查询方式
    if (allQuestions.value.length > 0 && !allQuestions.value[0].answers) {
      await loadQuestionsWithAnswers()
    }

    // 初始化筛选后的数据
    applyFilters()

  } catch (error) {
    ElMessage.error('加载题目失败: ' + error.message)
    allQuestions.value = []
    filteredQuestions.value = []
  } finally {
    loading.value = false
  }
}

// 使用能获取答案的方式加载题目
const loadQuestionsWithAnswers = async () => {
  try {
    // 方法1: 通过试卷详情API的模式获取
    const detailedQuestions = []
    for (const question of allQuestions.value) {
      try {
        // 假设有获取单个题目详情的API
        const detailResponse = await questionApi.getQuestionById(question.id)
        if (detailResponse.data && detailResponse.data.answers) {
          detailedQuestions.push(detailResponse.data)
        } else {
          detailedQuestions.push(question)
        }
      } catch (error) {
        detailedQuestions.push(question)
      }
    }
    allQuestions.value = detailedQuestions
  } catch (error) {
    console.warn('获取题目详情失败:', error)
  }
}

// 编辑题目
const handleEdit = (row) => {
  Object.assign(formData, {
    id: row.id,
    content: row.content,
    subject: row.subject,
    typeId: row.typeId,
    difficultyId: row.difficultyId,
    knowledgePoint: row.knowledgePoint || '',
    analysis: row.analysis || '',
    answerContent: getQuestionAnswer(row.answers),
    answerType: row.answers?.[0]?.answerType || 'number',
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

    // 处理新科目
    let subject = formData.subject
    if (formData.subject === '__new__' && newSubject.value) {
      subject = newSubject.value
    }

    // 构建符合后端要求的题目数据
    const questionData = {
      content: formData.content,
      subject: subject,
      typeId: formData.typeId,
      difficultyId: formData.difficultyId,
      knowledgePoint: formData.knowledgePoint,
      analysis: formData.analysis,
      answers: [
        {
          content: formData.answerContent,
          answerType: formData.answerType,
          isCorrect: true,
          sortOrder: 1
        }
      ],
      createdBy: userStore.userInfo?.id
    }

    if (isEditing.value) {
      await questionApi.updateQuestion(formData.id, questionData)
      ElMessage.success('题目修改成功')
    } else {
      await questionApi.addQuestion(questionData)
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

// 处理新科目输入
const handleNewSubject = () => {
  if (newSubject.value && !subjectList.value.includes(newSubject.value)) {
    // 可以在这里添加新科目到科目列表的逻辑
    ElMessage.success(`已添加新科目: ${newSubject.value}`)
  }
}

// 重置表单
const resetForm = () => {
  Object.assign(formData, {
    id: null,
    content: '',
    subject: '数学',
    typeId: questionTypes.value[0]?.id || null,
    difficultyId: difficultyLevels.value[0]?.id || null,
    knowledgePoint: '',
    analysis: '',
    answerContent: '',
    answerType: 'number',
    createdBy: userStore.userInfo?.id
  })
  newSubject.value = ''
  isEditing.value = false
  questionFormRef.value?.clearValidate()
}

// 删除题目
const handleDelete = async (questionId) => {
  try {
    const question = allQuestions.value.find(q => q.id === questionId)
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
  loadQuestions()
  loadQuestionTypesAndDifficulties()
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

/* 统计卡片样式 */
.header-stats {
  font-size: 14px;
  color: #666;
}

.filtered-count {
  color: #409eff;
  font-weight: 500;
  margin-left: 8px;
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

/* 复选框组样式 */
:deep(.el-checkbox-group) {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

/* 分页样式 */
.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
  padding: 20px 0;
}

/* 表格样式优化 */
:deep(.el-table) {
  margin-top: 10px;
}

:deep(.el-table .cell) {
  word-break: break-word;
}
</style>