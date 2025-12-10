@echo off
REM Перейти в директорию батника
cd /d "%~dp0"

REM Проверить, что git доступен
git --version >nul 2>&1
if errorlevel 1 (
  echo Git не найден в PATH. Установите Git или добавьте его в PATH.
  exit /b 1
)

REM Добавляем все изменения в индекс
git add .

REM Создаём tree-объект из текущего индекса
for /f "delims=" %%T in ('git write-tree') do set TREE=%%T
if "%TREE%"=="" (
  echo Не удалось получить tree из индекса.
  exit /b 1
)

REM Создаём новый коммит на основе tree (без родителей) с сообщением "upd"
for /f "delims=" %%C in ('git commit-tree %TREE% -m "upd"') do set NEWCOMMIT=%%C
if "%NEWCOMMIT%"=="" (
  echo Не удалось создать коммит через git commit-tree.
  exit /b 1
)

echo Создан коммит: %NEWCOMMIT%

REM Мягкий сброс на созданный коммит (оставляет staged changes)
git reset --soft %NEWCOMMIT%

REM Форсированный пуш в текущую ветку удалённого репозитория
git push -f

echo Готово.
