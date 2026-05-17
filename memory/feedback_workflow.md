---
name: 开发工作流规则
description: 每次较大改动后必须执行的步骤，避免 agent 切换时丢失上下文
type: feedback
originSessionId: 11d20578-102e-4724-a014-b46b77d8be86
---
每次完成一个模块或较大改动后，必须按以下顺序执行，不可跳过：

1. **更新 `PLAN.md`** — 在对应步骤前打勾（`- [x]`），标记已完成
2. **更新 `project_progress.md`** — 将对应行的 ⬜ 改为 ✅，并注明 commit hash
3. **`git add` 所有改动文件**（指定文件名，不用 `-A`）
4. **`git commit`** — 提交日志必须包含：
   - 标题：一句话说明做了什么（中文）
   - 正文：列出改动的文件及原因
   - 剩余工作：下一步要做什么
   - 格式见下方模板

**Why:** 用户要求每次完成后提交，方便 agent 切换时通过 `git log` 快速定位进度，不依赖对话上下文。

**How to apply:** 改动超过 2 个文件或完成任意一个 PLAN.md 中的模块时触发。单文件小修正可不提交，但完成一个完整功能模块必须提交。

---

## Commit 日志模板

```
<模块名>：<一句话描述>

完成内容：
- <文件1>：<做了什么>
- <文件2>：<做了什么>

参考来源：
- Android demo: <Activity 或文件名>
- iOS demo: <ViewController 或文件名>（如有）

剩余工作（下一步）：
- [ ] <下一个模块>
- [ ] <下一个模块>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```
