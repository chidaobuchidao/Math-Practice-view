<template>
  <div class="question-management">
    <div class="toolbar">
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon>
          <Plus />
        </el-icon>
        添加题目
      </el-button>

      <div class="filters">
        <el-select v-model="filterType" placeholder="题目类型" clearable>
          <el-option label="加减运算" value="AddAndSub" />
          <el-option label="乘除运算" value="MulAndDiv" />
          <el-option label="混合运算" value="Mixed" />
        </el-select>

        <el-select v-model="filterDifficulty" placeholder="难度" clearable>
          <el-option label="简单" value="easy" />
          <el-option label="中等" value="medium" />
          <el-option label="困难" value="hard" />
        </el-select>

        <el-button type="primary" @click="loadQuestions">筛选</el-button>
      </div>
    </div>

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

    <!-- 添加/编辑题目对话框 -->
    <el-dialog v-model="showAddDialog" :title="dialogTitle" width="500px">
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
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          {{ isEditing ? '保存修改' : '确认添加' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { questionApi } from '@/api/question'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const questions = ref([])
const loading = ref(false)
const showAddDialog = ref(false)
const submitting = ref(false)
const isEditing = ref(false)
const filterType = ref('')
const filterDifficulty = ref('')

const questionFormRef = ref()

// 表单数据
const formData = reactive({
  id: null,
  content: '',
  type: '',
  difficulty: '',
  answer: 0,
  createdBy: userStore.userInfo?.id
})

// 计算对话框标题
const dialogTitle = computed(() => {
  return isEditing.value ? '编辑题目' : '添加题目'
})

const questionRules = {
  content: [{ required: true, message: '请输入题目内容', trigger: 'blur' }],
  type: [{ required: true, message: '请选择题目类型', trigger: 'change' }],
  difficulty: [{ required: true, message: '请选择难度', trigger: 'change' }],
  answer: [{ required: true, message: '请输入答案', trigger: 'blur' }]
}

// 加载题目列表
const loadQuestions = async () => {
  try {
    loading.value = true
    const params = {}
    if (filterType.value) params.type = filterType.value
    if (filterDifficulty.value) params.difficulty = filterDifficulty.value

    const response = await questionApi.getQuestionBank(params)
    questions.value = response.data
  } catch (error) {
    ElMessage.error('加载题目失败: ' + error.message)
  } finally {
    loading.value = false
  }
}

// 编辑题目
const handleEdit = (row) => {
  // 填充表单数据
  Object.assign(formData, {
    id: row.id,
    content: row.content,
    type: row.type,
    difficulty: row.difficulty,
    answer: row.answer,
    createdBy: userStore.userInfo?.id
  })
  isEditing.value = true
  showAddDialog.value = true
}

// 提交表单（添加或编辑）
const handleSubmit = async () => {
  try {
    await questionFormRef.value.validate()
    submitting.value = true

    if (isEditing.value) {
      // 编辑模式
      await questionApi.updateQuestion(formData.id, formData)
      ElMessage.success('题目修改成功')
    } else {
      // 添加模式
      await questionApi.addQuestion(formData)
      ElMessage.success('题目添加成功')
    }

    // 关闭对话框并重置
    showAddDialog.value = false
    resetForm()
    loadQuestions() // 重新加载列表
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
    await ElMessageBox.confirm('确定要删除这个题目吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    await questionApi.deleteQuestion(questionId)
    ElMessage.success('题目删除成功')
    loadQuestions() // 重新加载列表
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
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.filters {
  display: flex;
  gap: 10px;
}
</style>