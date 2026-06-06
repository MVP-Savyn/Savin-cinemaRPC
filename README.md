# Savin-cinema-rpc 🎬

Un mod muy simple que envía a discord la información de lo que estás viendo en **local o streaming** con **mpv**, incluyendo la carátula de la película y el minuto de reproducción.

Esta script detecta dinámicamente tu reproducción en mpv, procesa y limpia los nombres de los archivos locales o en streaming (ideal para combinar con **rclone** para usar una nube con películas en remoto) mediante expresiones regulares avanzadas, e interactúa con la API de **The Movie Database (TMDB)** para mostrar el póster oficial y el título estilizado de la película directamente en tu perfil de Discord.
<br><br>
Bro simplemente es brutal poder ver en discord la carátula de la película, hay varios mods de mpv pero este aplica una carátula aunque los metadatos de tu archivo **p1r4t4** estén modificados, con tan sólo poner el nombre del archivo con el título de la película (que en la mayor parte de las ocasiones no tendrás que hacerlo porque el mod omite todos los elementos como puntos o enlaces), el mod hace el resto.

---

## ✨ Características

* **Soporte Multiplataforma Real**: Adaptado a las particularidades de sockets y tuberías de comunicación de cada sistema operativo (Sockets UNIX en macOS/Linux y Pipes Nombrados en Windows).
* **Limpieza por Regex Avanzada**: Purga automáticamente del título etiquetas de resolución, códecs y ripeos (`1080p`, `x265`, `Bluray`, corchetes, paréntesis) antes de buscar metadatos.
* **Integración Nativa con TMDB**: Localiza de manera inteligente carátulas y títulos oficiales con soporte bilingüe (Español/Inglés) en tiempo real.
* **Instaladores Inteligentes**: Automatización del despliegue de dependencias (`pypresence`, `requests`) e inyección automática del intérprete de Python adecuado con un solo clic.
* **Sincronización de Tiempo Precisa**: Mapeo en tiempo real del estado de pausa, tiempo transcurrido y duración total de la cinta.

---

## 📸 Ejemplos de Visualización

Así es como se ve tu perfil de Discord cuando el script está en funcionamiento. Al integrarse con TMDB, recupera dinámicamente los pósters oficiales en lugar de mostrar un icono genérico:

### 🎬 En Reproducción
Cuando estás viendo una película, muestra el título limpio, el año de lanzamiento, el estado actual y una barra de tiempo dinámica con el progreso exacto.

![Ejemplo en Reproducción](assets/discord_playing.png)

### ⏸️ En Pausa
Si detienes momentáneamente la reproducción, el estado de tu Rich Presence se actualiza al instante reflejando que la cinta está pausada y congelando el temporizador.

![Ejemplo en Pausa](assets/discord_paused.png)

---

## Ve a ver mi vídeo de YT!!

Aquí tienes un pequeño tutorial y demostración del funcionamiento (muy pequeño ya que no tiene mucho misterio):

[![Ver demostración de Savin-cinema-rpc](https://img.youtube.com/vi/TU_ID_DE_VIDEO/0.jpg)](https://www.youtube.com/watch?v=TU_ID_DE_VIDEO)
---

## 📂 Arquitectura y Rutas por Sistema

El programa adapta su comportamiento e inyección de archivos según el entorno donde se ejecute:

| Sistema Operativo | Ruta del Script (`.py`) y Configuración | Ruta del Script de Lanzamiento (`.lua`) | Servidor IPC (`mpv.conf`) |
| :--- | :--- | :--- | :--- |
| **macOS** 🍏 | `~/.config/mpv/` | `~/.config/mpv/scripts/`<br>`~/Library/Application Support/mpv/scripts/` | `input-ipc-server=/tmp/mpvsocket` |
| **Linux** 🐧 | `~/.config/mpv/` | `~/.config/mpv/scripts/` | `input-ipc-server=/tmp/mpvsocket` |
| **Windows** 🪟 | `%APPDATA%\mpv\` | `%APPDATA%\mpv\scripts\` | `input-ipc-server=\\.\pipe\mpvsocket` |

---
<br>
<br>
## 🛠️ Requisitos y Dependencias

Para que el ecosistema de **Savin-cinema-rpc** funcione sin problemas, el único requisito previo es que tu sistema cuente con **Python 3**.

### 1. Instalación de Python 3 (Paso previo manual)

Si tu equipo aún no tiene Python instalado, utiliza el método correspondiente a tu sistema operativo para prepararlo en menos de un minuto:

* **🍏 macOS:**
  Si utilizas el gestor de paquetes [Homebrew](https://brew.sh/) (altamente recomendado), simplemente ejecuta en tu terminal:
  ```bash
  brew install python

    *Alternativa:* También puedes descargar el instalador oficial de paquetes gráficos desde la web de [Python para macOS](https://www.python.org/downloads/mac-osx/).

* **🐧 Linux:**
  Utiliza el gestor de paquetes nativo de tu distribución:
  * **Arch Linux / CachyOS:** `sudo pacman -S python`
  * **Ubuntu / Debian:** `sudo apt update && sudo apt install python3 python3-pip`
  * **Fedora:** `sudo dnf install python3`

* **🪟 Windows:**
  Descarga el instalador ejecutable directamente desde [Python para Windows](https://www.python.org/downloads/windows/).
  > ⚠️ **CRÍTICO PARA WINDOWS:** Al abrir el instalador, asegúrate por completo de marcar la casilla que dice **"Add Python to PATH"** (Añadir Python al PATH) en la parte inferior de la primera ventana antes de pulsar *Install*. Si olvidas este paso, el script `.bat` no reconocerá los comandos.

### 2. Librerías del Núcleo (Instalación 100% Automática)

Una vez que el sistema detecte Python 3, **no necesitas instalar nada más a mano**. Nuestros instaladores automatizados (`.command`, `.sh` o `.bat`) se encargarán de desplegar y actualizar internamente mediante `pip` las siguientes dependencias:

* 📦 **`pypresence`** (vía pip): Una potente librería de bajo nivel escrita en Python que permite una comunicación limpia, asíncrona y segura con las tuberías (pipes) y sockets del cliente nativo de Discord.
* 📦 **`requests`** (vía pip): El estándar de oro para realizar peticiones HTTP en Python, utilizado por el script para conectarse en tiempo real a la API de **The Movie Database (TMDB)** de forma ultra rápida y segura.

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
