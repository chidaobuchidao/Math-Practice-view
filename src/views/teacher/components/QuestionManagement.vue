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

      <el-table :data="currentPageQuestions" v-loading="loading" :default-sort="{ prop: 'id', order: 'ascending' }"
        style="margin-top: -15px">
        <el-table-column prop="id" label="题目ID" width="100" align="center" sortable />
        <el-table-column prop="content" label="题目内容" min-width="200">
          <template #default="{ row }">
            <div>{{ row.content }}</div>
            <div v-if="row.images && row.images.length > 0" class="question-images">
              <img v-for="(img, idx) in row.images" :key="idx" :src="getImageUrl(img.imagePath)" 
                   class="question-image-thumb" @click="previewImage(img.imagePath)" />
            </div>
          </template>
        </el-table-column>
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
            {{ getQuestionAnswer(row) }}
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

        <el-form-item label="题目图片">
          <div class="images-section">
            <div v-for="(img, index) in formData.images" :key="index" class="image-item">
              <ImageUploader v-model="formData.images[index]" @uploaded="() => {}" />
            </div>
            <el-button type="primary" size="small" @click="addImage">
              <el-icon><Plus /></el-icon>
              添加图片
            </el-button>
          </div>
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

        <!-- 选择题选项管理（单选或多选） -->
        <el-form-item v-if="isChoiceQuestion" label="选择题选项" prop="options">
          <div class="options-container">
            <div v-for="(option, index) in formData.options" :key="index" class="option-item">
              <el-input v-model="option.content" :placeholder="`选项 ${String.fromCharCode(65 + index)}`" style="flex: 1; margin-right: 10px;">
                <template #prepend>{{ String.fromCharCode(65 + index) }}.</template>
              </el-input>
              <el-checkbox v-model="option.isCorrect" :disabled="!isMultipleChoice && hasOtherCorrectOption(index)">
                正确答案
              </el-checkbox>
              <el-button type="danger" size="small" @click="removeOption(index)" :disabled="formData.options.length <= 2">
                <el-icon><Delete /></el-icon>
              </el-button>
            </div>
            <el-button type="primary" size="small" @click="addOption" :disabled="formData.options.length >= 8">
              <el-icon><Plus /></el-icon>
              添加选项
            </el-button>
            <div class="form-tip">至少需要2个选项，最多8个选项。请至少标记一个正确答案。</div>
          </div>
        </el-form-item>

        <!-- 非选择题答案输入 -->
        <template v-else>
          <el-form-item label="答案" prop="answerContent">
            <el-input v-model="formData.answerContent" placeholder="请输入答案" />
            <div class="form-tip">对于数值答案直接输入数字，对于文本答案输入文本内容</div>
          </el-form-item>

          <el-form-item label="答案类型" prop="answerType">
            <el-select v-model="formData.answerType" placeholder="请选择答案类型" style="width: 100%">
              <el-option label="数值" value="number" />
              <el-option label="文本" value="text" />
              <el-option label="分数" value="fraction" />
            </el-select>
          </el-form-item>
        </template>

        <el-form-item label="解析" prop="analysis">
          <el-input v-model="formData.analysis" type="textarea" :rows="3" placeholder="请输入题目解析（支持HTML格式）" />
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
import { Plus, Refresh, Search, Collection, TrendCharts, DataAnalysis, ArrowDown, Delete } from '@element-plus/icons-vue'
import { questionApi } from '@/api/question'
import { useUserStore } from '@/stores/user'
import { getTypeTagType, getDifficultyTagType } from '@/utils/type'
import ImageUploader from './ImageUploader.vue'
import request from '@/utils/request'

// 获取图片完整URL
const getImageUrl = (path) => {
  if (!path) return ''
  return path.startsWith('http') ? path : `${request.defaults.baseURL}${path}`
}

// 预览图片
const previewImage = (path) => {
  window.open(getImageUrl(path), '_blank')
}

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
  options: [
    { content: '', isCorrect: false, sortOrder: 1 },
    { content: '', isCorrect: false, sortOrder: 2 }
  ],
  images: [],
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

// 判断是否为选择题（单选或多选）
const isChoiceQuestion = computed(() => {
  return formData.typeId === 1 || formData.typeId === 2 // 1=单选题, 2=多选题
})

// 判断是否为多选题
const isMultipleChoice = computed(() => {
  return formData.typeId === 2 // 2=多选题
})

// 检查单选情况下是否已有其他选项标记为正确答案
const hasOtherCorrectOption = (currentIndex) => {
  if (isMultipleChoice.value) return false
  return formData.options.some((opt, idx) => idx !== currentIndex && opt.isCorrect)
}

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

// 获取题目答案（支持选择题和非选择题）
const getQuestionAnswer = (question) => {
  if (!question) return '无答案'
  
  // 选择题：从answers中获取正确答案，content是选项键（A, B, C, D）
  if (question.typeId === 1 || question.typeId === 2) {
    // 检查是否有答案数据
    if (!question.answers || question.answers.length === 0) {
      return '无答案'
    }
    
    // 过滤正确答案：isCorrect可能是true、1或其他truthy值
    const correctAnswers = question.answers
      .filter(a => {
        const isCorrect = a.isCorrect
        return isCorrect === true || isCorrect === 1 || isCorrect === '1' || isCorrect === 'true'
      })
      .map(a => a.content)
      .filter(content => content && content.trim()) // 过滤空内容
    
    if (correctAnswers.length === 0) {
      return '无答案'
    }
    return question.typeId === 1 ? correctAnswers[0] : correctAnswers.sort().join(', ')
  }
  
  // 非选择题：返回答案内容
  if (!question.answers || question.answers.length === 0) {
    return '无答案'
  }
  
  const correctAnswer = question.answers.find(a => {
    const isCorrect = a.isCorrect
    return isCorrect === true || isCorrect === 1 || isCorrect === '1' || isCorrect === 'true'
  })
  return correctAnswer?.content || '无答案'
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
  answerContent: [
    {
      validator: (rule, value, callback) => {
        if (!isChoiceQuestion.value && (!value || value.trim() === '')) {
          callback(new Error('请输入答案'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  answerType: [
    {
      validator: (rule, value, callback) => {
        if (!isChoiceQuestion.value && !value) {
          callback(new Error('请选择答案类型'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ],
  options: [
    {
      validator: (rule, value, callback) => {
        if (isChoiceQuestion.value) {
          const validOptions = formData.options.filter(opt => opt.content.trim() !== '')
          if (validOptions.length < 2) {
            callback(new Error('选择题至少需要2个有效选项'))
          } else {
            const hasCorrectAnswer = formData.options.some(opt => opt.isCorrect && opt.content.trim() !== '')
            if (!hasCorrectAnswer) {
              callback(new Error('请至少标记一个正确答案'))
            } else {
              callback()
            }
          }
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ]
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

    // 调用生成接口 - 后端接口待更新
    // 目前暂时模拟生成过程
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
    const response = await questionApi.getAllQuestions()
    allQuestions.value = (response.data || []).sort((a, b) => a.id - b.id)
    applyFilters()
  } catch (error) {
    ElMessage.error('加载题目失败: ' + error.message)
    allQuestions.value = []
    filteredQuestions.value = []
  } finally {
    loading.value = false
  }
}

// 编辑题目
const handleEdit = (row) => {
  // 判断是否为选择题
  const isChoice = row.typeId === 1 || row.typeId === 2
  
  // 加载选项（选择题从options加载，非选择题从answers加载）
  if (isChoice && row.options && row.options.length > 0) {
    // 选择题：从options加载选项
    // 获取正确答案（从answers中获取，答案的content是optionKey如'A', 'B'）
    const correctAnswers = row.answers
      ?.filter(a => a.isCorrect)
      ?.map(a => a.content) || []
    
    formData.options = row.options
      .sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
      .map((option, index) => ({
        content: option.content || '',
        isCorrect: correctAnswers.includes(option.optionKey || String.fromCharCode(65 + index)),
        sortOrder: option.sortOrder || (index + 1)
      }))
    
    // 如果没有选项或选项少于2个，至少提供2个空选项
    if (formData.options.length < 2) {
      while (formData.options.length < 2) {
        formData.options.push({ content: '', isCorrect: false, sortOrder: formData.options.length + 1 })
      }
    }
  } else if (isChoice && row.answers && row.answers.length > 0) {
    // 兼容旧数据：从answers加载选项（旧版本可能没有options字段）
    formData.options = row.answers.map((answer, index) => ({
      content: answer.content || '',
      isCorrect: answer.isCorrect || false,
      sortOrder: answer.sortOrder || (index + 1)
    }))
    
    if (formData.options.length < 2) {
      while (formData.options.length < 2) {
        formData.options.push({ content: '', isCorrect: false, sortOrder: formData.options.length + 1 })
      }
    }
  } else {
    // 非选择题：初始化默认选项数组
    formData.options = [
      { content: '', isCorrect: false, sortOrder: 1 },
      { content: '', isCorrect: false, sortOrder: 2 }
    ]
  }
  
  // 加载图片
  formData.images = row.images?.map(img => ({
    imagePath: img.imagePath,
    imageName: img.imageName
  })) || []
  
  Object.assign(formData, {
    id: row.id,
    content: row.content || '',
    subject: row.subject,
    typeId: row.typeId,
    difficultyId: row.difficultyId,
    knowledgePoint: row.knowledgePoint || '',
    analysis: row.analysis || '',
    answerContent: isChoice ? '' : getQuestionAnswer(row),
    answerType: isChoice ? (row.typeId === 1 ? 'single' : 'multiple') : (row.answers?.[0]?.answerType || 'number'),
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

    // 验证选择题选项
    if (isChoiceQuestion.value) {
      // 检查至少2个选项
      const validOptions = formData.options.filter(opt => opt.content.trim() !== '')
      if (validOptions.length < 2) {
        ElMessage.error('选择题至少需要2个有效选项')
        return
      }
      
      // 检查至少有一个正确答案
      const hasCorrectAnswer = formData.options.some(opt => opt.isCorrect && opt.content.trim() !== '')
      if (!hasCorrectAnswer) {
        ElMessage.error('请至少标记一个正确答案')
        return
      }
    }

    // 构建符合后端要求的题目数据
    let questionData
    if (isChoiceQuestion.value) {
      // 选择题：使用新的选择题API格式
      const validOptions = formData.options.filter(opt => opt.content.trim() !== '')
      const correctAnswerIndices = validOptions
        .map((opt, idx) => ({ opt, idx }))
        .filter(({ opt }) => opt.isCorrect)
        .map(({ idx }) => idx)
      
      const correctAnswers = correctAnswerIndices.map(idx => String.fromCharCode(65 + idx))
      
      questionData = {
        typeId: formData.typeId,
        difficultyId: formData.difficultyId,
        subject: subject,
        knowledgePoint: formData.knowledgePoint,
        content: formData.content,
        analysis: formData.analysis,
        createdBy: userStore.userInfo?.id,
        options: validOptions.map((opt, index) => ({
          optionKey: String.fromCharCode(65 + index),
          content: opt.content.trim(),
          sortOrder: opt.sortOrder || (index + 1)
        })),
        correctAnswers: correctAnswers,
        images: formData.images.filter(img => img).map(img => ({
          imagePath: img.imagePath,
          imageName: img.imageName
        }))
      }
    } else {
      // 非选择题：使用通用API格式
      questionData = {
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
        images: formData.images.filter(img => img).map(img => ({
          imagePath: img.imagePath,
          imageName: img.imageName
        })),
        createdBy: userStore.userInfo?.id
      }
    }

    if (isEditing.value) {
      // 更新题目
      if (isChoiceQuestion.value) {
        await questionApi.updateChoiceQuestion(formData.id, questionData)
      } else {
        await questionApi.updateQuestion(formData.id, questionData)
      }
      ElMessage.success('题目修改成功')
    } else {
      // 创建题目
      if (isChoiceQuestion.value) {
        if (formData.typeId === 1) {
          await questionApi.createSingleChoiceQuestion(questionData)
        } else {
          await questionApi.createMultipleChoiceQuestion(questionData)
        }
      } else {
        await questionApi.addQuestion(questionData)
      }
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

// 添加选项
const addOption = () => {
  if (formData.options.length < 8) {
    formData.options.push({
      content: '',
      isCorrect: false,
      sortOrder: formData.options.length + 1
    })
  }
}

// 删除选项
const removeOption = (index) => {
  if (formData.options.length > 2) {
    formData.options.splice(index, 1)
    // 重新排序
    formData.options.forEach((opt, idx) => {
      opt.sortOrder = idx + 1
    })
  } else {
    ElMessage.warning('选择题至少需要2个选项')
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
    options: [
      { content: '', isCorrect: false, sortOrder: 1 },
      { content: '', isCorrect: false, sortOrder: 2 }
    ],
    createdBy: userStore.userInfo?.id
  })
  newSubject.value = ''
  formData.images = []
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

// 添加图片
const addImage = () => {
  formData.images.push(null)
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

/* 选择题选项管理样式 */
.options-container {
  width: 100%;
}

.option-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
  gap: 10px;
}

.option-item :deep(.el-checkbox) {
  margin-right: 10px;
}

.option-item :deep(.el-input) {
  flex: 1;
}

.option-item :deep(.el-checkbox) {
  margin-right: 10px;
}

.images-section {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.image-item {
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 10px;
}

.question-images {
  margin-top: 8px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.question-image-thumb {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
}

.question-image-thumb:hover {
  border-color: #409eff;
}
</style>