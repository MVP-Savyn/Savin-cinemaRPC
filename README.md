# Savin-cinemaRPC
Mod de MPV para compartir en discord la película que estás viendo en local, CON CARÁTULA de la película y detalles del minuto por el que vas

# Savin-cinema-rpc 🎬

Un puente automatizado de **Discord Rich Presence** para **mpv** en macOS. Este script detecta dinámicamente tu reproducción en mpv, limpia los nombres de los archivos locales o en streaming (como los montajes de `Cinema_cloud`) mediante expresiones regulares, e interactúa con la API de **The Movie Database (TMDB)** para mostrar el póster oficial de la película y su título estilizado en tu perfil de Discord.

---

## ✨ Características

* **Instalador Inteligente (`.command`)**: Olvídate de configurar rutas a mano. Un ejecutable nativo de macOS configurará el entorno con un doble clic.
* **Flexibilidad de Client ID**: Permite usar la aplicación de Discord por defecto o inyectar tu propio ID personalizado durante la instalación.
* **Limpieza por Regex Avanzada**: Elimina automáticamente etiquetas molestas de los archivos de video (`1080p`, `x265`, `Bluray`, corchetes, paréntesis) para procesar nombres limpios.
* **Integración con TMDB**: Busca carátulas y títulos reales con soporte bilingüe (Español/Inglés) en tiempo real.
* **Detección Dinámica de Entorno**: Vincula los disparadores de Lua directamente al binario real de Python en tu sistema, evitando los temidos fallos de `ModuleNotFoundError` causados por entornos aislados en macOS.
* **Monitoreo en Tiempo Real**: Sincroniza estados de pausa, tiempo transcurrido y duración total usando sockets IPC nativos (`/tmp/mpvsocket`).

---

## 🚀 Instalación Rápida

1. Descarga el archivo `Savin-cinema-rpc.command`.
2. Haz **doble clic** sobre él en el Finder.
3. Sigue las instrucciones en pantalla (puedes presionar `Enter` para usar la configuración por defecto o introducir tus credenciales personalizadas).
4. ¡Listo! Abre cualquier video en tu reproductor mpv y disfruta.

> 💡 **Nota de macOS**: Si el sistema bloquea el archivo por seguridad al ser la primera vez que se ejecuta, haz **clic derecho -> Abrir** desde el Finder para otorgarle permisos, o ejecuta `chmod +x Savin-cinema-rpc.command` en la terminal.

---

## 📂 Estructura del Ecosistema

El instalador despliega automáticamente los componentes en las siguientes ubicaciones para garantizar compatibilidad tanto en terminal como en entorno gráfico:

* **Script de Control (Python)**: `~/.config/mpv/savin_cinema_rpc.py`
* **Lanzadores Dinámicos (Lua)**: 
  * `~/.config/mpv/scripts/discord_launcher.lua`
  * `~/Library/Application Support/mpv/scripts/discord_launcher.lua`
* **Configuración del Servidor**: Inyección automática de `input-ipc-server=/tmp/mpvsocket` en tus perfiles de `mpv.conf`.

---

## 🛠️ Dependencias Automáticas

El instalador se encarga de verificar e instalar mediante `pip` de forma aislada:
* `pypresence`
* `requests`
