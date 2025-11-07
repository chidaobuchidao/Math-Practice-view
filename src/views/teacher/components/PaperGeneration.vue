<template>
  <div class="paper-generation">
    <el-card>
      <h3>试卷生成（占位）</h3>
      <p>这里是试卷生成的功能占位组件，后续实现试题选择、难度与导出功能。</p>
      <el-button type="primary" @click="generate">生成示例试卷</el-button>
    </el-card>
  </div>
</template>

<script setup>
import { ElMessage } from 'element-plus'

const generate = () => {
  ElMessage.success('已生成示例试卷（占位）')
}
</script>

<style scoped>
.paper-generation {
  padding: 16px;
}
</style>
