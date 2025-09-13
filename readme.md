# AI Read Helper

AI Read Helper 是一个基于HarmonyOS的图像文字识别应用，利用AI技术帮助眼睛不便的老年人用户快速识别和分析图片中的文字内容。

## 项目概述

该应用通过拍照或从相册选择图片，将图片转换为Base64编码后发送到AI服务接口，实现对图片中文字内容的识别和分析。主要功能包括：

- 拍照获取图片
- 从相册选择图片
- 图片Base64编码处理
- 调用AI接口进行文字识别
- 展示识别结果

## 技术架构

### 开发框架
- 基于HarmonyOS SDK 5.0.0(12)
- 使用ArkTS语言开发
- 采用Stage模型

### 核心技术栈
- ArkUI框架用于界面构建
- HarmonyOS网络请求API
- 文件IO操作
- Base64编码处理
- AI服务接口集成

### 主要依赖
```json
{
  "dependencies": {
    "@kit.AbilityKit": "系统能力包",
    "@kit.PerformanceAnalysisKit": "性能分析工具",
    "@kit.ArkUI": "UI框架",
    "@kit.NetworkKit": "网络请求库",
    "@kit.CoreFileKit": "核心文件处理",
    "@kit.BasicServicesKit": "基础服务"
  }
}
```


## 功能特性

### 1. 图像获取
- 支持拍照获取图片
- 支持从相册选择图片
- 图片大小限制（最大10MB）

### 2. 图像处理
- 自动将图片转换为Base64编码
- 错误处理和异常捕获
- 文件读取优化

### 3. AI识别
- 集成阿里云DashScope API
- 使用qwen-omni-turbo模型
- 支持图文混合识别

### 4. 用户界面
- 简洁直观的操作界面
- 实时状态反馈
- 识别结果展示

## 项目结构

```
ai-read-helper/
├── AppScope/                 # 应用级别配置
│   ├── app.json5            # 应用配置文件
│   └── resources/           # 应用资源
├── entry/                   # 主模块
│   ├── src/main/           # 主要源代码
│   │   ├── ets/            # ArkTS代码
│   │   │   ├── entryability/     # 应用能力
│   │   │   ├── entrybackupability/ # 备份能力
│   │   │   └── pages/            # 页面组件
│   │   └── resources/      # 模块资源
│   ├── build-profile.json5 # 构建配置
│   └── oh-package.json5    # 包配置
├── hvigor/                 # 构建工具配置
└── oh-package.json5        # 项目包配置
```


## 核心代码说明

### 主页面 (Index.ets)

主页面实现了完整的图像识别流程：

1. **图像获取**：
    - `photographUpload()` - 拍照功能
    - `selectFromGallery()` - 相册选择功能

2. **图像处理**：
    - `imageToBase64()` - 图像转Base64编码
    - `base64Encode()` - Base64编码实现

3. **API调用**：
    - `sendImageToAPI()` - 发送请求到AI服务
    - 使用qwen-omni-turbo模型进行识别

4. **结果展示**：
    - `ShowResult`组件展示识别结果
    - 支持滚动查看长文本

### 配置文件

- [app.json5](file://F:\admin\Documents\GitHub\ai-read-helper\AppScope\app.json5) - 应用基本信息配置
- [module.json5](file://F:\admin\Documents\GitHub\ai-read-helper\entry\src\main\module.json5) - 模块配置，包括权限声明
- [build-profile.json5](file://F:\admin\Documents\GitHub\ai-read-helper\build-profile.json5) - 构建配置
- [hvigor-config.json5](file://F:\admin\Documents\GitHub\ai-read-helper\hvigor\hvigor-config.json5) - 构建工具配置

## 权限要求

应用需要以下权限：

```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```


## API配置

应用集成了阿里云DashScope API服务：

- API地址: `https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions`
- 使用模型: `qwen-omni-turbo`
- 认证方式: Bearer Token

## 部署与运行

### 环境要求
- DevEco Studio 5.0+
- HarmonyOS SDK 5.0.0(12)
- 支持设备: 手机

### 构建步骤
1. 克隆项目到本地
2. 使用DevEco Studio打开项目
3. 同步项目依赖
4. 连接设备或启动模拟器
5. 点击运行按钮

### 签名配置
项目已配置默认签名，可用于调试运行。

## 使用说明

1. 启动应用后，点击"开始拍照"或"相册选择"
2. 选择需要识别的图片
3. 点击"分析图片"按钮
4. 等待AI识别完成，查看结果

## 注意事项

1. 图片大小限制为10MB以内
2. 需要网络连接才能使用AI识别功能
3. 首次使用需要授予网络权限

## 贡献指南

欢迎提交Issue和Pull Request来改进这个项目。

## 许可证

本项目仅供学习和参考使用，请遵守相关法律法规。