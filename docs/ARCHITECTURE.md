# 架构说明

## 组件

### `xiaozhi.asp`

主交互页面，负责：

- 初始化浏览器语音识别。
- 接收临时和最终识别文本。
- 将文字提交给本地 `/ask` 服务。
- 显示回答。
- 调用浏览器语音合成朗读回答。
- 管理连续对话状态：监听、思考、回答、暂停。

### `voice_server.js`

Node.js 本地 HTTP 服务，默认监听：

```text
http://127.0.0.1:15888
```

接口：

- `GET /health`：返回服务状态。
- `POST /ask`：接收 `q` 参数，调用本地模型代理生成回答。

### 本地模型代理

默认地址：

```text
http://127.0.0.1:15721/v1
```

实际请求：

```text
POST /responses
```

该端口不是标准端口，是本机运行环境提供的 OpenAI 兼容代理地址。可通过 `CODEX_MODEL_BASE_URL` 覆盖。

## 状态机

```text
用户点击启动
  -> primeSpeech 解锁浏览器 TTS
  -> startRec 开始监听
  -> onresult 收到文字
  -> stopRec 暂停监听
  -> ask 调用后端
  -> add 显示回答
  -> speak 朗读回答
  -> onend/onerror 清理状态
  -> startRec 恢复监听
```

回答时暂停识别是必要的，否则浏览器可能把电脑朗读内容重新识别成用户输入，引发回声循环。

## 低延迟策略

浏览器语音识别有两类结果：

- `interimText`：临时识别结果，速度快但可能修正。
- `finalText`：最终识别结果，更稳定但更慢。

页面策略：

- 收到 `finalText` 时立即提交。
- 只有 `interimText` 时，用户停顿约 `850ms` 后提交。

这能减少等待最终识别结果造成的体感延迟。

## 文字转语音

使用浏览器 API：

```js
window.speechSynthesis
new SpeechSynthesisUtterance(text)
```

实现要点：

- 用户点击后调用 `primeSpeech()`，满足浏览器播放策略。
- 优先选择 `zh-*` 中文声音。
- 调用 `speechSynthesis.resume()`。
- 保留 `currentUtterance` 引用，避免对象被回收。
- 处理 `onstart`、`onend`、`onerror` 和超时。

