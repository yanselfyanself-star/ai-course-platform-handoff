# TASK-FND-003 · Contract 落地（类型/接口定义）

| 字段 | 内容 |
|---|---|
| Task ID | TASK-FND-003 |
| 模块 | Foundation（契约地基） |
| 负责人/机器 | DEV-B（台式机，CPU） |
| 目标 | 把 `D_CONTRACT_1_DRAFT.md` 落成代码级类型/接口定义（Python pydantic + TS 类型），置于 `contracts/` |
| 输入 | 无 |
| 输出 | `contracts/` 目录的类型定义 + Asset/Job 的 Pydantic schema + 错误码枚举 |
| Contract | 引用 `D_CONTRACT_1_DRAFT.md` |
| 依赖 | TASK-FND-002 |
| 不允许修改 | Contract 字段不得私自增删（改需上报 Architecture Review） |
| 功能 AC | AC-001 Asset 类型/字段齐全（id/type/hash/storage_key/version/来源/provider/status）；AC-002 Job 八态枚举冻结；AC-003 错误码统一结构 {code,message,retryable}；AC-004 输入统一 asset_refs 不传路径 |
| 异常 AC | AC-005 非法 AssetID/非法 Job 态能校验报错 |
| 性能要求 | — |
| 测试方法 | `tests/contract/` 单测（schema 校验） |
| 必交证据 | 类型定义代码 / schema / 单测 / Commit ID |

状态：TODO
