#!/bin/bash

# Configuración de colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${BLUE}==================================================${NC}"
echo -e "${CYAN}    Instalador Oficial: Savin-cinema-rpc v1.2   ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# 1. Detectar el entorno real de Python
echo -e "${YELLOW}[1/6] 🔍 Buscando tu entorno de Python real...${NC}"
REAL_PYTHON=$(python3 -c "import sys; print(sys.executable)")

if [ -z "$REAL_PYTHON" ]; then
    echo -e "${RED}❌ Error: No se ha detectado Python 3 en el sistema.${NC}"
    echo "Presiona Enter para salir..."
    read
    exit 1
fi
echo -e "${GREEN}✅ Python detectado en: $REAL_PYTHON${NC}"
echo ""

# 2. INTERACCIÓN: Preguntar por el Discord Client ID
echo -e "${YELLOW}[2/6] 🆔 Configuración de Discord Application ID...${NC}"
DEFAULT_CLIENT_ID="1512598323725602878"
echo -e "Introduce tu ${CYAN}CLIENT_ID personalizado${NC} si tienes uno."
echo -e "O simplemente presiona ${GREEN}[ENTER]${NC} para usar el ID por defecto (${DEFAULT_CLIENT_ID}):"
read -p "❯ " USER_INPUT_ID

if [ -z "$USER_INPUT_ID" ]; then
    FINAL_CLIENT_ID="$DEFAULT_CLIENT_ID"
    echo -e "${GREEN}➡ Aplicado ID por defecto: $FINAL_CLIENT_ID${NC}"
else
    # Eliminar espacios en blanco por si acaso al copiar/pegar
    FINAL_CLIENT_ID=$(echo "$USER_INPUT_ID" | tr -d ' ')
    echo -e "${GREEN}➡ Aplicado ID personalizado: $FINAL_CLIENT_ID${NC}"
fi
echo ""

# 3. Asegurar librerías en ese Python
echo -e "${YELLOW}[3/6] 📦 Instalando dependencias necesarias (requests, pypresence)...${NC}"
"$REAL_PYTHON" -m pip install --upgrade pip --quiet
"$REAL_PYTHON" -m pip install requests pypresence --quiet
echo -e "${GREEN}✅ Dependencias listas.${NC}"
echo ""

# 4. Crear árbol de directorios de MPV si no existen
echo -e "${YELLOW}[4/6] 📂 Verificando estructura de directorios de MPV...${NC}"
mkdir -p "$HOME/.config/mpv/scripts"
mkdir -p "$HOME/Library/Application Support/mpv/scripts"
echo -e "${GREEN}✅ Directorios OK.${NC}"
echo ""

# 5. Escribir tu script original usando un marcador para el ID
echo -e "${YELLOW}[5/6] 🐍 Escribiendo script de control (savin_cinema_rpc.py)...${NC}"
cat << 'PYEOF' > "$HOME/.config/mpv/savin_cinema_rpc.py"
import os
import socket
import json
import time
import re
import requests
from pypresence import Presence

CLIENT_ID = 'SAVIN_DYNAMIC_CLIENT_ID'
SOCKET_PATH = '/tmp/mpvsocket'
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
    if not os.path.exists(SOCKET_PATH): return None
    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.connect(SOCKET_PATH)
        message = {"command": [cmd_name] + list(args)}
        client.sendall(json.dumps(message).encode('utf-8') + b'\n')
        response = client.recv(4096).decode('utf-8')
        client.close()
        return json.loads(response).get("data")
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
                print("\033[H\033[J", end="")
                print("=" * 75)
                print(" 🎬   MPV DISCORD RICH PRESENCE MONITOR (CINEEE)   🎬")
                print("=" * 75)
                print(f" 🟢 Estado del Script:  Corriendo en segundo plano controlado por MPV")
                print(f" 📦 Archivo físico:     {filename}")
                print(f" 🎥 Título en Perfil:   '{display_title}'")
                print(f" ⏱️  Estado de repro:   {linea_estado_discord}")
                print(f" 🖼️  Poster URL:         {imagen_caratula}")
                print("=" * 75)
            except: pass
        else:
            try:
                RPC.clear()
                last_filename = ""
            except: pass
        time.sleep(2)

if __name__ == "__main__":
    main()
PYEOF

# Reemplazar el marcador por el ID real seleccionado por el usuario
sed -i '' "s/SAVIN_DYNAMIC_CLIENT_ID/$FINAL_CLIENT_ID/g" "$HOME/.config/mpv/savin_cinema_rpc.py" 2>/dev/null || sed -i "s/SAVIN_DYNAMIC_CLIENT_ID/$FINAL_CLIENT_ID/g" "$HOME/.config/mpv/savin_cinema_rpc.py"
echo -e "${GREEN}✅ Script de Python configurado e inyectado.${NC}"
echo ""

# 6. Generar los lanzadores .lua dinámicos
echo -e "${YELLOW}[6/6] 🌙 Sincronizando disparadores Lua...${NC}"
cat << LUAEOF > "$HOME/.config/mpv/scripts/discord_launcher.lua"
-- Disparador definitivo para Savin-cinema-rpc
mp.msg.info("Iniciando puente de Discord Rich Presence...")

mp.command_native_async({
    name = "subprocess",
    args = {"$REAL_PYTHON", "$HOME/.config/mpv/savin_cinema_rpc.py"},
    playback_only = false
})
LUAEOF

# Copiar el disparador en la ruta de la interfaz gráfica de macOS
cp "$HOME/.config/mpv/scripts/discord_launcher.lua" "$HOME/Library/Application Support/mpv/scripts/discord_launcher.lua"
echo -e "${GREEN}✅ Lanzadores Lua listos en ambos entornos.${NC}"
echo ""

# Asegurar el socket IPC en los mpv.conf
for CONF in "$HOME/.config/mpv/mpv.conf" "$HOME/Library/Application Support/mpv/mpv.conf"; do
    touch "$CONF"
    if ! grep -q "input-ipc-server=/tmp/mpvsocket" "$CONF"; then
        echo "input-ipc-server=/tmp/mpvsocket" >> "$CONF"
    fi
done

echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN} 🎉 ¡Savin-cinema-rpc v1.2 instalado con éxito!  ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo "Presiona cualquier tecla para finalizar..."
read -n 1 -s
