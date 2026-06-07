@echo off
CHCP 65001 > NUL
setlocal EnabledDelayedExpansion

title Instalador Oficial: Savin-cinema-rpc v3.3 (Windows)
cls
echo ==================================================
echo     Instalador Oficial: Savin-cinema-rpc v3.3   
echo ==================================================
echo.

:: 1. Detectar el entorno de Python real en Windows
echo [1/8] 🔍 Buscando tu entorno de Python...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Error: No se ha detectado Python en el PATH del sistema.
    echo Por favor, instálalo desde la Microsoft Store o su web oficial
    echo y asegúrate de marcar la opción "Add Python to PATH".
    echo.
    pause
    exit /b
)
echo ✅ Python detectado en el sistema.
echo.

:: 2. Configuración de Discord Application ID
set "FINAL_CLIENT_ID=1512598323725602878"
echo [2/8] 🆔 Configuración de Discord Application ID...
echo Introduce tu CLIENT_ID personalizado si tienes uno.
echo O simplemente presiona [ENTER] para usar el ID por defecto (1512598323725602878):
set /p "USER_INPUT_ID=❯ "
if not "!USER_INPUT_ID!"=="" set "FINAL_CLIENT_ID=!USER_INPUT_ID!"
echo ➡ ID Aplicado: !FINAL_CLIENT_ID!
echo.

:: 3. Selector Opcional del Botón de Información
set "FINAL_INCLUDE_INFO=True"
echo [3/8] 🎬 Configuración del botón 'Ver información'...
echo ¿Deseas mostrar el botón de información de TMDb en Discord?
echo Presiona [ENTER] para Sí (Por defecto) o introduce n para No:
set /p "USER_INPUT_INFO=❯ "
if /i "!USER_INPUT_INFO!"=="n" set "FINAL_INCLUDE_INFO=False"
echo ➡ Botón de Información: !FINAL_INCLUDE_INFO!
echo.

:: 4. Selector Opcional del Botón GitHub
set "FINAL_INCLUDE_GH=True"
echo [4/8] 💻 Configuración del botón de GitHub...
echo ¿Deseas mostrar el botón hacia tu repositorio de GitHub?
echo Presiona [ENTER] para Sí (Por defecto) o introduce n para No:
set /p "USER_INPUT_GH=❯ "
if /i "!USER_INPUT_GH!"=="n" set "FINAL_INCLUDE_GH=False"
echo ➡ Botón de GitHub: !FINAL_INCLUDE_GH!
echo.

:: 5. Asegurar librerías de Python de forma silenciosa
echo [5/8] 📦 Instalando dependencias necesarias (requests, pypresence)...
python -m pip install --upgrade pip --quiet
python -m pip install requests pypresence --quiet
echo ✅ Dependencias listas.
echo.

:: 6. Crear árbol de directorios de MPV en AppData
echo [6/8] 📂 Verificando estructura de directorios de MPV...
if not exist "%APPDATA%\mpv\scripts" mkdir "%APPDATA%\mpv\scripts"
echo ✅ Estructura de directorios OK.
echo.

:: 7. Escribir script de control v3.3 adaptado a Pipes de Windows mediante inyección limpia
echo [7/8] 🐍 Escribiendo script de control (savin_cinema_rpc.py)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$id='!FINAL_CLIENT_ID!'; $info=!FINAL_INCLUDE_INFO!; $gh=!FINAL_INCLUDE_GH!; [void](gc '%~f0' | ? {$_ -like '##PY:*'} | %% { $_ -replace '##PY:','' -replace 'SAVIN_DYNAMIC_CLIENT_ID',$id -replace 'SAVIN_DYNAMIC_INCLUDE_INFO',$info -replace 'SAVIN_DYNAMIC_INCLUDE_GITHUB',$gh } | Out-File -FilePath \"$env:APPDATA\mpv\savin_cinema_rpc.py\" -Encoding utf8)"
echo ✅ Configuración modular inyectada con éxito en el núcleo de Windows.
echo.

:: 8. Generar el disparador .lua asíncrono para Windows (Usa pythonw para ocultar la consola)
echo [8/8] 🌙 Sincronizando disparador Lua para Windows...
(
echo -- Disparador definitivo para Savin-cinema-rpc (Windows^)
echo mp.msg.info("Iniciando puente de Discord Rich Presence..."^)
echo.
echo mp.command_native_async({
echo     name = "subprocess",
echo     args = {"pythonw", mp.command_native("expand-path", "~~/savin_cinema_rpc.py"^)},
echo     playback_only = false
echo })
) > "%APPDATA%\mpv\scripts\discord_launcher.lua"
echo ✅ Lanzador Lua configurado en segundo plano invisible.
echo.

:: Asegurar el servidor IPC por tuberías (Named Pipes) en el mpv.conf de Windows
if not exist "%APPDATA%\mpv\mpv.conf" type nul > "%APPDATA%\mpv\mpv.conf"
findstr /C:"input-ipc-server=\\\\.\\pipe\\mpvsocket" "%APPDATA%\mpv\mpv.conf" >nul
if %errorlevel% neq 0 (
    echo input-ipc-server=\\.\pipe\mpvsocket >> "%APPDATA%\mpv\mpv.conf"
    echo ✅ Línea de servidor IPC de Windows añadida a tu mpv.conf
)

echo ==================================================
echo  🎉 ¡Savin-cinema-rpc v3.3 instalado con éxito!  
echo ==================================================
echo.
echo Presiona cualquier tecla para cerrar el instalador...
pause >nul
exit /b

:: ==================================================================================
:: CÓDIGO NÚCLEO PYTHON (Extraído dinámicamente por la rutina de PowerShell)
:: ==================================================================================
##PY:import os
##PY:import socket
##PY:import json
##PY:import time
##PY:import re
##PY:import requests
##PY:import sys
##PY:from pypresence import Presence
##PY:
##PY:CLIENT_ID = 'SAVIN_DYNAMIC_CLIENT_ID'
##PY:GITHUB_URL = 'https://github.com/MVP-Savyn/Savin-cinemaRPC'
##PY:INCLUDE_INFO = SAVIN_DYNAMIC_INCLUDE_INFO
##PY:INCLUDE_GITHUB = SAVIN_DYNAMIC_INCLUDE_GITHUB
##PY:SOCKET_PATH = r'\\.\pipe\mpvsocket'
##PY:TMDB_API_KEY = 'cd8015c4e4de965057e0282c9d19610f'
##PY:
##PY:RAW_CLEAN_TAGS = ['1080p', '720p', '4k', '2160p', 'bluray', 'bdrip', 'brrip', 'h264', 'x264', 'x265', 'h265', 'hevc', 'web-dl', 'webdl', 'dvdrip', 'screener', 'aac', 'ac3', 'mp3', 'dual', 'hdr', 'remux', 'atmos', 'dts']
##PY:
##PY:def clean_filename_generic(filename):
##PY:    if not filename: return ""
##PY:    name, _ = os.path.splitext(filename)
##PY:    name = re.sub(r'\[.*?\]', '', name)
##PY:    name = re.sub(r'\(.*?\)', '', name)
##PY:    for tag in RAW_CLEAN_TAGS: name = re.sub(r'(?i)\b' + tag + r'\b', '', name)
##PY:    name = name.replace('.', ' ').replace('_', ' ').replace('-', ' ')
##PY:    return re.sub(r'\s+', ' ', name).strip('. -_')
##PY:
##PY:def parse_media_type(filename):
##PY:    if not filename: return None, None, None
##PY:    name_no_ext, _ = os.path.splitext(filename)
##PY:    pattern = re.compile(r'(?i)(.*?)[ ._\[\-](?:[Ss](\d+)[Ee](\d+)|(\d+)x(\d+))')
##PY:    match = pattern.search(name_no_ext)
##PY:    if match:
##PY:        raw_title = match.group(1)
##PY:        if match.group(2): s_num, e_num = match.group(2), match.group(3)
##PY:        else: s_num, e_num = match.group(4), match.group(5)
##PY:        clean_title = clean_filename_generic(raw_title)
##PY:        return clean_title, f"Temporada {int(s_num)} - Episodio {int(e_num)}", "tv"
##PY:    return clean_filename_generic(filename), None, "movie"
##PY:
##PY:def get_media_data(filename):
##PY:    clean_title, ep_info, media_type = parse_media_type(filename)
##PY:    if not clean_title: return filename, None, "mpv-icon", None
##PY:    if media_type == "tv":
##PY:        search_endpoint = "search/tv"
##PY:        view_url_base = "tv"
##PY:    else:
##PY:        search_endpoint = "search/movie"
##PY:        view_url_base = "movie"
##PY:    url_es = f"https://api.themoviedb.org/3/{search_endpoint}?api_key={TMDB_API_KEY}&query={requests.utils.quote(clean_title)}&language=es-ES"
##PY:    url_en = f"https://api.themoviedb.org/3/{search_endpoint}?api_key={TMDB_API_KEY}&query={requests.utils.quote(clean_title)}&language=en-US"
##PY:    for url in [url_es, url_en]:
##PY:        try:
##PY:            response = requests.get(url, timeout=4)
##PY:            if response.status_code != 200: continue
##PY:            results = response.json().get('results', [])
##PY:            if results:
##PY:                match = results[0]
##PY:                titulo_real = match.get('name') if media_type == "tv" else match.get('title', clean_title)
##PY:                fecha = match.get('first_air_date') if media_type == "tv" else match.get('release_date', '')
##PY:                fecha_year = fecha.split('-')[0] if fecha else ""
##PY:                titulo_final = f"{titulo_real} ({fecha_year})" if fecha_year else titulo_real
##PY:                poster = f"https://image.tmdb.org/t/p/w500{match.get('poster_path')}" if match.get('poster_path') else "mpv-icon"
##PY:                movie_id = match.get('id')
##PY:                tmdb_url = f"https://www.themoviedb.org/{view_url_base}/{movie_id}" if movie_id else None
##PY:                return titulo_final, ep_info, poster, tmdb_url
##PY:        except: pass
##PY:    return clean_title, ep_info, "mpv-icon", None
##PY:
##PY:def send_mpv_command(cmd_name, *args):
##PY:    try:
##PY:        with open(SOCKET_PATH, 'r+b', buffering=0) as pipe:
##PY:            message = {"command": [cmd_name] + list(args)}
##PY:            pipe.write(json.dumps(message).encode('utf-8') + b'\n')
##PY:            res = pipe.readline().decode('utf-8')
##PY:            return json.loads(res).get("data")
##PY:    except: return "__SOCKET_DEAD__"
##PY:
##PY:def generate_progress_bar(current, total, length=6):
##PY:    if total <= 0: return "🔘" + "▬" * (length - 1)
##PY:    percent = max(0.0, min(1.0, current / total))
##PY:    filled_length = int(round(length * percent))
##PY:    if filled_length >= length: filled_length = length - 1
##PY:    return "▬" * filled_length + "🔘" + "▬" * (length - filled_length - 1)
##PY:
##PY:def main():
##PY:    try:
##PY:        RPC = Presence(CLIENT_ID)
##PY:        RPC.connect()
##PY:    except: return
##PY:    last_state, last_filename, last_toggle_time, last_update_time = None, "", 0, 0
##PY:    display_title, ep_info, imagen_caratula, movie_url = "", None, "mpv-icon", None
##PY:    while True:
##PY:        res = send_mpv_command("get_property", "filename")
##PY:        if res == "__SOCKET_DEAD__":
##PY:            try: RPC.clear(); RPC.close()
##PY:            except: pass
##PY:            sys.exit(0)
##PY:        filename = res
##PY:        if filename:
##PY:            paused = send_mpv_command("get_property", "pause")
##PY:            time_pos = send_mpv_command("get_property", "time-pos")
##PY:            duration = send_mpv_command("get_property", "duration")
##PY:            if "__SOCKET_DEAD__" in [paused, time_pos, duration]:
##PY:                try: RPC.clear(); RPC.close()
##PY:                except: pass
##PY:                sys.exit(0)
##PY:            try:
##PY:                t_actual = int(float(time_pos)) if time_pos is not None else 0
##PY:                t_total = int(float(duration)) if duration is not None else 0
##PY:            except: t_actual, t_total = 0, 0
##PY:            current_state = 'paused' if paused else 'playing'
##PY:            now = time.time()
##PY:            if filename != last_filename:
##PY:                display_title, ep_info, imagen_caratula, movie_url = get_media_data(filename)
##PY:                last_filename = filename
##PY:            progreso_actual = time.strftime('%H:%M:%S', time.gmtime(t_actual)) if t_actual >= 3600 else time.strftime('%M:%S', time.gmtime(t_actual))
##PY:            progreso_total = time.strftime('%H:%M:%S', time.gmtime(t_total)) if t_total >= 3600 else time.strftime('%M:%S', time.gmtime(t_total))
##PY:            barras_visuales = generate_progress_bar(t_actual, t_total)
##PY:            payload = {"details": display_title, "large_image": imagen_caratula, "large_text": "mpv media player"}
##PY:            prefix_status = "📺 " if ep_info else ""
##PY:            time_status = f"{ep_info} | {progreso_actual} {barras_visuales} {progreso_total}" if ep_info else f"{progreso_actual} {barras_visuales} {progreso_total}"
##PY:            payload["state"] = f"⏸️ {prefix_status}{time_status}" if current_state == 'paused' else f"▶ {prefix_status}{time_status}"
##PY:            buttons_list = []
##PY:            if INCLUDE_INFO and movie_url: buttons_list.append({"label": "Ver información", "url": movie_url})
##PY:            if INCLUDE_GITHUB: buttons_list.append({"label": "Github", "url": GITHUB_URL})
##PY:            if buttons_list: payload["buttons"] = buttons_list
##PY:            state_changed = (current_state != last_state)
##PY:            time_to_update = (now - last_update_time >= 10.0)
##PY:            can_send = False
##PY:            if state_changed:
##----
##PY:                if now - last_toggle_time >= 3.0: can_send = True; last_toggle_time = now
##PY:            elif current_state == 'playing' and time_to_update: can_send = True
##PY:            if can_send:
##PY:                try:
##PY:                    RPC.update(**payload)
##PY:                    last_state = current_state
##PY:                    last_update_time = now
##PY:                    os.system('cls')
##PY:                    print("=" * 75)
##PY:                    print(" 🎬   MPV DISCORD RICH PRESENCE - WINDOWS CUSTOM LAYOUT v3.3 🎬")
##PY:                    print("=" * 75)
##PY:                    print(f" 🎥 Medio:          '{display_title}'")
##PY:                    if ep_info: print(f" 📺 Info Serie:      {ep_info}")
##PY:                    print(f" ⚙️  Estado RPC:      {payload['state']}")
##PY:                    print(f" 🎬 Botón Info:      {'ACTIVADO' if (INCLUDE_INFO and movie_url) else 'DESACTIVADO o Sin Ficha'}")
##PY:                    print(f" 💻 Botón GitHub:    {'ACTIVADO' if INCLUDE_GITHUB else 'DESACTIVADO'}")
##PY:                    print("=" * 75)
##PY:                except: pass
##PY:        else:
##PY:            if last_state != 'idle':
##PY:                try: RPC.clear(); last_state = 'idle'; last_filename = ""; movie_url = None; ep_info = None
##PY:                except: pass
##PY:        time.sleep(1)
##PY:
##PY:if __name__ == "__main__":
##PY:    main()