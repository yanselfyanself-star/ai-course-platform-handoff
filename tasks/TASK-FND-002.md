# TASK-FND-002 · Core Domain + Identity Boundary

| 字段 | 内容 |
|---|---|
| Task ID | TASK-FND-002 |
| 模块 | Foundation（数据地基） |
| 负责人/机器 | DEV-B（Hermes 主导/合并） |
| 目标 | 建课程生产域七实体 + 平台身份域三实体（DEC-005）+ Alembic 迁移 |
| 输入 | 无 |
| 输出 | SQLAlchemy 模型 + Alembic 迁移 + 双库（SQLite 可跑，PG 方言预留） |
| Contract | 引用 `C_DATA_ARCHITECTURE.md`（含 §〇 身份域 + §一 七实体）+ `D_CONTRACT_1_DRAFT.md` |
| 依赖 | TASK-FND-001 ｜ 前置裁决：DEC-005（已冻结） |
| 不允许修改 | 不写业务逻辑；数据模型不含引擎标识；**禁止 course.user_id/asset.user_id 直接归 User（一律 workspace_id）**；不把机构版逻辑硬编码 |

## 必须建立

**平台身份域（Identity）**：User / Workspace / WorkspaceMembership
**课程生产域（Course Core）**：Project / Course / Lesson / Scene / Asset / Job / Provider

## 验收标准（AC）

- AC-001 创建 User 成功
- AC-002 User 自动拥有 Personal Workspace
- AC-003 Project 必须归属一个 Workspace
- AC-004 Course/Asset/Job 必须能追溯所属 Workspace
- AC-005 Workspace A 不能读取 Workspace B 数据
- AC-006 Desktop 可用 Local Workspace（workspace_type=LOCAL_PERSONAL），不强制联网
- AC-007 Guest/Dev 身份未来可升级为正式身份而不迁移课程数据
- AC-008 删除 User 不得直接导致课程资产误删，有明确生命周期策略
- AC-009 Alembic migration 从空库完整建 Schema
- AC-010 SQLite 与 PostgreSQL 核心模型一致
- AC-011 测试至少含两个 User、两个 Workspace 的隔离测试
- AC-012 Domain 层只保留 Workspace/Membership 基础能力，不硬编码机构版逻辑

## 测试方法
pytest 单测（模型 + 隔离测试）+ Alembic migration dry-run

## 必交证据
模型代码 / 迁移脚本 / 单测结果（AC 逐项）/ Commit ID

状态：TODO
