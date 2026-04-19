.PHONY: install test lint help

help:
	@powershell -NoProfile -Command 'Write-Host ""; Write-Host "CDescriptor - comandos disponibles" -ForegroundColor Cyan; Write-Host ""; Write-Host "  make install" -ForegroundColor Green -NoNewline; Write-Host "   Instala el entorno de desarrollo (Lua, LuaRocks, busted, luacheck)"; Write-Host "  make lint   " -ForegroundColor Green -NoNewline; Write-Host "   Luacheck --std lua51 sobre el codigo del addon"; Write-Host "  make test   " -ForegroundColor Green -NoNewline; Write-Host "   Lint + suite de tests con busted"; Write-Host "  make help   " -ForegroundColor Green -NoNewline; Write-Host "   Muestra este mensaje"; Write-Host ""'

install:
	powershell -ExecutionPolicy Bypass -File install.ps1

lint:
	powershell -NoProfile -Command '$$env:LUA_PATH = (luarocks path --lr-path); $$env:LUA_CPATH = (luarocks path --lr-cpath); luacheck adapters/ pipeline/ core/ ui/ --std lua51'

test: lint
	powershell -NoProfile -Command '$$env:LUA_PATH = (luarocks path --lr-path); $$env:LUA_CPATH = (luarocks path --lr-cpath); busted spec/'
