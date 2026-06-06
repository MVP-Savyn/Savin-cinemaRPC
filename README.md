# Savin-cinema-rpc 🎬
Un mod muy simple que envía a discord la información de lo que estás viendo en **local o streaming** con **mpv**, incluyendo la carátula de la película y el minuto de reproducción.

Esta script detecta dinámicamente tu reproducción en mpv, procesa y limpia los nombres de los archivos locales o en streaming (ideal para combinar con **rclone** para usar una nube con películas en remoto) mediante expresiones regulares avanzadas, e interactúa con la API de **The Movie Database (TMDB)** para mostrar el póster oficial y el título estilizado de la película directamente en tu perfil de Discord.

---

## ✨ Características

* **Soporte Multiplataforma Real**: Adaptado a las particularidades de sockets y tuberías de comunicación de cada sistema operativo (Sockets UNIX en macOS/Linux y Pipes Nombrados en Windows).
* **Limpieza por Regex Avanzada**: Purga automáticamente del título etiquetas de resolución, códecs y ripeos (`1080p`, `x265`, `Bluray`, corchetes, paréntesis) antes de buscar metadatos.
* **Integración Nativa con TMDB**: Localiza de manera inteligente carátulas y títulos oficiales con soporte bilingüe (Español/Inglés) en tiempo real.
* **Instaladores Inteligentes**: Automatización del despliegue de dependencias (`pypresence`, `requests`) e inyección automática del intérprete de Python adecuado.
* **Sincronización de Tiempo Precisa**: Mapeo en tiempo real del estado de pausa, tiempo transcurrido y duración total de la cinta.

---

## 📂 Arquitectura y Rutas por Sistema

El programa adapta su comportamiento e inyección de archivos según el entorno donde se ejecute:

| Sistema Operativo | Ruta del Script (`.py`) y Configuración | Ruta del Script de Lanzamiento (`.lua`) | Servidor IPC (`mpv.conf`) |
| :--- | :--- | :--- | :--- |
| **macOS** 🍏 | `~/.config/mpv/` | `~/.config/mpv/scripts/`<br>`~/Library/Application Support/mpv/scripts/` | `input-ipc-server=/tmp/mpvsocket` |
| **Linux** 🐧 | `~/.config/mpv/` | `~/.config/mpv/scripts/` | `input-ipc-server=/tmp/mpvsocket` |
| **Windows** 🪟 | `%APPDATA%\mpv\` | `%APPDATA%\mpv\scripts\` | `input-ipc-server=\\.\pipe\mpvsocket` | (o la ruta de mpv personalizada)

---

## 🚀 Guía de Instalación

### 🍏 En macOS
1. Descarga el archivo de instalación `Savin-cinema-rpc.command`.
2. Haz **doble clic** sobre él en el Finder.
3. Sigue las instrucciones interactivas en la terminal (puedes presionar `Enter` para usar el Client ID por defecto o introducir uno personalizado).

> 💡 *Nota de macOS:* Si el sistema lo bloquea por seguridad la primera vez, haz clic derecho sobre el archivo y selecciona **Abrir**.

### 🐧 En Linux
1. Asegúrate de dar permisos de ejecución al script instalador (`Savin-cinema-rpc.sh`):
   ```bash
   chmod +x Savin-cinema-rpc.sh
