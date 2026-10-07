# REPORT-DEV-C-PROVIDER-2026-10-06

> DEV-C（算力机）· 四大能力 Provider 类骨架交付报告
> 派工单：to_workbuddy_dev-c.md（任务：四大能力 Provider 类骨架）
> 关联：P0 四大 Spike 全部 FEASIBLE-LOCAL（VOICE / IMAGE / VIDEO / DIGITAL-HUMAN）

---

## 0. 机器标识块（Machine Identity Block）

| 项 | 值 |
| --- | --- |
| 机器角色 | DEV-C（算力机 / Spike 验证机，不写生产业务逻辑） |
| GPU | NVIDIA RTX 5070 12GB（Blackwell，compute capability **sm_120**） |
| CUDA 运行时 | 12.8 |
| PyTorch 基线 | **2.7.0+cu128**（低于此版本缺 sm_120 内核，Spike 已验证） |
| OS / Python | Windows 11 / Python 3.11 & 3.13 |
| 本地提交时间 | 2026-10-07 |
| 代码 commit（本地） | `6c3e328` |

---

## 1. 交付摘要

按派工单，将 P0 四大 Spike 的验证成果固化为 **四大能力 Provider 类骨架**（生产代码准备，非设计文档）：

- 在 `backend/src/rpb/providers/` 新增 `BaseProvider` + 四大 Provider 骨架；
- 接口方法签名 `health() / submit() / status()` **对齐 `contracts/`** 的 `JobState` 八态与 `ErrorInfo{code,message,retryable}` 错误码；
- 输入/输出 asset 类型**引用 `contracts/asset_contract.py` 的 `AssetType`**；
- 本地默认参数取自 **P0 四大 Spike 实测值**（非估算）；
- 预留**云端兜底接口位**（显存超限转云端），不实现云侧逻辑；
- **只立骨架 + 关键参数，不写完整业务逻辑**（存储解析、引擎 payload 构造、云侧提交均为明确 TODO slot）。

交付物：6 个新文件，456 行（已 `git commit`，本地 `feature/dev-c` @ `6c3e328`）。

---

## 2. 代码落点 / 分支 / commit

| 仓 | 路径 | 分支 | commit（本地） | 远端状态 |
| --- | --- | --- | --- | --- |
| 真人IP工作台2.0 | `backend/src/rpb/providers/*.py` | `feature/dev-c`（track `origin/develop`） | `6c3e328` | ⏳ 待 push（GitHub 500 阻塞，见 §9） |
| handoff | `REPORT-DEV-C-PROVIDER-2026-10-06.md` | `feature/dev-c`（track `origin/main`） | 本报告提交后生成 | ⏳ 待 push |

> 两仓均**从未建 `feature/dev-c`**，本次从 `origin/develop`（2.0）/ `origin/main`（handoff）新切。

---

## 3. 四大 Provider 骨架清单

| 文件 | 类 | capability | 输入 AssetType | 输出 AssetType | 本地引擎 / 实测峰值 |
| --- | --- | --- | --- | --- | --- |
| `voice_clone.py` | `VoiceCloneProvider` | `TTS` | `AUDIO` (RAW) | `AUDIO` | CosyVoice2-0.5B / ~3.7GB |
| `image_gen.py` | `ImageGenProvider` | `IMAGE` | （无，prompt 驱动） | `IMAGE` | SDXL 1.0 fp16 / ~10.7GB |
| `video_gen.py` | `VideoGenProvider` | `RENDER` | `IMAGE`（可选） | `VIDEO` | CogVideoX-2b / ~11.4GB |
| `digital_human.py` | `DigitalHumanProvider` | `LIPSYNC` | `AUDIO` | `VIDEO` | KrLongAI 35005 / ~11.1GB（91%） |

公共基类 `base.py`：`BaseProvider`（抽象）、`ProviderStatus`（对外状态）、引擎四态→契约八态映射、云端兜底 slot。

---

## 4. 契约对齐说明（红线：不增删 Contract 字段）

### 4.1 引擎态 → 契约八态映射（base.py）
引擎层 `EngineAdapter` 只有四态 `succeeded/running/failed/unknown`，映射到对外冻结的 `JobState`：

| 引擎态 | `JobState` |
| --- | --- |
| `succeeded` | `COMPLETED` |
| `running` | `RUNNING` |
| `failed` | `FAILED` |
| `unknown`（引擎消失） | `STALLED`（与 job_contract「Worker 崩后卡住」一致） |

`ProviderStatus.from_engine()` 直接复用该映射；`progress` 取引擎回传**真实值**，绝不写死估算。

### 4.2 错误码结构
`submit()/status()` 失败统一用 `contracts.error_contract.ErrorInfo{code,message,retryable}`：
- 网络/引擎不可达 → `retryable=True`（走 `RETRYING`/`STALLED`）；
- 参数/契约非法 → `retryable=False`（走 `FAILED`）。

### 4.3 输入用 `asset_refs`
`submit(job: JobRequest)` 以 `JobRequest`（含 `asset_refs: list[str]` + `params`）为唯一入参；`asset_refs` 的合法性由 `JobRequest` 构造时按 AC-004/AC-005 校验（路径字符串被拒），**不传文件路径**。

### 4.4 Asset 类型
输入/输出类型全部引用 `contracts.asset_contract.AssetType`（`AUDIO/VIDEO/IMAGE/...`），不自行定义枚举。

---

## 5. 本地默认参数（P0 Spike 实测值，非估算）

| Provider | 关键默认参数（实测） |
| --- | --- |
| VoiceClone | 参考音 **24k wav / <30s**（内核 30s 上限，Spike 用 29s）；`prompt_wav` 须传**文件路径字符串**（非 tensor）；生成器 `torch.cat` 拼接分片；峰值 **3689MB** |
| ImageGen | **1024² / 30 步 / fp16**，原生 `to('cuda')` 可跑；峰值 **10700MB**；Flux.1-dev ~23GB → 12GB 不可行（转云端） |
| VideoGen | 必须 `enable_model_cpu_offload()` + `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`；naive 全驻留 VAE decode 必 OOM（~23.8GiB）；峰值 **11400MB** |
| DigitalHuman | 渲染峰值 **11158MB（约 91%）→ 须独占 GPU**；引擎三死穴：①持久常驻（禁 DETACHED，须 `p.wait()` 保活）②`DIANJIN_KRLONGAI_DATA_ROOT` 显式指定 ③`NO_PROXY` 含 127.0.0.1；注册须 **multipart + `version:new`**；`audio_file` 用内核 `/files/` URL（中文 URL-encode）、`meta_human_name` 带 `.mp4`、`video_file_name` 本机绝对路径、`use_super_resolution=False`、进度 `urlData` 为成片键 |

> 上述约束已同步固化进 `devc-gpu-spike` Skill，供后续 DEV-C 云端任务与 DEV-B 生产接入复用。

---

## 6. 云端兜底接口位

`BaseProvider` 预留统一云端兜底 slot（**仅接口位，不实现云侧逻辑**，属后续云端接入任务）：

- 配置项：`config["cloud_fallback_enabled"]`（默认 `False`）、`config["cloud_provider_id"]`；
- `_should_offload(estimated_vram_mb)`：骨架默认返回 `False`（走本地），TODO 接 `nvidia-smi` 真实空闲显存判断；
- `_submit_to_cloud(job)`：未实现，抛 `NotImplementedError` 并带 `cloud_fallback_enabled / cloud_provider_id` 当前值；
- 各 Provider 的 `_estimate_vram_mb()` 返回 §5 实测峰值，供兜底判定。

触发语义：**本地显存不足 / GPU 被占用（数字人需 91% 独占）→ 转云端同能力 Provider**。

---

## 7. 验证结果（真实，非假绿）

| 验证项 | 命令 / 方法 | 结果 |
| --- | --- | --- |
| 语法 | `python -m py_compile` 全部 6 文件 | ✅ ALL_COMPILE_OK |
| 导入冒烟 | `PYTHONPATH=<repo根>:<backend/src>` + venv 导入 `rpb.providers` | ✅ IMPORT_OK：4 Provider + BaseProvider 全部解析；`contracts` 与 `engines.base` 图正常；引擎态→JobState 映射生效；capability=TTS/IMAGE/RENDER/LIPSYNC 正确 |
| 运行时逻辑 | 存储解析 / 引擎 payload 构造 / 云端提交 | ⏸ 明确 TODO slot（依赖 DEV-B 存储接入与云端任务），未实装，未声称可用 |

---

## 8. 已知缺口 / FINDING（呈 Architecture Review，DEV-C 不自行裁决）

1. **`contracts` 包接入路径（属 DEV-B 地基，D-015 划定）**：`src/rpb` 当前未 import `contracts`。本骨架用 `from contracts...` 绝对导入，导入前置为「仓库根加入 PYTHONPATH 或 `pip install -e ./contracts`」。DEV-C 仅预留 import 位，不擅自改 backend 路径配置。
2. **`asset_refs` → 真实资产解析（TODO/DEV-B）**：`_validate_inputs` 与 `submit` 的存储层解析为占位，待 `StorageProvider` 接入后填实。
3. **`job_id → external_id` 反查（TODO/DEV-B）**：`status()` 当前直接以 `external_id` 查引擎，缺任务映射表（落库/缓存）。
4. **云端逻辑（TODO/DEV-C-cloud）**：`_submit_to_cloud` 未实现。
5. **`JobState` 八态 vs 内部态 gap（FINDING-C1，已在 contracts 注释标注）**：对外契约八态与 `rpb.tasks.states.JobState`（含 PENDING/SUCCEEDED 等内部态）命名不一致，属已知 gap，跨模块对接只认八态；是否统一由 Architecture Review 裁决，DEV-C 不自行改 Contract。

---

## 9. Push 状态（⚠️ 当前阻塞）

- 本地两仓均已切出 `feature/dev-c` 并完成提交（代码 `6c3e328`；报告本报告）。
- **`git push` 至 origin 现被 GitHub 服务端 500（Internal Server Error）阻塞**，两仓（`zhenren-ip-workbench-2.0.git` 与 `ai-course-platform-handoff.git`）均复现，且 `git ls-remote` 正常、既有 `feature/fnd-*` 远端分支存在 → 判定为 **GitHub 账户级 push 写操作临时故障**，非本地问题。
- 已多次重试（含显式 refspec）均失败。代码与报告已落本地，待 GitHub 恢复后执行 push 即达交活条件（代码 push + 报告 push 均到 origin）。
- **交活判定**：代码 push + 报告 push 均到 origin 才算交活。当前两项均未达 origin，故 **交活状态 = 待 push（阻塞于 GitHub 服务端）**，未假绿。

---

## 10. 红线遵守声明

- ✅ 对齐 `contracts/`：未增删任何 Contract 字段（AssetType / JobState / ErrorInfo / JobRequest 原样引用）。
- ✅ 进度真实值：`status()` 的 `progress` 取自引擎回传，未写死估算。
- ✅ 只骨架 + 关键参数：未写完整业务逻辑，存储/引擎/云端均为明确 TODO slot，未声称可运行。
- ✅ 实测参数：所有本地默认参数均来自 P0 四大 Spike 实测，未编造。

---
*报告生成：DEV-C · 2026-10-07 · 代码 commit `6c3e328`（本地，待 push）*
