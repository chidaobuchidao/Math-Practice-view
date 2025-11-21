# 刷题系统 - 前端

## 项目简介

刷题系统前端是一个基于 Vue 3 + TypeScript + Element Plus 构建的单页面应用（SPA），为管理员和用户提供数学题目管理、试卷生成、在线练习等功能，提供可视化的交互界面，管理员可以通过界面更新题库、指定或批量发布试题、管理用户。

## 技术栈

- **框架**: Vue 3.5.22
- **语言**: TypeScript 5.9.0
- **构建工具**: Vite 7.1.11
- **UI 组件库**: Element Plus 2.11.7
- **状态管理**: Pinia 3.0.4
- **路由**: Vue Router 4.6.3
- **HTTP 客户端**: Axios 1.13.2
- **图表库**: ECharts 6.0.0
- **图标**: Element Plus Icons 2.3.2

## 环境要求

- Node.js: ^20.19.0 或 >=22.12.0
- npm 或 yarn

## 项目结构

```
Math-Practice-view/
├── public/                 # 静态资源
├── src/
│   ├── api/               # API 接口封装
│   │   ├── paper.js       # 试卷相关接口
│   │   ├── question.js    # 题目相关接口
│   │   ├── upload.js      # 文件上传接口
│   │   ├── user.js        # 用户相关接口
│   │   └── wrongQuestion.js # 错题相关接口
│   ├── router/            # 路由配置
│   │   └── index.js
│   ├── stores/            # Pinia 状态管理
│   │   └── user.js        # 用户状态
│   ├── utils/             # 工具函数
│   │   ├── activityLogger.js # 活动日志
│   │   ├── debug.js       # 调试工具
│   │   ├── icons.js       # 图标工具
│   │   ├── request.js     # Axios 封装
│   │   └── type.js        # 类型定义
│   ├── views/             # 页面组件
│   │   ├── Login.vue      # 登录页
│   │   ├── Register.vue   # 注册页
│   │   ├── student/       # 学生相关页面
│   │   │   ├── StudentDashboard.vue
│   │   │   └── components/
│   │   │       └── WrongQuestions.vue
│   │   └── teacher/       # 教师相关页面
│   │       ├── TeacherDashboard.vue
│   │       └── components/
│   │           ├── ImageUploader.vue
│   │           ├── PaperGeneration.vue
│   │           ├── QuestionManagement.vue
│   │           ├── StudentManagement.vue
│   │           └── TeacherInfo.vue
│   ├── App.vue            # 根组件
│   └── main.js            # 入口文件
├── index.html             # HTML 模板
├── package.json           # 项目配置
├── vite.config.ts         # Vite 配置
└── tsconfig.json          # TypeScript 配置
```

## 安装与运行

### 1. 安装依赖

```bash
npm install
```

### 2. 开发环境运行

```bash
npm run dev
```

启动后，访问 `http://localhost:5173`（Vite 默认端口）

### 3. 构建生产版本

```bash
npm run build
```

构建产物将输出到 `dist/` 目录

### 4. 预览生产构建

```bash
npm run preview
```

### 5. 类型检查

```bash
npm run type-check
```

### 6. 代码格式化

```bash
npm run format
```

## 功能模块

### 用户认证
- 用户登录
- 用户注册
- 角色管理（教师/学生）

### 教师功能
- **题目管理**: 创建、编辑、删除题目（单选题、多选题）
- **题目生成**: 自动生成数学计算题（加减法、乘除法、混合运算）
- **试卷生成**: 从题库中选择题目生成试卷
- **学生管理**: 查看学生列表和信息
- **图片上传**: 为题目上传图片
- **个人信息**: 查看和编辑个人信息

### 学生功能
- **试卷练习**: 查看和完成试卷
- **错题本**: 查看和管理错题
- **成绩查看**: 查看历史成绩和统计

## 配置说明

### API 基础地址

在 `src/utils/request.js` 中配置后端 API 地址：

```javascript
const request = axios.create({
  baseURL: 'http://localhost:8080',  // 修改为实际后端地址
  timeout: 10000,
})
```

### 路由配置

路由配置位于 `src/router/index.js`，包含：
- 登录/注册页面（无需认证）
- 教师仪表板（需要教师角色）
- 学生仪表板（需要学生角色）

路由守卫会自动检查用户认证状态和角色权限。

## 开发规范

### 代码风格
- 使用 Prettier 进行代码格式化
- 遵循 Vue 3 Composition API 最佳实践
- 使用 TypeScript 进行类型检查

### 组件开发
- 使用 `<script setup>` 语法
- 组件命名采用 PascalCase
- 文件命名采用 PascalCase（组件）或 camelCase（工具函数）

### API 调用
- 所有 API 调用统一通过 `src/api/` 目录下的文件封装
- 使用封装的 `request` 实例（已配置拦截器）
- 统一错误处理和消息提示

## 常见问题

### 1. 端口冲突

如果 5173 端口被占用，Vite 会自动使用下一个可用端口，或手动在 `vite.config.ts` 中配置：

```typescript
export default defineConfig({
  server: {
    port: 3000, // 自定义端口
  },
  // ...
})
```

### 2. 跨域问题

开发环境下的跨域问题需要在后端配置 CORS，或使用 Vite 代理：

```typescript
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
})
```

### 3. 构建错误

如果构建时出现类型错误，运行 `npm run type-check` 查看详细错误信息。

## 浏览器支持

- Chrome (推荐)
- Firefox
- Safari
- Edge

## 许可证

本项目为私有项目。

## 联系方式

如有问题，请联系项目维护者。
