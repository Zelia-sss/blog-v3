@echo off
chcp 65001 >nul
rem 自动探测 blog-v3 位置（脚本自身所在目录 / C:\Blog / D:\Blog / 桌面\Blog / 桌面直接）
set "BASE=%~dp0"
if "%BASE:~-1%"=="\" set "BASE=%BASE:~0,-1%"
if not exist "%BASE%\.git" set "BASE=C:\Blog\blog-v3"
if not exist "%BASE%\.git" set "BASE=D:\Blog\blog-v3"
if not exist "%BASE%\.git" set "BASE=%USERPROFILE%\Desktop\Blog\blog-v3"
if not exist "%BASE%\.git" set "BASE=%USERPROFILE%\Desktop\blog-v3"
if not exist "%BASE%\.git" (
    echo 找不到 blog-v3 仓库！请确认位置后手动 cd 进去再运行。
    pause
    exit /b 1
)
cd /d "%BASE%"
echo 使用目录: %BASE%
echo [1/3] 添加改动...
git add -A
echo [2/3] 提交...
git commit -m "post: 更新文章 %date% %time%"
if errorlevel 1 (
    echo 没有新改动，无需提交。
    goto :push
)
:push
echo [3/3] 推送到 GitHub，EdgeOne 将自动部署...
git push origin main
if errorlevel 1 (
    echo.
    echo 推送失败！请检查网络或凭证（GitHub 不通时可开 Watt Toolkit 加速后再试）。
    pause
    exit /b 1
)
echo.
echo 发布成功！1~3 分钟后 zelia.top 更新。
pause
