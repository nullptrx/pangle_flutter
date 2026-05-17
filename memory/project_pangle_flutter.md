---
name: pangle_flutter 项目概况
description: pangle_flutter Flutter 插件项目的背景、目标和核心规则，新 agent 入场必读
type: project
originSessionId: 11d20578-102e-4724-a014-b46b77d8be86
---
## 项目位置

主仓库（所有开发工作在此进行）：`/Users/su/repo/workspace/nullptrx/pangle_flutter/`

Memory 文件：`memory/`（主仓库根目录，在项目内版本控制，不放 Claude 系统目录）

## 项目目标

将 Android 原生 demo（`template/demo`）的所有广告功能完整复刻到 Flutter example，再逐步实现 Flutter plugin（Dart → Android → iOS）。

完整规划见：`PLAN.md`（主仓库根目录）

## 核心规则（开发时必须遵守）

1. **以 demo 功能为准，不兼容旧实现** — 旧 plugin 代码不需要保留兼容性，直接重写
2. **demo 中没用到的参数/类一律删除** — 不做"保留旧接口"的过渡
3. **demo 中用到的每个参数必须完整复刻** — `AdSlot.Builder` 的每个字段都要在 Dart 配置类中体现
4. **每次较大改动结束后必须**：
   - 更新 `PLAN.md` 中的完成进度（勾选已完成步骤）
   - 更新本 memory 中的 `project_progress.md` 完成状态
   - `git commit` 并写完整的中文提交日志（说明做了什么、改了哪些文件、还剩什么）

## Why：全参数复刻

**Why:** 用户明确要求 demo 里用到的参数要完整复刻，旧 plugin 有大量简化/遗漏的参数（如 `adLoadType`、`rewardAmount`、`tolerateTimeout`、`isHalfSize` 等），这些在实际接入时都有业务含义。

**How to apply:** 实现每个配置类时，对照 `PLAN.md` Phase 2 的参数清单逐字段实现，不能只写 `slotId`。
