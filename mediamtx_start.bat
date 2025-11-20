
@echo off
if not exist mediamtx.exe (
  echo 找不到 mediamtx.exe，請將 mediamtx.exe 放在本資料夾或加入 PATH。
  pause
  exit /b 1
)
if not exist mediamtx.yml (
  echo rtspAddress: :8554>mediamtx.yml
)
mediamtx.exe mediamtx.yml
