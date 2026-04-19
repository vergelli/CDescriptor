# install.ps1
# CDescriptor — Bootstrap del entorno de desarrollo
# Requiere: Windows 11, permisos de administrador, winget disponible
# Uso: .\install.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

function Write-Ok($msg) {
    Write-Host "    OK: $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "    WARN: $msg" -ForegroundColor Yellow
}

function Write-Fail($msg) {
    Write-Host "    FAIL: $msg" -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# 1. Verificar winget
# ---------------------------------------------------------------------------
Write-Step "Verificando winget..."
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Fail "winget no encontrado. Instala App Installer desde la Microsoft Store."
    exit 1
}
Write-Ok "winget disponible."

# ---------------------------------------------------------------------------
# 2. Instalar Lua (DEVCOM.Lua — instala 5.4, compatible con dev toolchain)
# ---------------------------------------------------------------------------
Write-Step "Instalando Lua (DEVCOM.Lua)..."
$luaInstalled = winget list --id DEVCOM.Lua 2>$null | Select-String "DEVCOM.Lua"
if ($luaInstalled) {
    Write-Ok "Lua ya esta instalado, saltando."
} else {
    winget install --id DEVCOM.Lua --silent --accept-package-agreements --accept-source-agreements
    Write-Ok "Lua instalado."
}

# Candidatos de path para Lua — 64-bit primero, luego 32-bit, luego versiones especificas
$luaCandidates = @(
    "$env:ProgramFiles\Lua",
    "$env:ProgramFiles\Lua\5.4",
    "$env:ProgramFiles\Lua\5.1",
    "${env:ProgramFiles(x86)}\Lua",
    "${env:ProgramFiles(x86)}\Lua\5.1",
    "$env:LOCALAPPDATA\Programs\Lua",
    "$env:LOCALAPPDATA\Programs\Lua\5.4",
    "$env:LOCALAPPDATA\Programs\Lua\5.1"
)
$luaPath = $luaCandidates | Where-Object { Test-Path "$_\lua.exe" } | Select-Object -First 1

if (-not $luaPath) {
    # Busqueda de emergencia en Program Files
    $found = Get-ChildItem "$env:ProgramFiles" -Recurse -Filter "lua.exe" -ErrorAction SilentlyContinue |
             Select-Object -First 1
    if ($found) { $luaPath = $found.DirectoryName }
}

if (-not $luaPath) {
    Write-Warn "No se pudo detectar el path de Lua automaticamente."
    Write-Warn "Busca lua.exe manualmente y agregalo al PATH de usuario."
} else {
    Write-Ok "Lua encontrado en: $luaPath"
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$luaPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$luaPath", "User")
        Write-Ok "Agregado al PATH de usuario: $luaPath"
    } else {
        Write-Ok "Ya estaba en el PATH."
    }
}

# ---------------------------------------------------------------------------
# 3. Instalar LuaRocks
# ---------------------------------------------------------------------------
Write-Step "Instalando LuaRocks (LuaRocks.LuaRocks)..."
$rocksInstalled = winget list --id LuaRocks.LuaRocks 2>$null | Select-String "LuaRocks"
if ($rocksInstalled) {
    Write-Ok "LuaRocks ya esta instalado, saltando."
} else {
    winget install --id LuaRocks.LuaRocks --silent --accept-package-agreements --accept-source-agreements
    Write-Ok "LuaRocks instalado."
}

# Candidatos de path para LuaRocks — 64-bit primero
$rocksCandidates = @(
    "$env:ProgramFiles\LuaRocks",
    "${env:ProgramFiles(x86)}\LuaRocks",
    "$env:LOCALAPPDATA\Programs\LuaRocks"
)
$rocksPath = $rocksCandidates | Where-Object { Test-Path "$_\luarocks.bat" } | Select-Object -First 1

if (-not $rocksPath) {
    $found = Get-ChildItem "$env:ProgramFiles" -Recurse -Filter "luarocks.bat" -ErrorAction SilentlyContinue |
             Select-Object -First 1
    if ($found) { $rocksPath = $found.DirectoryName }
}

if (-not $rocksPath) {
    Write-Warn "No se pudo detectar el path de LuaRocks automaticamente."
    Write-Warn "Busca luarocks.bat manualmente y agregalo al PATH de usuario."
} else {
    Write-Ok "LuaRocks encontrado en: $rocksPath"
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$rocksPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$rocksPath", "User")
        Write-Ok "Agregado al PATH de usuario: $rocksPath"
    } else {
        Write-Ok "Ya estaba en el PATH."
    }
}

# ---------------------------------------------------------------------------
# 4. Agregar bin dir de paquetes LuaRocks al PATH
# ---------------------------------------------------------------------------
# Los paquetes instalados por `luarocks install` van a %APPDATA%\luarocks\bin,
# que es distinto del path de LuaRocks en si. Hay que agregarlo explicitamente.
Write-Step "Configurando PATH y LUA_PATH del bin dir de LuaRocks..."

$luarocksBin = "$env:APPDATA\luarocks\bin"
if (-not (Test-Path $luarocksBin)) {
    New-Item -ItemType Directory -Path $luarocksBin -Force | Out-Null
}
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$luarocksBin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$luarocksBin", "User")
    Write-Ok "Agregado al PATH de usuario: $luarocksBin"
} else {
    Write-Ok "Ya estaba en el PATH: $luarocksBin"
}

# LUA_PATH y LUA_CPATH: necesarios para que lua.exe encuentre los modulos
# instalados por luarocks (busted, luacheck, etc.)
$lrPath  = (luarocks path --lr-path  2>$null)
$lrCPath = (luarocks path --lr-cpath 2>$null)
if ($lrPath) {
    [Environment]::SetEnvironmentVariable("LUA_PATH",  $lrPath,  "User")
    [Environment]::SetEnvironmentVariable("LUA_CPATH", $lrCPath, "User")
    Write-Ok "LUA_PATH y LUA_CPATH configurados para el arbol de LuaRocks"
}

# ---------------------------------------------------------------------------
# 5. Refrescar PATH en la sesion actual
# ---------------------------------------------------------------------------
Write-Step "Refrescando PATH en la sesion actual..."
$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("PATH", "User")
Write-Ok "PATH refrescado."

# ---------------------------------------------------------------------------
# 6. Instalar busted y luacheck directamente
# ---------------------------------------------------------------------------
Write-Step "Instalando busted y luacheck via LuaRocks..."

try {
    luarocks install busted
    Write-Ok "busted instalado."
} catch {
    Write-Warn "Fallo instalando busted: $_"
}

try {
    luarocks install luacheck
    Write-Ok "luacheck instalado."
} catch {
    Write-Warn "Fallo instalando luacheck: $_"
}

# ---------------------------------------------------------------------------
# 6. Verificacion final
# ---------------------------------------------------------------------------
Write-Step "Verificacion final del entorno..."

$checks = @(
    @{ cmd = "lua";      args = "-v";        label = "Lua" },
    @{ cmd = "luarocks"; args = "--version"; label = "LuaRocks" },
    @{ cmd = "busted";   args = "--version"; label = "busted" },
    @{ cmd = "luacheck"; args = "--version"; label = "luacheck" },
    @{ cmd = "make";     args = "--version"; label = "GNU Make" }
)

$allOk = $true
foreach ($check in $checks) {
    try {
        $result = & $check.cmd $check.args 2>&1 | Select-Object -First 1
        Write-Ok "$($check.label): $result"
    } catch {
        Write-Fail "$($check.label): no encontrado en PATH."
        $allOk = $false
    }
}

Write-Host ""
if ($allOk) {
    Write-Host "Entorno listo. Podes correr 'make test' para verificar." -ForegroundColor Green
} else {
    Write-Host "Algunas herramientas no se encontraron en PATH." -ForegroundColor Yellow
    Write-Host "Abre una nueva terminal e intenta de nuevo. Si persiste, agrega los paths manualmente." -ForegroundColor Yellow
}
