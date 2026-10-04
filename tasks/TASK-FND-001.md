# TASK-FND-001 · Monorepo 骨架 + 门禁脚本（复用收编）

| 字段 | 内容 |
|---|---|
| Task ID | TASK-FND-001 |
| 模块 | Foundation（工程地基） |
| 负责人/机器 | DEV-B（台式机，CPU） |
| 目标 | 对齐 `B_REPO_ARCHITECTURE.md` 立住 Monorepo 目录/模块边界 + 统一门禁脚本（三段式）。**策略：复用收编现有 `backend/src/rpb` 作为地基**，不 greenfield 重搭。 |
| 输入 | 无（既有仓库 `真人IP工作台2.0` 已为 git 仓库，含 rpb 地基 + `scripts/check.sh`） |
| 输出 | 对齐后的目录骨架 + `scripts/check.sh`(已有) + `scripts/check.bat`(新增 Windows 对等) + git `develop`/`feature/fnd-001` 分支 |
| Contract | 引用 `B_REPO_ARCHITECTURE.md` 目录结构 + `I_TEST_MATRIX.md` 门禁组成 |
| 依赖 | 无 |
| 不允许修改 | 不建业务模块代码；不碰 `docs/pre-construction/` 冻结基线 |
| 功能 AC | AC-001 目录结构符合 B 文档（补 `contracts/ modules/labs/ apps/ tests/{unit,contract,integration,golden,s65} fixtures/`）；AC-002 门禁三段式（单测/离线集成/前端 tsc）可跑（补 `check.bat` 与 `check.sh` 对等）；AC-003 git 初始化 + .gitignore（排除 data/cache/引擎，已存在）；AC-004 `feature/main/develop` 分支就绪 |
| 异常 AC | AC-005 门禁在无引擎在线时也能跑（不依赖本地引擎） |
| 性能要求 | 门禁单次 < 5 分钟（地基阶段） |
| 测试方法 | 跑 `check.sh` / `check.bat` 全绿 |
| 必交证据 | 目录树 / 门禁输出 / Commit ID |

> 说明：本任务原 F-001 假定 greenfield；经 REVIEW FINDING-1 裁决改为「复用收编 rpb」。既有 `rpb` 已实现 5/7 实体 + Job System + 引擎层 + FastAPI，本任务仅补结构缺口与 Windows 门禁。

状态：TODO
