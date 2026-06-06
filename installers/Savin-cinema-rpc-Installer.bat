@echo off
cls
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ((Get-Content '%~f0' | Select-Object -Skip 4) -join [Environment]::NewLine)"
exit /b

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    Instalador Oficial Windows: Savin-cinema-rpc  " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Validar presencia de Python 3
try {
    $pyCheck = python --version 2>$null
    Write-Host "✅ Python detectado correctamente en el sistema." -ForegroundColor Green
} catch {
    Write-Host "❌ Error: No se ha detectado Python en el PATH de Windows." -ForegroundColor Red
    Write-Host "Por favor, descarga Python 3 de la web oficial e instálalo." -ForegroundColor Yellow
    Write-Host "Asegúrate de marcar la casilla 'Add Python to PATH' en el instalador." -ForegroundColor LightYellow
    Write-Host ""
    Read-Host "Presiona Enter para salir..."
    exit
}
Write-Host ""

# 2. Preguntar de forma interactiva por la ubicación de MPV
Write-Host "[1/3] 📂 Configuración del directorio de MPV:" -ForegroundColor Yellow
Write-Host "1. Usar ubicación por defecto (%APPDATA%\mpv)"
Write-Host "2. Usar una carpeta o ruta específica personalizada"
Write-Host ""
$opt = Read-Host "Elige una opción (1 o 2)"

if ($opt -eq "2") {
    Write-Host ""
    $customPath = Read-Host "Introduce la ruta absoluta de tu carpeta MPV (Ej: C:\Herramientas\mpv)"
    $mpvDir = $customPath.Replace('"', '').Trim()
} else {
    $mpvDir = "$env:APPDATA\mpv"
}

# Asegurar la existencia de la carpeta destino
if (-not (Test-Path $mpvDir)) {
    New-Item -ItemType Directory -Path $mpvDir -Force | Out-Null
    Write-Host "📂 Carpeta creada automáticamente: $mpvDir" -ForegroundColor Gray
} else {
    Write-Host "✅ Carpeta de MPV confirmada: $mpvDir" -ForegroundColor Green
}
Write-Host ""

# 3. Preguntar por Client ID
Write-Host "[2/3] 🆔 Configuración de Discord Application ID..." -ForegroundColor Yellow
$defaultId = "1512598323725602878"
Write-Host "Introduce tu CLIENT_ID personalizado si tienes uno."
$userId = Read-Host "O presiona [ENTER] para usar el ID por defecto ($defaultId)"

if ([string]::IsNullOrWhiteSpace($userId)) {
    $finalId = $defaultId
} else {
    $finalId = $userId.Trim()
}
Write-Host "➡ Aplicado ID: $finalId" -ForegroundColor Green
Write-Host ""

# 4. Instalar librerías de Python
Write-Host "[3/3] 📦 Instalando dependencias de Python (pypresence, requests)..." -ForegroundColor Yellow
python -m pip install --upgrade pip --quiet
python -m pip install requests pypresence --quiet
Write-Host "✅ Dependencias de Python listas." -ForegroundColor Green
Write-Host ""

# Preparar las rutas de los scripts
$scriptPath = Join-Path $mpvDir "savin_cinema_rpc.py"
$escapedScriptPath = $scriptPath.Replace('\', '\\')
$luaScriptsFolder = Join-Path $mpvDir "scripts"

if (-not (Test-Path $luaScriptsFolder)) {
    New-Item -ItemType Directory -Path $luaScriptsFolder -Force | Out-Null
}
$luaPath = Join-Path $luaScriptsFolder "discord_launcher.lua"

# 5. Escribir el Script de Python optimizado con tuberías Win32 nativas (ctypes)
Write-Host "🐍 Generando script de control de Windows (savin_cinema_rpc.py)..." -ForegroundColor Magenta
$pythonCode = @"
import os
import sys
import json
import time
import re
import requests
import ctypes
from pypresence import Presence

# Evitar fallos de entrada/salida si corre bajo pythonw sin consola
if sys.stdout is None:
    class DummyWriter:
        def write(self, *args, **kwargs): pass
        def flush(self): pass
    sys.stdout = DummyWriter()
    sys.stderr = DummyWriter()

CLIENT_ID = '$finalId'
PIPE_PATH = r'\\.\pipe\mpvsocket'
TMDB_API_KEY = 'cd8015c4e4de965057e0282c9d19610f'

debug_tmdb_url = "Ninguna petición realizada"
debug_tmdb_status = "Esperando reproducción..."
debug_discord_payload = {}

def clean_filename(filename):
    if not filename: return ""
    name, _ = os.path.splitext(filename)
    name = re.sub(r'\[.*?\]', '', name)
    name = re.sub(r'\(.*?\)', '', name)
    tags = ['1080p', '720p', '4k', '2160p', 'bluray', 'bdrip', 'brrip', 'h264', 'x264', 'x265', 'h265', 'hevc', 'web-dl', 'webdl', 'dvdrip', 'screener', 'aac', 'ac3', 'mp3', 'dual', 'hdr', 'remux', 'atmos', 'dts']
    for tag in tags: name = re.sub(r'(?i)\b' + tag + r'\b', '', name)
    name = name.replace('.', ' ').replace('_', ' ').replace('-', ' ')
    return re.sub(r'\s+', ' ', name).strip('. -_')

def get_movie_data(title):
    global debug_tmdb_url, debug_tmdb_status
    clean_title = clean_filename(title)
    if not clean_title:
        debug_tmdb_status = "Cancelado: Vacío"
        return title, "mpv-icon"
    url_es = f"https://api.themoviedb.org/3/search/movie?api_key={TMDB_API_KEY}&query={requests.utils.quote(clean_title)}&language=es-ES"
    url_en = f"https://api.themoviedb.org/3/search/movie?api_key={TMDB_API_KEY}&query={requests.utils.quote(clean_title)}&language=en-US"
    debug_tmdb_url = url_es
    for url in [url_es, url_en]:
        try:
            response = requests.get(url, timeout=4)
            debug_tmdb_status = f"HTTP {response.status_code}"
            if response.status_code != 200: continue
            results = response.json().get('results', [])
            if results:
                match = results[0]
                titulo_real = match.get('title', clean_title)
                fecha = match.get('release_date', '')
                titulo_final = f"{titulo_real} ({fecha.split('-')[0]})" if fecha else titulo_real
                poster = f"https://image.tmdb.org/t/p/w500{match.get('poster_path')}" if match.get('poster_path') else "mpv-icon"
                debug_tmdb_status = f"HTTP 200 OK (¡Encontrada!: {titulo_final})"
                return titulo_final, poster
        except Exception as e:
            debug_tmdb_status = f"Error: {str(e)}"
    return clean_title, "mpv-icon"

def send_mpv_command(cmd_name, *args):
    try:
        GENERIC_READ = 0x80000000
        GENERIC_WRITE = 0x40000000
        OPEN_EXISTING = 3
        
        handle = ctypes.windll.kernel32.CreateFileW(
            PIPE_PATH, GENERIC_READ | GENERIC_WRITE, 0, None, OPEN_EXISTING, 0, None
        )
        if handle == -1: return None
        
        message = {"command": [cmd_name] + list(args)}
        data = (json.dumps(message) + "\n").encode('utf-8')
        
        written = ctypes.c_ulong(0)
        ctypes.windll.kernel32.WriteFile(handle, data, len(data), ctypes.byref(written), None)
        
        response = b""
        read_bytes = ctypes.c_ulong(0)
        char_buf = ctypes.create_string_buffer(1)
        
        while True:
            res = ctypes.windll.kernel32.ReadFile(handle, char_buf, 1, ctypes.byref(read_bytes), None)
            if not res or read_bytes.value == 0: break
            response += char_buf.raw[:read_bytes.value]
            if response.endswith(b'\n'): break
            
        ctypes.windll.kernel32.CloseHandle(handle)
        return json.loads(response.decode('utf-8')).get("data")
    except: return None

def main():
    global debug_discord_payload, debug_tmdb_url, debug_tmdb_status
    try:
        RPC = Presence(CLIENT_ID)
        RPC.connect()
    except: return
    last_filename = ""
    display_title, imagen_caratula = "", "mpv-icon"
    while True:
        filename = send_mpv_command("get_property", "filename")
        if filename:
            paused = send_mpv_command("get_property", "pause")
            time_pos = send_mpv_command("get_property", "time-pos")
            duration = send_mpv_command("get_property", "duration")
            if filename != last_filename:
                display_title, imagen_caratula = get_movie_data(filename)
                last_filename = filename
            try:
                t_actual = int(float(time_pos)) if time_pos is not None else 0
                t_total = int(float(duration)) if duration is not None else 0
            except: t_actual, t_total = 0, 0
            state_str = "Pausado" if paused else "Reproduciendo"
            progreso_actual = time.strftime('%H:%M:%S', time.gmtime(t_actual)) if t_actual >= 3600 else time.strftime('%M:%S', time.gmtime(t_actual))
            progreso_total = time.strftime('%H:%M:%S', time.gmtime(t_total)) if t_total >= 3600 else time.strftime('%M:%S', time.gmtime(t_total))
            linea_estado_discord = f"{state_str} | {progreso_actual} / {progreso_total}"
            payload = {"details": display_title, "state": linea_estado_discord, "large_image": imagen_caratula, "large_text": "mpv media player"}
            debug_discord_payload = payload
            try:
                RPC.update(**payload)
            except: pass
        else:
            try:
                RPC.clear()
                last_filename = ""
            except: pass
        time.sleep(2)

if __name__ == "__main__":
    main()
"@
Set-Content -Path $scriptPath -Value $pythonCode -Encoding UTF8

# 6. Escribir lanzador Lua inyectando la ruta absoluta y llamando a pythonw
Write-Host "🌙 Creando disparador en segundo plano (discord_launcher.lua)..." -ForegroundColor Magenta
$luaCode = @"
-- Disparador optimizado para Windows (Savin-cinema-rpc)
mp.msg.info("Iniciando puente de Discord Rich Presence...")

mp.command_native_async({
    name = "subprocess",
    args = {"pythonw", "$escapedScriptPath"},
    playback_only = false
})
"@
Set-Content -Path $luaPath -Value $luaCode -Encoding UTF8

# 7. Forzar la directiva Named Pipe en el mpv.conf de esa carpeta
Write-Host "🛠️ Añadiendo servidor Pipe IPC a tu mpv.conf..." -ForegroundColor Magenta
$confPath = Join-Path $mpvDir "mpv.conf"
if (-not (Test-Path $confPath)) {
    New-Item -ItemType File -Path $confPath -Force | Out-Null
}
$confContent = Get-Content $confPath -Raw
if ($confContent -notmatch "input-ipc-server=\\\\.\\\\pipe\\\\mpvsocket") {
    Add-Content $confPath "`ninput-ipc-server=\\.\pipe\mpvsocket"
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 🎉 ¡Savin-cinema-rpc configurado en Windows!     " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "Presiona cualquier tecla para cerrar el instalador..."