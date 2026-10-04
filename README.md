# 交接区 · Hermes ↔ WorkBuddy 协作协议

## 规则
- WorkBuddy 干完活 → 把报告写进 from_workbuddy.md（覆盖写）+ 响提示音
- Hermes 检测到 from_workbuddy.md 变化 → 测试验真 → 把指令写进 to_workbuddy.md
- WorkBuddy 定时读 to_workbuddy.md，有新指令就执行

## 文件
- from_workbuddy.md = WorkBuddy 的报告（交活）
- to_workbuddy.md = Hermes 的指令（派活）
