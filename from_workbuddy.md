# WorkBuddy 交活报告 · DEV-C · REVIEW FINDING（Foundation Sprint 开工前侦察）

> 性质：**侦察 + REVIEW FINDING**，非执行。依据 `to_workbuddy.md`（2026-10-04 版）+ `docs/pre-construction/`。
> 机器确认：本机 = **DEV-C**（GPU `NVIDIA GeForce RTX 5070, 12227 MiB` = 12G 算力机）。
> 仓库确认：`D:\真人 IP 工作台\真人IP工作台2.0` 已是 git 仓库（`main` + `origin/main`），非空白。

---

## 一、既有资产清点（证据，非推测）

| 项 | 现状 | 证据 |
|---|---|---|
| git 仓库 | 已在 `main`，有 `origin/main` | `git rev-parse --is-inside-work-tree` = true |
| Monorepo 骨架 | 部分存在：`backend/ frontend/ scripts/ docs/ data/ tools/` | `ls -d */` |
| 门禁 `check.sh` | **已存在**（18KB） | `scripts/check.sh` |
| 门禁 `check.bat` | **缺失**（仅 Windows 侧需求，AC-002 要求） | `find` 无 `check.bat` |
| 领域模型 | `backend/src/rpb/domain/`：asset/project/scene/job/provider/content/render/base（覆盖七实体中 5 个：Project/Scene/Asset/Job/Provider；**缺 Course/Lesson**） | `find backend/src -name *.py` |
| Job System | `backend/src/rpb/tasks/`：idempotency/states/supervisor/worker **已实现** | 同上 |
| 引擎层 | `backend/src/rpb/engines/`：全套渲染适配器 | 同上 |
| HTTP 层 | `backend/src/rpb/http/`：FastAPI 路由齐 | 同上 |
| **身份域 User/Workspace/WorkspaceMembership** | **完全缺失**（TASK-FND-002 核心） | `find` 无 identity/user/workspace 目录 |
| **Alembic 迁移** | **缺失**（TASK-FND-002 AC-009） | `ls -d backend/alembic*` = 无 |
| 契约层 `contracts/` | **缺失**（B 文档模块边界铁律） | `ls -d contracts` = 无 |
| `modules/labs/`、`apps/`、`tests/{unit,contract,integration,golden,s65}`、`fixtures/` | **全部缺失** | `ls -d` 均无 |
| 分支 | 仅 `main`；**缺 `develop` 与 `feature/*`**（AC-004） | `git branch -a` |

---

## 二、REVIEW FINDING（需 Hermes/子房裁决，DEV-C 不自行定）

### FINDING-1（高）：派工单「从零建」前提与仓库现状矛盾
- 派工单 TASK-FND-001~005 均标 `TODO`、输入「无」，措辞是 greenfield。
- 但 `backend/src/rpb/` 已是实质地基代码（5/7 实体 + Job System + 引擎 + FastAPI），且与派工单引用的「DEC-005 冻结七实体 + 身份域」高度重叠。
- **分歧点**：这堆 `rpb` 代码到底是 (a) 应被 Foundation Sprint 复用/收编的「前置资产」，还是 (b) 需按 B_REPO_ARCHITECTURE 另起炉灶、把 `rpb` 当 v1 弃用？
- 影响：决定 FND-001 是「补缺失结构」还是「重搭」；FND-002 是在 `rpb/domain` 上加身份域，还是新建 `backend/domain`。
- **请求裁决**：请明确「复用 rpb 收编」还是「greenfield 重搭」。

### FINDING-2（中）：任务文件命名与派工单引用不一致
- 派工单 §三.2 引用 `handoff/tasks/TASK-FND-001~005.md`。
- 磁盘实际：`TASK-F-001.md`、`TASK-F-002.md`、`TASK-F-003.md`、`TASK-F-004.md`、`TASK-F-005.md` + 一个 `TASK-FND-002.md`。
- **缺失文件**：`TASK-FND-001`、`TASK-FND-003`、`TASK-FND-004`、`TASK-FND-005` 共 4 份（仅有 `TASK-F-00x` 对应物，命名差 `ND`）。
- **请求**：确认以 `TASK-F-00x.md` 为准，还是补 `TASK-FND-00x.md` 正式版；避免 AC 对不齐。

### FINDING-3（中）：身份域为真正净新增，应优先
- 无论 FINDING-1 如何裁决，身份域（User/Workspace/WorkspaceMembership）+ Alembic 是当前仓库**确实没有**且 FND-002 要求的部分。
- 这是 Foundation 最该先落地的硬骨头，建议无论如何都从它切入。

### FINDING-4（低）：派工单两份任务表状态已滞后
- 派工单表格标 FND-001~005 全 `TODO`；但仓库证据显示 FND-001（骨架/门禁）、FND-005（Job System）主体已实现。
- 建议 Hermes 复核各任务真实完成度，避免重复派活或漏验。

---

## 三、DEV-C 当前可安全推进项（不踩红线、不依赖裁决）

以下为**纯增量、不改动既有代码/冻结文档**，可在裁决回来前先做：
1. 补 `scripts/check.bat`（Windows 门禁，AC-002 明确要求，与现有 `check.sh` 对等）。
2. 建 git 分支 `develop` + `feature/fnd-002`（AC-004；不碰 main）。
3. 若裁决为「复用 rpb」，在 `rpb/domain` 上加身份域三实体 + Alembic（FND-002 净新增部分）。

---

## 四、待 Hermes 回复后我方动作
- 收到 FINDING-1/2 裁决 → 按裁决执行对应 FND 任务，逐 AC 自验，回写本报告「交活」段。
- 若裁决「先做安全项」→ 我立即执行第三节 1~3。

> 注：本次仅侦察 + 上报，未改任何代码、未碰 `docs/pre-construction/` 冻结基线、未宣布复审通过（遵守 D-014）。
