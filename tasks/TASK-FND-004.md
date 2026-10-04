# TASK-FND-004 · StorageProvider（Local/S3 双实现）

| 字段 | 内容 |
|---|---|
| Task ID | TASK-FND-004 |
| 模块 | Foundation（存储地基） |
| 负责人/机器 | DEV-B（台式机，CPU） |
| 目标 | 统一 StorageProvider：Local 实现 + S3 接口位，业务模块不知道底层是盘还是云 |
| 输入 | 无 |
| 输出 | StorageProvider 抽象 + Local 实现 + S3 占位（置于 `backend/src/rpb/storage/` 或对齐 B 文档 `backend/storage/`） |
| Contract | 引用 `C_DATA_ARCHITECTURE.md` |
| 依赖 | TASK-FND-002 |
| 不允许修改 | 业务模块不得直接读写文件系统（必须走 StorageProvider）；不写死盘符 |
| 功能 AC | AC-001 上传→生成唯一 key→读回字节一致；AC-002 同文件 hash 去重；AC-003 原始/生成素材分离存储；AC-004 删 Scene 不立即物理删 Asset；AC-005 路径全走配置/环境变量零盘符 |
| 异常 AC | AC-006 文件缺失返回可理解错误；AC-007 存储写失败可恢复 |
| 性能要求 | 流式读写，不整文件进内存 |
| 测试方法 | 单测 + 离线集成（本地存储） |
| 必交证据 | 代码 / 测试结果 / Commit ID |

状态：TODO
