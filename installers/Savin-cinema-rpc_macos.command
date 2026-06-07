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
echo -e "${CYAN}    Instalador Oficial: Savin-cinema-rpc v3.3   ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""

# 1. Detectar el entorno real de Python
echo -e "${YELLOW}[1/8] 🔍 Buscando tu entorno de Python real...${NC}"
REAL_PYTHON=$(python3 -c "import sys; print(sys.executable)")

if [ -z "$REAL_PYTHON" ]; then
    echo -e "${RED}❌ Error: No se ha detectado Python 3 en el sistema.${NC}"
    echo "Presiona Enter para salir..."
    read
    exit 1
fi
echo -e "${GREEN}✅ Python detectado en: $REAL_PYTHON${NC}"
echo ""

# 2. Configuración de Discord Application ID
echo -e "${YELLOW}[2/8] 🆔 Configuración de Discord Application ID...${NC}"
DEFAULT_CLIENT_ID="1512598323725602878"
echo -e "Introduce tu ${CYAN}CLIENT_ID personalizado${NC} si tienes uno."
echo -e "O simplemente presiona ${GREEN}[ENTER]${NC} para usar el ID por defecto (${DEFAULT_CLIENT_ID}):"
read -p "❯ " USER_INPUT_ID

if [ -z "$USER_INPUT_ID" ]; then
    FINAL_CLIENT_ID="$DEFAULT_CLIENT_ID"
    echo -e "${GREEN}➡ Aplicado ID por defecto: $FINAL_CLIENT_ID${NC}"
else
    FINAL_CLIENT_ID=$(echo "$USER_INPUT_ID" | tr -d ' ')
    echo -e "${GREEN}➡ Aplicado ID personalizado: $FINAL_CLIENT_ID${NC}"
fi
echo ""

# 3. Selector Opcional del Botón de Información
echo -e "${YELLOW}[3/8] 🎬 Configuración del botón 'Ver información'...${NC}"
echo -e "¿Deseas mostrar el botón de información de TMDb en Discord?"
echo -e "Presiona ${GREEN}[ENTER]${NC} para Sí (Por defecto) o introduce ${RED}n${NC} para No:"
read -p "❯ " USER_INPUT_INFO

if [[ "$USER_INPUT_INFO" =~ ^[nN]$ ]]; then
    FINAL_INCLUDE_INFO="False"
    echo -e "${RED}➡ Botón de Información desactivado.${NC}"
else
    FINAL_INCLUDE_INFO="True"
    echo -e "${GREEN}➡ Botón de Información activado.${NC}"
fi
echo ""

# 4. Selector Opcional del Botón GitHub
echo -e "${YELLOW}[4/8] 💻 Configuración del botón de GitHub...${NC}"
echo -e "¿Deseas mostrar el botón hacia tu repositorio de GitHub?"
echo -e "Presiona ${GREEN}[ENTER]${NC} para Sí (Por defecto) o introduce ${RED}n${NC} para No:"
read -p "❯ " USER_INPUT_GH

if [[ "$USER_INPUT_GH" =~ ^[nN]$ ]]; then
    FINAL_INCLUDE_GH="False"
    echo -e "${RED}➡ Botón de GitHub desactivado.${NC}"
else
    FINAL_INCLUDE_GH="True"
    echo -e "${GREEN}➡ Botón de GitHub activado.${NC}"
fi
echo ""

# 5. Asegurar librerías
echo -e "${YELLOW}[5/8] 📦 Instalando dependencias necesarias (requests, pypresence)...${NC}"
"$REAL_PYTHON" -m pip install --upgrade pip --quiet
"$REAL_PYTHON" -m pip install requests pypresence --quiet
echo -e "${GREEN}✅ Dependencias listas.${NC}"
echo ""

# 6. Crear árbol de directorios de MPV si no existen
echo -e "${YELLOW}[6/8] 📂 Verificando estructura de directorios de MPV...${NC}"
mkdir -p "$HOME/.config/mpv/scripts"
mkdir -p "$HOME/Library/Application Support/mpv/scripts"
echo -e "${GREEN}✅ Directorios OK.${NC}"
echo ""

# 7. Escribir script de control v3.3 con Gestión Dual de Flags Opcionales
echo -e "${YELLOW}[7/8] 🐍 Escribiendo script de control (savin_cinema_rpc.py)...${NC}"
cat << 'PYEOF' > "$HOME/.config/mpv/savin_cinema_rpc.py"
import os
import socket
import json
import time
import re
import requests
import sys
from pypresence import Presence

CLIENT_ID = 'SAVIN_DYNAMIC_CLIENT_ID'
GITHUB_URL = 'https://github.com/MVP-Savyn/Savin-cinemaRPC'
INCLUDE_INFO = SAVIN_DYNAMIC_INCLUDE_INFO
INCLUDE_GITHUB = SAVIN_DYNAMIC_INCLUDE_GITHUB
SOCKET_PATH = '/tmp/mpvsocket'
TMDB_API_KEY = 'cd8015c4e4de965057e0282c9d19610f'

RAW_CLEAN_TAGS = ['1080p', '720p', '4k', '2160p', 'bluray', 'bdrip', 'brrip', 'h264', 'x264', 'x265', 'h265', 'hevc', 'web-dl', 'webdl', 'dvdrip', 'screener', 'aac', 'ac3', 'mp3', 'dual', 'hdr', 'remux', 'atmos', 'dts']

def clean_filename_generic(filename):
    if not filename: return ""
    name, _ = os.path.splitext(filename)
    name = re.sub(r'\[.*?\]', '', name)
    name = re.sub(r'\(.*?\)', '', name)
    
    for tag in RAW_CLEAN_TAGS: name = re.sub(r'(?i)\b' + tag + r'\b', '', name)
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
    if not os.path.exists(SOCKET_PATH): return "__SOCKET_DEAD__"
    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.connect(SOCKET_PATH)
        message = {"command": [cmd_name] + list(args)}
        client.sendall(json.dumps(message).encode('utf-8') + b'\n')
        response = client.recv(4096).decode('utf-8')
        client.close()
        return json.loads(response).get("data")
    except: return "__SOCKET_DEAD__"

def generate_progress_bar(current, total, length=6):
    if total <= 0: 
        return "🔘" + "▬" * (length - 1)
    percent = max(0.0, min(1.0, current / total))
    filled_length = int(round(length * percent))
    if filled_length >= length:
        filled_length = length - 1
    bar = "▬" * filled_length + "🔘" + "▬" * (length - filled_length - 1)
    return bar

def main():
    try:
        RPC = Presence(CLIENT_ID)
        RPC.connect()
    except: return
    
    last_state = None       
    last_filename = ""
    last_toggle_time = 0    
    last_update_time = 0    
    
    display_title, ep_info, imagen_caratula, movie_url = "", None, "mpv-icon", None
    
    while True:
        res = send_mpv_command("get_property", "filename")
        
        if res == "__SOCKET_DEAD__":
            try:
                RPC.clear()
                RPC.close()
            except: pass
            sys.exit(0)
            
        filename = res
        if filename:
            paused = send_mpv_command("get_property", "pause")
            time_pos = send_mpv_command("get_property", "time-pos")
            duration = send_mpv_command("get_property", "duration")
            
            if "__SOCKET_DEAD__" in [paused, time_pos, duration]:
                try:
                    RPC.clear()
                    RPC.close()
                except: pass
                sys.exit(0)
                
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
            
            payload = {
                "details": display_title,
                "large_image": imagen_caratula,
                "large_text": "mpv media player"
            }
            
            if ep_info:
                prefix_status = "📺 "
                time_status = f"{ep_info} | {progreso_actual} {barras_visuales} {progreso_total}"
            else:
                prefix_status = ""
                time_status = f"{progreso_actual} {barras_visuales} {progreso_total}"

            if current_state == 'paused':
                payload["state"] = f"⏸️ {prefix_status}{time_status}"
            else:
                payload["state"] = f"▶ {prefix_status}{time_status}"
            
            # Construcción modular inteligente de botones
            buttons_list = []
            
            # Botón 1 opcional: TMDb Info (Renombrado a "Ver información")
            if INCLUDE_INFO and movie_url:
                buttons_list.append({"label": "Ver información", "url": movie_url})
            
            # Botón 2 opcional: GitHub
            if INCLUDE_GITHUB:
                buttons_list.append({"label": "Github", "url": GITHUB_URL})
            
            # Inyectar solo si se ha activado al menos un botón válido
            if buttons_list:
                payload["buttons"] = buttons_list
            
            state_changed = (current_state != last_state)
            time_to_update = (now - last_update_time >= 10.0)
            
            can_send = False
            if state_changed:
                if now - last_toggle_time >= 3.0:
                    can_send = True
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
                    print(" 🎬   MPV DISCORD RICH PRESENCE - CUSTOM BUTTON LAYOUT v3.3 🎬")
                    print("=" * 75)
                    print(f" 🎥 Medio:          '{display_title}'")
                    if ep_info: print(f" 📺 Info Serie:      {ep_info}")
                    print(f" ⚙️  Estado RPC:      {payload['state']}")
                    print(f" 🎬 Botón Info:      {'ACTIVADO' if (INCLUDE_INFO and movie_url) else 'DESACTIVADO o Sin Ficha'}")
                    print(f" 💻 Botón GitHub:    {'ACTIVADO' if INCLUDE_GITHUB else 'DESACTIVADO'}")
                    print("=" * 75)
                except:
                    pass
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
PYEOF

# Reemplazar el marcador del ID de aplicación de Discord
sed -i '' "s/SAVIN_DYNAMIC_CLIENT_ID/$FINAL_CLIENT_ID/g" "$HOME/.config/mpv/savin_cinema_rpc.py" 2>/dev/null || sed -i "s/SAVIN_DYNAMIC_CLIENT_ID/$FINAL_CLIENT_ID/g" "$HOME/.config/mpv/savin_cinema_rpc.py"

# Reemplazar flags de visibilidad condicional sin comillas (como Booleanos puros de Python)
sed -i '' "s/SAVIN_DYNAMIC_INCLUDE_INFO/$FINAL_INCLUDE_INFO/g" "$HOME/.config/mpv/savin_cinema_rpc.py" 2>/dev/null || sed -i "s/SAVIN_DYNAMIC_INCLUDE_INFO/$FINAL_INCLUDE_INFO/g" "$HOME/.config/mpv/savin_cinema_rpc.py"
sed -i '' "s/SAVIN_DYNAMIC_INCLUDE_GITHUB/$FINAL_INCLUDE_GH/g" "$HOME/.config/mpv/savin_cinema_rpc.py" 2>/dev/null || sed -i "s/SAVIN_DYNAMIC_INCLUDE_GITHUB/$FINAL_INCLUDE_GH/g" "$HOME/.config/mpv/savin_cinema_rpc.py"

echo -e "${GREEN}✅ Configuración modular inyectada en el núcleo.${NC}"
echo ""

# 8. Generar los lanzadores .lua dinámicos
echo -e "${YELLOW}[8/8] 🌙 Sincronizando disparadores Lua...${NC}"
cat << LUAEOF > "$HOME/.config/mpv/scripts/discord_launcher.lua"
-- Disparador definitivo para Savin-cinema-rpc
mp.msg.info("Iniciando puente de Discord Rich Presence...")

mp.command_native_async({
    name = "subprocess",
    args = {"$REAL_PYTHON", "$HOME/.config/mpv/savin_cinema_rpc.py"},
    playback_only = false
})
LUAEOF

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
echo -e "${GREEN} 🎉 ¡Savin-cinema-rpc v3.3 instalado con éxito!  ${NC}"
echo -e "${BLUE}==================================================${NC}"
echo ""
echo "Presiona cualquier tecla para finalizar..."
read -n 1 -s