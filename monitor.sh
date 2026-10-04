#!/usr/bin/env bash
# handoff 哨兵：输出 from_workbuddy.md 的指纹。文件没变→输出不变→Hermes cron 跳过 agent（零消耗）。
F="D:/真人 IP 工作台/handoff/from_workbuddy.md"
if [ -f "$F" ]; then
  md5sum "$F" | cut -d' ' -f1
else
  echo "MISSING"
fi
