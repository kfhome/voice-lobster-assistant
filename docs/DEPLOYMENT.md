# 部署与发布说明

## IIS 部署

1. 将 `voice` 目录放在 IIS 站点下，例如：

   ```text
   E:\IIS\hr\voice
   ```

2. 确认 IIS 启用 Classic ASP。

3. 确认页面可访问：

   ```text
   http://127.0.0.1/hr/voice/xiaozhi.asp
   ```

## 启动 Node 后端

在服务器上执行：

```powershell
cd E:\IIS\hr\voice
node voice_server.js
```

也可以使用环境变量覆盖配置：

```powershell
$env:HR_VOICE_PORT='15888'
$env:CODEX_MODEL_BASE_URL='http://127.0.0.1:15721/v1'
$env:CODEX_MODEL='ark-code-latest'
$env:HR_VOICE_TIMEOUT_MS='45000'
node voice_server.js
```

## 健康检查

```powershell
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:15888/health
```

## GitHub 发布

如果已经有 GitHub 空仓库：

```powershell
git remote add origin https://github.com/<owner>/<repo>.git
git branch -M main
git push -u origin main
```

如果使用 SSH：

```powershell
git remote add origin git@github.com:<owner>/<repo>.git
git branch -M main
git push -u origin main
```

## 不应提交的内容

- `.env`
- `tmp/`
- 日志文件
- 调试截图
- 图片处理前的备份文件
- 任何真实 API Key 或账号密码

