-- Disparador definitivo generado por Python
mp.msg.info("Iniciando puente de Discord Rich Presence...")

mp.command_native_async({
    name = "subprocess",
    args = {"/Library/Developer/CommandLineTools/usr/bin/python3", "/Applications/mpv.app/Contents/Resources/mpv_discord.py"},
    playback_only = false
})
