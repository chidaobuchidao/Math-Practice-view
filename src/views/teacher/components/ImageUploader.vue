<template>
  <div class="image-uploader">
    <el-upload :action="uploadUrl" :show-file-list="false" :before-upload="beforeUpload" :http-request="customUpload"
      accept="image/*">
      <el-button type="primary" :loading="uploading" size="small">
        <el-icon v-if="!uploading">
          <Upload />
        </el-icon>
        {{ uploading ? '上传中...' : '上传图片' }}
      </el-button>
    </el-upload>

    <div v-if="imageInfo" class="image-preview">
      <img :src="fullImageUrl" alt="预览" />
      <el-button type="danger" size="small" @click="handleRemove">删除</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Upload } from '@element-plus/icons-vue'
import { uploadApi } from '@/api/upload'
import request from '@/utils/request'

const props = defineProps({
  modelValue: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'uploaded'])

const uploading = ref(false)
const imageInfo = ref(props.modelValue)

const uploadUrl = computed(() => `${request.defaults.baseURL}/api/upload/image`)
const fullImageUrl = computed(() => {
  if (!imageInfo.value?.imagePath) return ''
  return imageInfo.value.imagePath.startsWith('http')
    ? imageInfo.value.imagePath
    : `${request.defaults.baseURL}${imageInfo.value.imagePath}`
})

const customUpload = async (options) => {
  uploading.value = true
  try {
    const response = await uploadApi.uploadImage(options.file)
    if (response?.code === 200) {
      const path = response.data
      const name = options.file.name
      imageInfo.value = { imagePath: path, imageName: name }
      emit('update:modelValue', imageInfo.value)
      emit('uploaded', imageInfo.value)
      ElMessage.success('图片上传成功')
    } else {
      ElMessage.error(response?.message || '上传失败')
      options.onError(new Error(response?.message))
    }
  } catch (error) {
    ElMessage.error('上传失败: ' + error.message)
    options.onError(error)
  } finally {
    uploading.value = false
  }
}

const beforeUpload = (file) => {
  if (!file.type.startsWith('image/')) {
    ElMessage.error('只能上传图片文件')
    return false
  }
  if (file.size / 1024 / 1024 >= 5) {
    ElMessage.error('图片大小不能超过5MB')
    return false
  }
  return true
}

const handleRemove = () => {
  imageInfo.value = null
  emit('update:modelValue', null)
}
</script>

<style scoped>
.image-uploader {
  width: 100%;
}

.image-preview {
  margin-top: 10px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.image-preview img {
  max-width: 150px;
  max-height: 150px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}
</style>
