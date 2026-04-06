---
name: py-download
description: "Universal video downloader. Download public videos to ~/Downloads using yt-dlp. Primary targets: XiaoHongShu (小红书), Douyin (抖音), YouTube, Bilibili (B站), X/Twitter, TikTok, and other sites supported by yt-dlp. Use when user shares a video URL and wants to save it locally, or says '下载视频', '保存视频', 'download video', '小红书视频', '抖音视频', 'YouTube 视频', or 'B站视频'."
version: "2.0.0"
user_invocable: true
---

# py-download

把公开可下载的视频保存到 `~/Downloads/`。默认使用 `yt-dlp`，必要时加浏览器 cookies。

## 依赖

- `yt-dlp`
- `ffmpeg`

## 支持范围

优先按 `yt-dlp` 当前 extractor 处理。重点支持：

- 小红书 `xiaohongshu.com` / `xhslink.com`
- 抖音 `douyin.com` / `v.douyin.com`
- YouTube `youtube.com` / `youtu.be`
- Bilibili `bilibili.com` / `b23.tv`
- X / Twitter `x.com` / `twitter.com`
- TikTok `tiktok.com`

如果用户给的是其他站点 URL，也先交给 `yt-dlp` 试，不要先主观判死。

## 执行流程

### 1. 解析输入

从用户消息中提取一个或多个 URL。

如果没有 URL，直接要求用户补充链接，不要猜。

短链接先解析成最终地址：

```bash
curl -Ls -o /dev/null -w '%{url_effective}' "SHORT_URL"
```

常见短链接包括：`xhslink.com`、`v.douyin.com`、`b23.tv`、`t.co`、`youtu.be`。

### 2. 先做探测

对每个 URL，先探测元信息，不直接下载：

```bash
yt-dlp --dump-single-json --no-warnings --no-playlist "URL"
```

读取结果，确认：

- 站点 / extractor
- 标题
- 上传者
- 是否是 playlist / album / multi-video
- 是否需要登录

如果用户给的是单视频需求，但探测结果是 playlist，默认加 `--no-playlist`，除非用户明确说要整套下载。

### 3. 默认下载命令

默认下载单视频到 `~/Downloads/`：

```bash
yt-dlp \
  --no-playlist \
  -P "$HOME/Downloads" \
  -o "%(extractor)s_%(title).120B_%(id)s.%(ext)s" \
  -f "bv*+ba/b" \
  --merge-output-format mp4 \
  --embed-metadata \
  "URL"
```

规则：

- 优先取最佳视频+音频，拿不到时回退到单文件最佳流
- 合并容器优先 `mp4`
- 输出名保留平台 + 标题 + ID，避免重名
- 不要把 `~/Downloads` 写在引号里；路径用 `"$HOME/Downloads"`

### 4. 登录 / 风控回退

如果报错里包含 `login`、`sign in`、`private`、`authentication`、`forbidden`、`age-restricted`、`members-only`、`HTTP Error 403`，先重试浏览器 cookies：

```bash
yt-dlp \
  --cookies-from-browser safari \
  --no-playlist \
  -P "$HOME/Downloads" \
  -o "%(extractor)s_%(title).120B_%(id)s.%(ext)s" \
  -f "bv*+ba/b" \
  --merge-output-format mp4 \
  --embed-metadata \
  "URL"
```

如果用户明显不是 Safari 用户，再改用：

- `--cookies-from-browser chrome`
- `--cookies-from-browser brave`
- `--cookies-from-browser edge`

### 5. 平台特例

#### 小红书 / 抖音

- 先直接用默认命令
- 如果返回风控或登录限制，再加浏览器 cookies
- 如果同一条内容包含多媒体，按 `yt-dlp` 的实际输出为准，下载完成后逐个汇报

#### YouTube

- 先用默认命令
- 如果只是个别格式拿不到，先不要乱改参数，先试 cookies
- 某些 YouTube 格式/功能按 `yt-dlp` 官方文档可能需要额外的 PO Token；如果默认下载和 cookies 都失败，要把这一点明确告诉用户，不要硬编 workaround

#### Bilibili

- 公开视频先直接下载
- 大会员、登录后高清流、番剧、课程、收藏夹等内容，通常需要 cookies
- 如果是合集 / 分 P，默认只下当前视频，除非用户明确要求整集或整套

### 6. 多链接处理

如果用户一次给多个 URL，对每个 URL 独立执行：

1. 解析 / 展开短链接
2. 探测
3. 下载
4. 汇总结果

不要因为一个失败就中断全部。

### 7. 汇报结果

下载完成后，用：

```bash
ls -lh "$HOME/Downloads" | tail
```

或直接列出本次产出的绝对路径、文件大小、平台和标题。

## 故障处理

### 站点支持但下载失败

优先顺序：

1. 直接下载
2. 加 `--cookies-from-browser`
3. 报告精确错误

不要上来就改一堆玄学参数。

### 链接不是单视频

如果探测结果是 playlist / 收藏夹 / 频道 / 用户页：

- 默认只下载单条，不自动扫库
- 明确告诉用户这是列表型链接
- 只有用户明确要求时，才去掉 `--no-playlist`

### 本地依赖缺失

- `yt-dlp` 缺失：先安装再继续
- `ffmpeg` 缺失：先安装再继续；没有它，很多站点的音视频无法合并

### 结果验证

至少确认三件事：

- 文件已写入 `~/Downloads/`
- 文件大小不是 0
- 扩展名和容器合理（常见为 `mp4`、`mkv`、`webm`）
