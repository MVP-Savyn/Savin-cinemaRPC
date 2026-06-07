# ===========================================================================
#  Instalador Windows PowerShell: Savin-cinema-rpc v3.5 (Interactivo + Safe-Paths)
# ===========================================================================
$OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

Write-Host "==================================================" -ForegroundColor Blue
Write-Host "    Instalador Windows: Savin-cinema-rpc v3.5     " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Blue
Write-Host ""

# 1. Detectar entorno de Python
Write-Host "[1/6] [BUSQUEDA] Buscando entorno de Python..." -ForegroundColor Yellow
$RealPython = python -c "import sys; print(sys.executable)" 2>$null

if (-not $RealPython) {
    Write-Host "[ERROR] Python 3 no esta instalado o no se encuentra en el PATH." -ForegroundColor Red
    Read-Host "Presiona Enter para salir..."
    exit
}
Write-Host "[OK] Python detectado en: $RealPython" -ForegroundColor Green
Write-Host ""

# 2. Configurar ID de Aplicacion
Write-Host "[2/6] [CONFIG] Configurando Discord Application ID..." -ForegroundColor Yellow
$DefaultClientID = "1512598323725602878"
Write-Host "Introduce tu CLIENT_ID personalizado si tienes uno."
Write-Host "O presiona [ENTER] para usar el ID por defecto ($DefaultClientID):"
$UserInputID = Read-Host ">>> "
$FinalClientID = if ([string]::IsNullOrWhiteSpace($UserInputID)) { $DefaultClientID } else { $UserInputID.Trim() }
Write-Host "-> ID Aplicado: $FinalClientID" -ForegroundColor Green
Write-Host ""

# 3. Configurar Boton de TMDB
Write-Host "[3/6] [CONFIG] ¿Quieres mostrar el boton 'Ver informacion' (TMDB)? (S/N):" -ForegroundColor Yellow
$PromptInfo = Read-Host ">>> "
$IncludeInfo = if ($PromptInfo -match "n|N") { "False" } else { "True" }
Write-Host "-> Boton TMDB: $IncludeInfo" -ForegroundColor Green
Write-Host ""

# 4. Configurar Boton de GitHub
Write-Host "[4/6] [CONFIG] ¿Quieres mostrar el boton del proyecto 'Savin-CinemaRPC'? (S/N):" -ForegroundColor Yellow
$PromptGH = Read-Host ">>> "
$IncludeGH = if ($PromptGH -match "n|N") { "False" } else { "True" }
Write-Host "-> Boton GitHub: $IncludeGH" -ForegroundColor Green
Write-Host ""

# 5. Instalar Dependencias
Write-Host "[5/6] [DEPS] Instalando dependencias (pypresence, requests)..." -ForegroundColor Yellow
& $RealPython -m pip install --upgrade pip --quiet
& $RealPython -m pip install requests pypresence --quiet
Write-Host "[OK] Dependencias listas." -ForegroundColor Green
Write-Host ""

# Asegurar directorios de MPV
$MpvAppData = "$env:APPDATA\mpv"
$MpvScripts = "$MpvAppData\scripts"
if (-not (Test-Path $MpvScripts)) {
    New-Item -ItemType Directory -Path $MpvScripts -Force | Out-Null
}

# 6. Escribir archivos de control
Write-Host "[6/6] [CORE] Desplegando nucleo de Python y disparador Lua..." -ForegroundColor Yellow

$PythonCode = @'
import os
import socket
import json
import time
import re
import requests
import sys
from pypresence import Presence

CLIENT_ID = 'SAVIN_DYNAMIC_CLIENT_ID'
GITHUB_URL = 'https://mvp-savyn.github.io/Savin-cinemaRPC/'
INCLUDE_INFO = SAVIN_DYNAMIC_INCLUDE_INFO
INCLUDE_GITHUB = SAVIN_DYNAMIC_INCLUDE_GITHUB
SOCKET_PATH = r'\\.\pipe\mpvsocket'
TMDB_API_KEY = 'cd8015c4e4de965057e0282c9d19610f'

RAW_CLEAN_TAGS = ['1080p', '720p', '4k', '2160p', 'bluray', 'bdrip', 'brrip', 'h264', 'x264', 'x265', 'h265', 'hevc', 'web-dl', 'webdl', 'dvdrip', 'screener', 'aac', 'ac3', 'mp3', 'dual', 'hdr', 'remux', 'atmos', 'dts']
_pipe_file = None

def clean_filename_generic(filename):
    if not filename: return ""
    name, _ = os.path.splitext(filename)
    name = re.sub(r'\[.*?\]', '', name)
    name = re.sub(r'\(.*?\)', '', name)
    for tag in RAW_CLEAN_TAGS: 
        name = re.sub(r'(?i)\b' + tag + r'\b', '', name)
    name = name.replace('.', ' ').replace('_', ' ').replace('-', ' ')
    return re.sub(r'\s+', ' ', name).strip('. -_')

def parse_media_type(filename):
    if not filename: return None, None, None
    name_no_ext, _ = os.path.splitext(filename)
    pattern = re.compile(r'(?i)(.*?)[ ._\[\-](?:[Ss](\d+)[Ee](\d+)|(\d+)x(\d+))')
    match = pattern.search(name_no_ext)
    if match:
        raw_title = match.group(1)
        if match.group(2): s_num, e_num = match.group(2), match.group(3)
        else: s_num, e_num = match.group(4), match.group(5)
        clean_title = clean_filename_generic(raw_title)
        return clean_title, f"Temporada {int(s_num)} - Episodio {int(e_num)}", "tv"
    return clean_filename_generic(filename), None, "movie"

def get_media_data(filename):
    clean_title, ep_info, media_type = parse_media_type(filename)
    if not clean_title: return filename, None, "mpv-icon", None
    if media_type == "tv":
        search_endpoint = "search/tv"
        view_url_base = "tv"
    else:
        search_endpoint = "search/movie"
        view_url_base = "movie"
        
    url_es = f"https://api.themoviedb.org/3/{search_endpoint}?api_key={TMDB_API_KEY}&query={requests.utils.quote(clean_title)}&language=es-ES"
    url_en = f"https://api.themoviedb.org/3/{search_endpoint}?api_key={TMDB_API_KEY}&query={requests.utils.quote(clean_title)}&language=en-US"
    
    for url in [url_es, url_en]:
        try:
            response = requests.get(url, timeout=4)
            if response.status_code != 200: continue
            results = response.json().get('results', [])
            if results:
                match = results[0]
                titulo_real = match.get('name') if media_type == "tv" else match.get('title', clean_title)
                fecha = match.get('first_air_date') if media_type == "tv" else match.get('release_date', '')
                fecha_year = fecha.split('-')[0] if fecha else ""
                titulo_final = f"{titulo_real} ({fecha_year})" if fecha_year else titulo_real
                poster = f"https://image.tmdb.org/t/p/w500{match.get('poster_path')}" if match.get('poster_path') else "mpv-icon"
                movie_id = match.get('id')
                tmdb_url = f"https://www.themoviedb.org/{view_url_base}/{movie_id}" if movie_id else None
                return titulo_final, ep_info, poster, tmdb_url
        except: pass
    return clean_title, ep_info, "mpv-icon", None

def send_mpv_command(cmd_name, *args):
    global _pipe_file
    try:
        if _pipe_file is None:
            _pipe_file = open(SOCKET_PATH, 'r+b')
        message = {"command": [cmd_name] + list(args)}
        _pipe_file.write(json.dumps(message).encode('utf-8') + b'\n')
        _pipe_file.flush()
        response = _pipe_file.readline().decode('utf-8')
        if not response: raise Exception("Pipe closed")
        return json.loads(response).get("data")
    except:
        if _pipe_file:
            try: _pipe_file.close()
            except: pass
            _pipe_file = None
        return "__SOCKET_DEAD__"

def generate_progress_bar(current, total, length=6):
    if total <= 0: return "\U0001F518" + "\u25AC" * (length - 1)
    percent = max(0.0, min(1.0, current / total))
    filled_length = int(round(length * percent))
    if filled_length >= length: filled_length = length - 1
    return "\u25AC" * filled_length + "\U0001F518" + "\u25AC" * (length - filled_length - 1)

def main():
    try:
        RPC = Presence(CLIENT_ID)
        RPC.connect()
    except: return
    
    last_state, last_filename, last_toggle_time, last_update_time = None, "", 0, 0
    display_title, ep_info, imagen_caratula, movie_url = "", None, "mpv-icon", None
    consecutive_failures = 0
    
    while True:
        res = send_mpv_command("get_property", "filename")
        if res == "__SOCKET_DEAD__":
            consecutive_failures += 1
            if consecutive_failures >= 5:
                try:
                    RPC.clear()
                    RPC.close()
                except: pass
                sys.exit(0)
            time.sleep(1)
            continue
            
        consecutive_failures = 0
        filename = res
        if filename:
            paused = send_mpv_command("get_property", "pause")
            time_pos = send_mpv_command("get_property", "time-pos")
            duration = send_mpv_command("get_property", "duration")
            
            if "__SOCKET_DEAD__" in [paused, time_pos, duration]:
                time.sleep(1)
                continue
                
            try:
                t_actual = int(float(time_pos)) if time_pos is not None else 0
                t_total = int(float(duration)) if duration is not None else 0
            except: t_actual, t_total = 0, 0
            
            current_state = 'paused' if paused else 'playing'
            now = time.time()
            
            if filename != last_filename:
                display_title, ep_info, imagen_caratula, movie_url = get_media_data(filename)
                last_filename = filename

            progreso_actual = time.strftime('%H:%M:%S', time.gmtime(t_actual)) if t_actual >= 3600 else time.strftime('%M:%S', time.gmtime(t_actual))
            progreso_total = time.strftime('%H:%M:%S', time.gmtime(t_total)) if t_total >= 3600 else time.strftime('%M:%S', time.gmtime(t_total))
            barras_visuales = generate_progress_bar(t_actual, t_total)
            
            payload = {"details": display_title, "large_image": imagen_caratula, "large_text": "mpv media player"}
            
            if ep_info:
                prefix_status = "\U0001F4FA "
                time_status = f"{ep_info} | {progreso_actual} {barras_visuales} {progreso_total}"
            else:
                prefix_status = ""
                time_status = f"{progreso_actual} {barras_visuales} {progreso_total}"

            if current_state == 'paused':
                payload["state"] = f"\u23F8\uFE0F {prefix_status}{time_status}"
            else:
                payload["state"] = f"\u25B6 {prefix_status}{time_status}"
            
            buttons_list = []
            if INCLUDE_INFO and movie_url:
                buttons_list.append({"label": "Ver informaci\u00f3n", "url": movie_url})
            if INCLUDE_GITHUB:
                buttons_list.append({"label": "Savin-CinemaRPC", "url": GITHUB_URL})
            if buttons_list:
                payload["buttons"] = buttons_list
            
            state_changed = (current_state != last_state)
            time_to_update = (now - last_update_time >= 10.0)
            
            can_send = False
            if state_changed:
                if now - last_toggle_time >= 3.0: can_send = True
                last_toggle_time = now
            elif current_state == 'playing' and time_to_update:
                can_send = True

            if can_send:
                try:
                    RPC.update(**payload)
                    last_state = current_state
                    last_update_time = now
                    print("\033[H\033[J", end="")
                    print("=" * 75)
                    print(" \U0001F3AC   MPV DISCORD RICH PRESENCE - WINDOWS PIPES LAYOUT v3.5 \U0001F3AC")
                    print("=" * 75)
                    print(f" \U0001F3A5 Medio:          '{display_title}'")
                    if ep_info: print(f" \U0001F4FA Info Serie:      {ep_info}")
                    print(f" \u2699\ufe0f  Estado RPC:      {payload['state']}")
                    print("=" * 75)
                except: pass
        else:
            if last_state != 'idle':
                try:
                    RPC.clear()
                    last_state = 'idle'
                    last_filename = ""
                    movie_url = None
                    ep_info = None
                except: pass
        time.sleep(1)

if __name__ == "__main__":
    main()
'@

# Inyeccion dinamica de variables
$PythonCode = $PythonCode.Replace('SAVIN_DYNAMIC_CLIENT_ID', $FinalClientID)
$PythonCode = $PythonCode.Replace('SAVIN_DYNAMIC_INCLUDE_INFO', $IncludeInfo)
$PythonCode = $PythonCode.Replace('SAVIN_DYNAMIC_INCLUDE_GITHUB', $IncludeGH)

$PythonFile = "$MpvAppData\savin_cinema_rpc.py"
[System.IO.File]::WriteAllText($PythonFile, $PythonCode, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Script de Python estructurado correctamente." -ForegroundColor Green

# Disparador LUA con soporte de corchetes literales [[ ]] para evitar fallos de escape de rutas en Windows
$LuaCode = @"
-- Disparador definitivo para Windows (Safe-Paths Leyout)
mp.msg.info("Iniciando puente de Discord Rich Presence v3.5...")
mp.command_native_async({
    name = "subprocess",
    args = {[[$RealPython]], [[$MpvAppData\savin_cinema_rpc.py]]},
    playback_only = false
})
"@
[System.IO.File]::WriteAllText("$MpvScripts\discord_launcher.lua", $LuaCode, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Disparador Lua blindado e inyectado." -ForegroundColor Green

# Asegurar configuracion IPC en mpv.conf
$MpvConf = "$MpvAppData\mpv.conf"
if (-not (Test-Path $MpvConf)) { New-Item -ItemType File -Path $MpvConf -Force | Out-Null }
$ConfContent = Get-Content $MpvConf
if ($ConfContent -notcontains "input-ipc-server=mpvsocket") {
    Add-Content -Path $MpvConf -Value "input-ipc-server=mpvsocket"
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Blue
Write-Host "  Savin-CinemaRPC v3.5 configurado y listo!       " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Blue
Read-Host "Presiona cualquier tecla para finalizar..."