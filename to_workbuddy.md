# 完整派工单 + 开发总规则 · 给 DEV-B（台式机）的 WorkBuddy

> 你是全新介入这台项目的机器，对项目零了解。这份文档 = 你的「入职说明 + 开发规则 + 本轮任务」，从头读到尾，全部照做。做完一项再下一项。

---

## ⚠️ 重要分工调整（2026-10-04 更新，优先于下文）

1. **任务 1（TASK-FND-001 收编 rpb）改由 Hermes 在算力机做** —— rpb 代码就在那台机器上，不需要你跨机拿。你**跳过任务 1，从任务 2 开始**。

2. **代码回传方式**：你 clone 的公开交接仓库只能读、不能写（你没有 push 凭据）。所以你写的代码，通过 `from_workbuddy.md` 回传——把代码文件内容（markdown 代码块）+ AC 逐项结果 + 测试输出写进报告，Hermes 验真后落地到私有仓库。

3. **任务 0（PPT Spike）** 你已做，结论是条件性 FEASIBLE-CLOUD-ONLY，先搁置（真实 DEV-B 补测 LibreOffice 再定稿）。

4. **你的任务顺序**：任务 2 → 3 → 4 → 5，串行，每个交活报 AC。

---

---

# 第一部分 · 项目全貌（先搞懂我们在做什么）

## 1.1 这是什么项目

**AI 课程平台**（工程仓库名 `ai-course-platform`，商业品牌名待定）。

一句话：**帮老师把课件（PPT）和文案，自动做成教学视频的工具。**

老师要的效果是：导入 PPT 课件和讲课文案 → 系统把文案拆成一个个知识点 → 每个知识点配上对应画面（PPT 页 / 图片 / 小视频 / AI 生图）和配音 → 一键合成一条教学视频。核心价值是「讲到哪儿，画面同步跟到哪儿」，不是数字人从头干讲到尾。

## 1.2 这个产品的两种形态（一套代码两套部署）

| 形态 | 谁用 | 数据库 | 文件存哪 |
|---|---|---|---|
| **SaaS 云端轻量** | 浏览器直接用，零安装 | PostgreSQL 18 | S3 对象存储 |
| **Desktop 本地增强** | 本地装软件，GPU 跑重活 | SQLite + WAL | 本地磁盘 |

**铁律**：两端共享同一套业务模型、同一套接口契约、同一个项目文件格式、同一套 React 前端、同一套编排逻辑。**禁止写成两套产品。**

## 1.3 三台机器分工（已冻结，别越界）

| 机器 | 代号 | 能力 | 负责 |
|---|---|---|---|
| 老笔记本 | DEV-A | CPU | 讲稿、Scene、字幕 |
| **台式机** | **DEV-B（你）** | **CPU** | **地基 + PPT + 标准TTS + 编排 + 成片** |
| 算力机 | DEV-C | 12G GPU | Spike + 集成 + QA |

你现在处于**地基阶段**：先把三台机器都要依赖的公共底座建好（数据模型、接口契约、存储、任务系统）。

---

# 第二部分 · 技术栈（冻结，一个字都不能改）

技术栈是总设计方「子房」冻结的，你只能照做，**不许私自换语言、换框架、换版本**。要改必须走审批。

## 2.1 语言（只有两种，多一种都不行）

- **TypeScript**（前端）
- **Python**（后端）
- **SQL**（数据库）
- 禁止引入 Java / C# / Go / Rust / 其他任何语言。

## 2.2 后端（Python 生态）

| 项 | 冻结值 |
|---|---|
| Python 版本 | **3.11.x**（以现有 3.11.9 为基线，不许升 3.12） |
| Web 框架 | FastAPI |
| 数据校验 | Pydantic |
| ORM | SQLAlchemy |
| 数据库迁移 | Alembic |
| 后端测试 | pytest |

## 2.3 前端（TypeScript 生态）

| 项 | 冻结值 |
|---|---|
| 框架 | React + Vite |
| React 版本 | 先审计现有工程，满足需求就保持现状，**不许以「最新」为理由升级** |
| 前端测试 | Vitest + React Testing Library + Playwright |
| 纪律 | 全项目 TypeScript，核心业务禁止大量 `any` |

## 2.4 数据库（双库同模）

- SaaS 用 **PostgreSQL 18**，Desktop 用 **SQLite + WAL**。
- **一套 SQLAlchemy 模型，两端共用**。差异只在连接串，业务层无感知。

## 2.5 视频合成

- **FFmpeg 是确定性合成核心**。AI 负责决策和产素材，FFmpeg 负责确定性合成。

---

# 第三部分 · 工程目录规范（建目录必须照这个）

仓库名 `ai-course-platform`，一个 Monorepo，结构如下（你建目录严格照此）：

```
ai-course-platform/
├── apps/
│   ├── web/          # SaaS 前端入口
│   └── desktop/      # Desktop 前端入口
├── frontend/         # 共享 React UI
├── backend/
│   ├── api/          # HTTP 接口层
│   ├── domain/       # 领域模型（数据模型）
│   ├── modules/      # 业务模块
│   ├── providers/    # 引擎/能力接缝（本地/云端双实现）
│   ├── workers/      # 任务执行器
│   ├── render/       # 渲染/合成
│   ├── storage/      # StorageProvider
│   └── auth/         # 身份认证
├── contracts/        # 接口契约（类型定义）
├── modules/labs/     # 实验模块
├── tests/
│   ├── unit/         # 单元测试
│   ├── contract/     # 契约测试
│   ├── integration/  # 集成测试
│   ├── golden/       # 黄金流验收
│   └── s65/          # 产品易用性验收
├── fixtures/         # 测试素材
├── docs/             # adr / architecture / acceptance
└── scripts/          # 门禁脚本
```

---

# 第四部分 · 数据规则（最不能错）

## 4.1 核心实体（你建数据模型就建这些）

**平台身份域（3 个）**：
- `User`（用户）
- `Workspace`（工作空间 = 所有权边界）
- `WorkspaceMembership`（用户↔工作空间关系）

**课程生产域（7 个，叫「七实体」）**：
- `Project`（顶层容器，一个项目含多个 Course）
- `Course`（一门课 = 教学母源）
- `Lesson`（一课/章节）
- `Scene`（一个知识点）
- `Asset`（素材资产）
- `Job`（任务）
- `Provider`（引擎接缝）

## 4.2 所有权铁律（记死）

- 所有资源挂 **`workspace_id`**，**不挂 `user_id`**。例：`course.workspace_id` 对，`course.user_id` 错。
- 用户通过 Membership 属于 Workspace。将来机构版（多老师一个工作空间）不用重构。

## 4.3 文件不进数据库

- 视频/PPT/图片/音频/大模型，**绝不塞进数据库**。
- 数据库只存元数据：Asset ID、路径/key、类型、hash、版本、来源、归属、Provider、状态。
- 真实文件走 **StorageProvider**（本地=磁盘，SaaS=S3），业务模块不知道底层是盘还是云。

---

# 第五部分 · 编码铁律（每条都守，缺一不可）

1. **路径零盘符**：所有路径走配置/环境变量，禁止硬编码 `C:\` `D:\` 之类盘符。
2. **进度真实值驱动**：任务进度必须来自引擎真实回调，禁止写死估算、禁止假进度。
3. **幂等**：每个生成资产记参数指纹（param_hash），参数不变不重复生成。
4. **母源唯一**：Course 是母源，字幕/配音/讲稿/画面全部从它派生，禁止多套不一致。
5. **不硬编码引擎/算法**：所有能力走 Provider 接缝，换引擎只加 Provider，不改业务代码。
6. **每任务一个 commit，feature 分支**：禁止直接改 main。
7. **零引擎标识**：数据模型和契约里不内嵌任何引擎私有标识。

---

# 第六部分 · 接口契约原则（模块怎么对接）

三个概念：**Contract（接口定义）→ Job（任务）→ Asset（资产）**。

- 模块之间**只通过这三样对接**，不互相 import 对方内部实现。
- 输入统一传 **AssetID**（资产引用），不传文件路径。
- 错误码统一结构：`{code, message, retryable}`。
- **改 Contract 字段必须上报 Architecture Review**，不许私自增删。

---

# 第七部分 · 验收标准（怎么算「完成」）

## 7.1 八级验收 Gate

| 级 | 名称 | 何时跑 |
|---|---|---|
| G0 | 任务定义验收 | 开工前（任务单缺项禁止开工） |
| G1 | 开发者自验 | 每个任务 |
| G2 | 模块独立验收 | 每个任务 |
| G3 | Contract 验收 | 涉及公共契约时必跑 |
| G4 | 子系统集成验收 | 按模块组/里程碑 |
| G5 | Golden 验收 | 主要集成里程碑 |
| G6 | 产品易用性验收 | 重要 UI 版本/RC |
| G7 | 发布验收 | 正式 Release |

## 7.2 任务生命周期（每个任务走这条线）

```
TODO → IN DEVELOPMENT → DEV DONE → ACCEPTED → CERTIFIED
```

- 你做完 = **DEV DONE**。
- Hermes 验收通过 = **ACCEPTED**。
- 子房/甲方终审 = **CERTIFIED**。
- **DEV DONE 绝对不等于完成。** 没有 Hermes 的 ACCEPTED，任务不算完。

---

# 第八部分 · 你的本轮任务（按顺序做）

## 任务 0：PPT-SPIKE-001（先做，优先级最高）

**干什么**：实测「PPT 转图片」用哪个方案可行。

**两个候选都要测**：① LibreOffice 无头导出（准但 300MB 依赖）② 纯 Python python-pptx（轻但只读不渲染）。

**产出 5 项真实证据（缺一不可，不许编）**：环境版本 / 转图耗时 / 资源占用 / 复杂 PPT 连转 3 份成功率 / 画质（附样图路径）。

**结论三选一**：`FEASIBLE-LOCAL` / `FEASIBLE-CLOUD-ONLY` / `INFEASIBLE`。

**红线**：只出结论+证据，不写生产代码。

---

## 任务 1：TASK-FND-001 — Monorepo 骨架 + 门禁

**干什么**：按第三部分目录规范，立住目录结构 + 门禁脚本。

**AC**：
- AC-001 目录结构符合第三部分
- AC-002 门禁三段式（单测 + 离线集成 + 前端 tsc）能跑，Linux `check.sh` + Windows 对等 `check.bat`
- AC-003 git 初始化 + .gitignore（排除 data/cache/引擎）
- AC-004 main/develop/feature 分支就绪
- AC-005 门禁无引擎在线也能跑

**策略**：**复用收编现有 `backend/src/rpb` 代码地基，不 greenfield 重写**（它已有数据模型/任务系统/引擎层雏形，补结构缺口即可）。

---

## 任务 2：TASK-FND-002 — 数据模型 + 身份域

**干什么**：用 SQLAlchemy 建第四部分的实体 + Alembic 迁移。

**12 条 AC**：
1. 创建 User 成功
2. User 自动有 Personal Workspace
3. Project 必须归属一个 Workspace
4. Course/Asset/Job 能追溯所属 Workspace
5. Workspace A 不能读 Workspace B 的数据
6. Desktop 可用 Local Workspace（workspace_type=LOCAL_PERSONAL）不强制联网
7. Guest/Dev 身份可升级为正式身份，不迁移数据
8. 删除 User 不得误删课程资产，有生命周期策略
9. Alembic migration 从空库完整建 Schema
10. SQLite 与 PostgreSQL 核心模型一致
11. 至少两个 User + 两个 Workspace 的隔离测试
12. Domain 层只保留 Workspace/Membership 基础能力，不硬编码机构版逻辑

---

## 任务 3：TASK-FND-003 — 接口契约落地

**干什么**：把接口契约落成代码类型定义（Python pydantic + TS 类型），放 `contracts/`。

**AC**：
- AC-001 Asset 字段齐全（id/type/hash/storage_key/version/来源/provider/status）
- AC-002 Job 八态枚举冻结：QUEUED / RUNNING / WAITING_PROVIDER / RETRYING / STALLED / COMPLETED / FAILED / CANCELLED
- AC-003 错误码统一 {code, message, retryable}
- AC-004 输入统一 asset_refs 不传路径
- AC-005 非法 AssetID / 非法 Job 态能校验报错

---

## 任务 4：TASK-FND-004 — StorageProvider

**干什么**：统一存储层（Local 实现 + S3 接口位占位）。

**AC**：
- AC-001 上传→唯一 key→读回字节一致
- AC-002 相同文件 hash 去重
- AC-003 原始/生成素材分离存储
- AC-004 删 Scene 不立即物理删 Asset
- AC-005 路径全走配置，零盘符
- AC-006 文件缺失返回可理解错误
- AC-007 写失败可恢复
- 性能：流式读写，不整文件进内存

---

## 任务 5：TASK-FND-005 — Job System

**干什么**：八态状态机 + 幂等 + Worker 心跳/租约/卡死恢复。

**AC**：
- AC-001 八态冻结
- AC-002 幂等键防重复提交
- AC-003 heartbeat 超时 → STALLED
- AC-004 lease 防两个 Worker 抢同一 Job
- AC-005 stalled recovery 可重放
- AC-006 Worker 崩了 Job 不永久卡 RUNNING（进 STALLED）
- AC-007 引擎拒绝（非 0）严格 FAILED，不静默成功

---

# 第九部分 · 交活方式

每做完一个任务：
1. 写 `handoff/from_workbuddy.md`，内容 =「AC 逐项 N/N PASS」+ 证据（代码/测试输出/日志/Commit ID）。
2. 响提示音。
3. 等 Hermes 验收 ACCEPTED，再开始下一个任务。

---

**顺序再强调：任务 0 → 1 → 2 → 3 → 4 → 5，串行。**
