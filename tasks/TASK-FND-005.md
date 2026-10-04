# TASK-FND-005 · Job System（八态 + 幂等 + heartbeat/lease/stalled）

| 字段 | 内容 |
|---|---|
| Task ID | TASK-FND-005 |
| 模块 | Foundation（任务地基） |
| 负责人/机器 | DEV-B（台式机，CPU） |
| 目标 | Job 八态状态机 + 幂等键 + Worker heartbeat/lease/stalled recovery |
| 输入 | 无（既有 `backend/src/rpb/tasks/` 已有 Job System 主体，本任务核对/补全八态与 stalled recovery） |
| 输出 | Job 提交/查询/状态机 + Worker 心跳/租约/stalled 检测（对齐 `D_CONTRACT_1_DRAFT.md` 第三节） |
| Contract | 引用 `D_CONTRACT_1_DRAFT.md` 第三节 |
| 依赖 | TASK-FND-002, TASK-FND-003 |
| 不允许修改 | 八态不得私自增删；进度必须引擎真实值驱动，禁写死估算 |
| 功能 AC | AC-001 八态冻结（QUEUED/RUNNING/WAITING_PROVIDER/RETRYING/STALLED/COMPLETED/FAILED/CANCELLED）；AC-002 幂等键防重复提交；AC-003 heartbeat 超时→STALLED；AC-004 lease 防双 Worker 抢同一 Job；AC-005 stalled recovery 可重放 |
| 异常 AC | AC-006 Worker 崩后 Job 不永久卡 RUNNING（进 STALLED）；AC-007 引擎拒绝（code!=0）严格 FAILED 不静默成功 |
| 性能要求 | 提交/查询低延迟 |
| 测试方法 | 单测（状态机 + 幂等 + stalled 场景模拟） |
| 必交证据 | 代码 / 状态机测试 / Commit ID |

状态：TODO
