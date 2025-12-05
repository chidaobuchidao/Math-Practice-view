# 刷题系统 - 前端

## 项目简介

刷题系统前端是一个基于现代 Web 技术栈构建的单页面应用，为教师和学生提供直观、高效的在线练习平台。系统支持题目管理、智能组卷、在线答题、错题分析等功能，为教育场景提供完整的数字化解决方案。

**后端项目**: [Math-Practice-system](https://github.com/chidaobuchidao/Math-Practice)

## 🛠 技术栈

| 类别 | 技术选型 |
|------|----------|
| **核心框架** | Vue 3.5.22 + Composition API |
| **开发语言** | TypeScript 5.9.0 |
| **构建工具** | Vite 7.1.11 |
| **UI 组件** | Element Plus 2.11.7 |
| **状态管理** | Pinia 3.0.4 |
| **路由管理** | Vue Router 4.6.3 |
| **HTTP 客户端** | Axios 1.13.2 |
| **数据可视化** | ECharts 6.0.0 |
| **图标库** | Element Plus Icons 2.3.2 |

## 📋 环境要求

- **Node.js**: ^20.19.0 或 >=22.12.0
- **包管理器**: npm 或 yarn
- **浏览器**: Chrome 90+ (推荐), Firefox 88+, Safari 14+, Edge 90+

## 🗂 项目结构

```
Math-Practice-view/
├── public/                 # 静态资源
├── src/
│   ├── api/               # API 接口层
│   │   ├── paper.js       # 试卷接口
│   │   ├── question.js    # 题目接口
│   │   ├── upload.js      # 上传接口
│   │   ├── user.js        # 用户接口
│   │   └── wrongQuestion.js # 错题接口
│   ├── router/            # 路由配置
│   │   └── index.js       # 路由定义和守卫
│   ├── stores/            # 状态管理
│   │   └── user.js        # 用户状态
│   ├── utils/             # 工具函数
│   │   ├── activityLogger.js # 活动日志
│   │   ├── debug.js       # 调试工具
│   │   ├── icons.js       # 图标管理
│   │   ├── request.js     # HTTP 请求封装
│   │   └── type.js        # 类型定义
│   ├── views/             # 页面组件
│   │   ├── Login.vue      # 登录页面
│   │   ├── Register.vue   # 注册页面
│   │   ├── student/       # 学生模块
│   │   │   ├── StudentDashboard.vue  # 学生仪表板
│   │   │   └── components/
│   │   │       └── WrongQuestions.vue # 错题组件
│   │   └── teacher/       # 教师模块
│   │       ├── TeacherDashboard.vue  # 教师仪表板
│   │       └── components/
│   │           ├── ImageUploader.vue    # 图片上传
│   │           ├── PaperGeneration.vue  # 试卷生成
│   │           ├── QuestionManagement.vue # 题目管理
│   │           ├── StudentManagement.vue # 学生管理
│   │           └── TeacherInfo.vue      # 教师信息
│   ├── App.vue            # 根组件
│   └── main.js            # 应用入口
├── index.html             # HTML 模板
├── package.json           # 项目依赖和脚本
├── vite.config.ts         # 构建配置
└── tsconfig.json          # TypeScript 配置
```

## 🚀 快速开始

### 1. 获取代码

```bash
git clone <repository-url>
cd Math-Practice-view
```

### 2. 安装依赖

```bash
npm install
# 或使用 yarn
yarn install
```

### 3. 开发环境运行

```bash
npm run dev
```

启动成功后访问：`http://localhost:5173`

### 4. 项目构建

```bash
# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

### 5. 开发工具

```bash
# TypeScript 类型检查
npm run type-check

# 代码格式化
npm run format
```

## ⚙️ 配置说明

### API 地址配置

在 `src/utils/request.js` 中配置后端服务地址：

```javascript
const request = axios.create({
  baseURL: 'http://localhost:8080',  // 根据实际环境修改
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})
```

### 开发环境代理

如需配置开发环境代理，在 `vite.config.ts` 中设置：

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
```

### 环境变量

创建 `.env` 文件配置环境变量：

```env
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_TITLE=刷题系统
```

## 💡 功能模块

### 👨‍🏫 教师功能
| 功能模块 | 描述 |
|----------|------|
| **题目管理** | 创建、编辑、删除单选题、多选题 |
| **智能组卷** | 从题库按条件筛选题目生成试卷 |
| **题目生成** | 自动生成数学计算题（加减乘除、混合运算） |
| **学生管理** | 查看学生列表、学习进度和成绩统计 |
| **资源管理** | 题目图片上传和管理 |
| **个人中心** | 个人信息查看和编辑 |

### 👨‍🎓 学生功能
| 功能模块 | 描述 |
|----------|------|
| **试卷练习** | 在线答题、自动计时、实时保存 |
| **错题管理** | 错题查看、分类整理、重点练习 |
| **学习统计** | 成绩趋势、知识点掌握度分析 |
| **进度跟踪** | 学习进度可视化展示 |

## 📱 页面路由

### 公开路由
- `/login` - 用户登录
- `/register` - 用户注册

### 受保护路由
#### 教师路由
- `/teacher/dashboard` - 教师仪表板
- `/teacher/questions` - 题目管理
- `/teacher/paper-generation` - 试卷生成
- `/teacher/students` - 学生管理
- `/teacher/profile` - 个人信息

#### 学生路由
- `/student/dashboard` - 学生仪表板
- `/student/wrong-questions` - 错题本

## 🎯 开发指南

### 代码规范

#### 组件开发
```vue
<template>
  <!-- 使用 PascalCase 组件名 -->
  <QuestionManagement />
</template>

<script setup>
// 使用 Composition API
import { ref, computed } from 'vue'

// 类型定义
interface Question {
  id: number
  title: string
  type: string
}

// 响应式数据
const questions = ref<Question[]>([])
</script>
```

#### API 调用规范
```typescript
// 统一使用 api 目录下的封装
import { getQuestions, createQuestion } from '@/api/question'

// 异步处理使用 async/await
const loadQuestions = async () => {
  try {
    const response = await getQuestions()
    questions.value = response.data
  } catch (error) {
    console.error('加载题目失败:', error)
  }
}
```

### 状态管理

使用 Pinia 进行状态管理：

```typescript
// stores/user.js
export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: null,
    token: ''
  }),
  
  actions: {
    async login(credentials) {
      const response = await userApi.login(credentials)
      this.userInfo = response.data.user
      this.token = response.data.token
    }
  },
  
  getters: {
    isTeacher: (state) => state.userInfo?.role === 'teacher'
  }
})
```

## 🐛 常见问题

### 1. 端口冲突

如果默认端口 5173 被占用，Vite 会自动选择其他端口，或手动指定：

```bash
npm run dev -- --port 3000
```

### 2. 跨域问题

**解决方案**：
- 后端配置 CORS
- 使用 Vite 代理（开发环境）
- 配置 Nginx 反向代理（生产环境）

### 3. 依赖安装失败

```bash
# 清除缓存重新安装
npm cache clean --force
rm -rf node_modules
npm install
```

### 4. 类型检查错误

```bash
# 查看详细类型错误
npm run type-check

# 或使用 Vue TS 插件获得更好的开发体验
```

## 🌐 浏览器兼容性

| 浏览器 | 最低版本 | 状态 |
|--------|----------|------|
| Chrome | 90 | ✅ 完全支持 |
| Firefox | 88 | ✅ 完全支持 |
| Safari | 14 | ✅ 完全支持 |
| Edge | 90 | ✅ 完全支持 |

## 📦 部署指南

### 构建生产版本

```bash
npm run build
```

构建产物位于 `dist/` 目录，包含：
- 静态资源（HTML, CSS, JS）
- 压缩和优化的代码
- Source Map 文件

### 服务器配置

#### Nginx 配置示例
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    root /path/to/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API 代理
    location /api/ {
        proxy_pass http://backend-server:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 环境变量配置

生产环境通过环境变量配置：

```env
VITE_API_BASE_URL=https://api.your-domain.com
VITE_APP_TITLE=刷题系统 - 生产环境
```

## 📄 许可证

本项目为开源项目，禁止商用。

## 📞 技术支持

如有技术问题或功能建议，请联系作者。

---

**欢迎贡献代码，共同完善项目喵~** 🎉
