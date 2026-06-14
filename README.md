# 小龙虾本地语音助手

QQ群:544813193

这是一个运行在本机 IIS/Classic ASP 页面中的语音问答助手。浏览器负责语音识别和语音朗读，Node.js 本地服务负责把识别出的文字转发给本机 OpenAI 兼容模型代理。

## 功能

- 连续语音对话：点击启动后直接说话，不需要每轮唤醒词。
- 语音转文字：使用浏览器 `SpeechRecognition` / `webkitSpeechRecognition`。
- 本地问答代理：`voice_server.js` 暴露 `/health` 和 `/ask`。
- 文字转语音：使用浏览器 `speechSynthesis` 朗读回答。
- 低延迟提交：临时识别结果停顿约 850ms 后自动提交。
- 小龙虾头像：鼠标跟随眼睛、回答动画、打断/暂停/停止控制。

## 技术链路

```text
用户语音
  -> 浏览器 SpeechRecognition 转文字
  -> xiaozhi.asp fetch http://127.0.0.1:15888/ask
  -> voice_server.js
  -> http://127.0.0.1:15721/v1/responses
  -> 模型返回文字
  -> xiaozhi.asp 显示文字
  -> 浏览器 speechSynthesis 朗读
```

注意：本项目不是把音频直接发给模型。模型只处理文字；语音识别和语音朗读都由浏览器完成。

## 目录说明

```text
voice/
  xiaozhi.asp        主语音助手页面
  index.asp          简化语音问答页面
  voice_server.js    Node.js 本地问答代理
  ask.asp            旧版 Classic ASP 调用入口
  ask_claude.ps1     旧版 PowerShell/Claude 调用脚本
  assets/            头像图片资源
  tmp/               运行时临时目录，不提交
```

## 环境要求

- Windows + IIS，启用 Classic ASP。
- Node.js 18 或更高版本。
- Chrome 或 Edge 浏览器。
- 浏览器允许麦克风权限。
- 本机存在 OpenAI 兼容模型代理，默认地址为 `http://127.0.0.1:15721/v1`。

## 配置

`voice_server.js` 支持以下环境变量：

```text
HR_VOICE_PORT        默认 15888，本地语音后端端口
CODEX_MODEL_BASE_URL 默认 http://127.0.0.1:15721/v1
CODEX_MODEL          默认 ark-code-latest
HR_VOICE_TIMEOUT_MS  默认 45000，模型请求超时毫秒数
```

可参考 `.env.example`。

## 本地启动

在 `voice` 目录执行：

```powershell
node voice_server.js
```

健康检查：

```text
http://127.0.0.1:15888/health
```

正常返回示例：

```json
{"ok":true,"service":"hr-voice-codex","port":15888,"model":"ark-code-latest"}
```

IIS 页面访问示例：

```text
http://127.0.0.1/hr/voice/xiaozhi.asp
```

## 使用方式

1. 打开 `xiaozhi.asp` 页面。
2. 点击“启动小智”。
3. 浏览器提示麦克风权限时选择允许。
4. 直接说话，小龙虾会回答并朗读。
5. 说“休息 / 暂停 / 停止 / 不用了”或点击按钮可停止连续对话。

## 验证命令

```powershell
node --check voice_server.js
node -e "const fs=require('fs'); const s=fs.readFileSync('xiaozhi.asp','utf8'); const js=s.match(/<script>([\s\S]*?)<\/script>/)[1]; new Function(js); console.log('xiaozhi.asp script syntax ok');"
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:15888/health
```

## 常见问题

### 能显示文字但没有声音

- 确认使用 Chrome/Edge。
- 确认页面不是静音标签页。
- 确认 Windows 输出设备和音量正常。
- 点击“启动小智”触发浏览器语音播放解锁。
- 页面日志会显示 `语音播报失败`、`语音播报超时` 等诊断。

### 听不到我说话

- 确认浏览器麦克风权限已允许。
- 确认页面通过 `localhost` / `127.0.0.1` 或 HTTPS 访问。
- 确认浏览器支持 `SpeechRecognition`。
- 页面日志中关注 `not-allowed`、`audio-capture`、`network`、`no-speech`。

### 问答延迟高

- 前端已经使用临时识别结果停顿提交，不必一直等待 final。
- 后端返回 `elapsed_ms`，可判断模型生成耗时。
- 可缩短回答提示词或更换更快的本地模型代理。

## 安全说明

- 该服务默认只监听 `127.0.0.1`，不对局域网暴露。
- 不要提交 `.env`、真实密钥、日志和 `tmp/` 临时文件。
- `Authorization: Bearer PROXY_MANAGED` 是本机代理占位，不是真实 API 密钥。
