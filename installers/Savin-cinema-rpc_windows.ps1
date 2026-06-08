<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Savin-cinema-rpc — El Mod Definitivo para MPV</title>
    <style>
        :root {
            --bg-main: #060709;
            --bg-card: rgba(13, 17, 23, 0.65); 
            --bg-card-hover: rgba(18, 24, 33, 0.75);
            --accent: #00ebd4;
            --accent-glow: rgba(0, 235, 212, 0.25);
            --python-blue: #3776AB;
            --python-blue-glow: rgba(55, 118, 171, 0.3); 
            --text-main: #f3f4f6;
            --text-muted: #9ca3af;
            --discord-dark: #232428;
            --discord-profile: #111214;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            -webkit-user-select: none;
            user-select: none;
        }

        body {
            background-color: transparent; /* Permite ver el contenedor de fondo fijo */
            color: var(--text-main);
            line-height: 1.6;
            overflow-x: hidden;
        }

        .container {
            max-width: 1150px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        /* --- CONTENEDOR VÍDEO DE FONDO --- */
        .video-bg-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: -1;
            overflow: hidden;
            background-color: var(--bg-main);
        }

        #bg-video {
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.40; /* 🌟 Ajustado para que no se vea tan oscuro y resalte más */
            will-change: transform;
            transform: translateZ(0); 
            filter: blur(2px); /* 🌟 Reducido para mayor nitidez visual */
            transition: opacity 0.5s ease;
        }

        /* --- SELECTOR INTERACTIVO DE FONDOS --- */
        .bg-control-panel {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 2000;
            background: rgba(13, 17, 23, 0.7);
            border: 1px solid rgba(31, 42, 60, 0.8);
            border-radius: 30px;
            padding: 5px;
            display: flex;
            align-items: center;
            gap: 4px;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
        }

        .bg-panel-title {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-muted);
            padding: 0 10px 0 12px;
            font-weight: 700;
        }

        .bg-btn {
            background: transparent;
            border: none;
            color: var(--text-muted);
            width: 32px;
            height: 32px;
            border-radius: 50%;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .bg-btn:hover {
            color: #ffffff;
            background: rgba(255, 255, 255, 0.1);
        }

        .bg-btn.active {
            background: var(--accent);
            color: #020406;
            box-shadow: 0 0 12px var(--accent-glow);
        }

        /* Header & Perfil */
        header {
            text-align: center;
            margin-bottom: 40px;
        }

        .profile-container {
            position: relative;
            display: inline-block;
            margin-bottom: 20px;
        }

        .profile-img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 3px solid var(--accent);
            box-shadow: 0 0 25px var(--accent-glow);
            transition: transform 0.3s ease;
        }

        .profile-img:hover {
            transform: scale(1.05);
        }

        .profile-name {
            display: block;
            font-size: 1.1rem;
            color: var(--accent);
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-top: 10px;
        }

        h1 {
            font-size: 3.2rem;
            font-weight: 800;
            letter-spacing: -1px;
            margin-bottom: 12px;
            background: linear-gradient(135deg, #ffffff 50%, var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .tagline {
            font-size: 1.2rem;
            color: var(--text-muted);
            max-width: 750px;
            margin: 0 auto 30px auto;
        }

        .cta-container {
            display: flex;
            gap: 15px;
            justify-content: center;
            align-items: center; 
            flex-wrap: wrap; 
            margin-top: 35px; /* Un pelín más de espacio superior por las letras flotantes */
        }

        .cta-btn {
            display: inline-block;
            background: var(--accent);
            color: #020406;
            padding: 15px 40px;
            border-radius: 50px;
            font-weight: 700;
            text-decoration: none;
            font-size: 1.15rem;
            box-shadow: 0 5px 20px var(--accent-glow);
            transition: all 0.3s ease;
        }

        .cta-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 30px var(--accent-glow);
            background: #00ffea;
        }

        .cta-btn.mpv-btn {
            background-color: #1e222b;
            color: #64ffda;
            border: 2px solid #64ffda;
        }
        
        .cta-btn.mpv-btn:hover {
            background-color: #252a36;
            box-shadow: 0 0 12px rgba(100, 255, 218, 0.4);
        }
        
        .cta-btn.python-btn {
            background-color: #2b5b84;
            color: #ffde57;
            border: 2px solid #ffde57;
        }
        
        .cta-btn.python-btn:hover {
            background-color: #356e9e;
            box-shadow: 0 0 12px rgba(255, 222, 87, 0.4);
        }

        .section-title {
            font-size: 1.8rem;
            margin-top: 50px;
            margin-bottom: 25px;
            border-left: 4px solid var(--accent);
            padding-left: 15px;
            letter-spacing: -0.5px;
        }

        /* --- CAROUSEL --- */
        .carousel-wrapper {
            position: relative;
            width: 100%;
            margin-bottom: 40px;
            overflow: hidden;
            padding: 40px 0;
        }

        .carousel-track {
            display: flex;
            gap: 30px;
            padding: 15px 0;
            overflow-x: hidden;
            cursor: grab;
            align-items: center;
            width: 100%;
            scrollbar-width: none;
        }

        .carousel-track::-webkit-scrollbar {
            display: none;
        }

        .carousel-track:active {
            cursor: grabbing;
        }

        .carousel-item {
            flex: 0 0 320px;
            height: 180px;
            border-radius: 14px;
            background: #101520;
            border: 1px solid #1f2a3c;
            position: relative;
            overflow: hidden;
            transition: transform 0.1s ease-out, filter 0.1s ease-out, opacity 0.1s ease-out;
            will-change: transform, filter, opacity;
            transform-origin: center center;
        }

        .carousel-item img {
            width: 100%;
            height: 100%;
            object-fit: cover; 
            pointer-events: none;
            display: none;
        }

        .carousel-item .img-fallback {
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background: linear-gradient(145deg, #0d121d, #182030);
            color: var(--text-muted);
            font-size: 0.85rem;
            text-align: center;
            padding: 15px;
        }

        .carousel-item .img-fallback span {
            color: var(--accent);
            font-weight: 600;
            margin-bottom: 4px;
            font-size: 0.95rem;
        }

        .carousel-item.center-active {
            border-color: var(--accent);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.7), 0 0 20px var(--accent-glow);
            z-index: 5;
        }

        /* --- VIDEO SHOWCASE --- */
        .video-showcase {
            width: 100%;
            max-width: 800px;
            margin: 0 auto 70px auto;
            background: #090d14;
            border: 1px solid #1b2332;
            border-radius: 20px;
            padding: 12px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.7);
        }

        .video-placeholder {
            width: 100%;
            aspect-ratio: 16 / 9;
            background: linear-gradient(135deg, #05070a 0%, #111622 100%);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            position: relative;
            border: 1px dashed #2c384e;
            transition: border-color 0.3s ease;
        }

        .video-placeholder:hover {
            border-color: var(--accent);
        }

        .play-button {
            width: 70px;
            height: 70px;
            background: rgba(0, 0, 0, 0.75);
            border: 2px solid var(--accent);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 15px;
            box-shadow: 0 0 15px var(--accent-glow);
            transition: all 0.3s ease;
        }

        .video-placeholder:hover .play-button svg {
            fill: #000;
        }

        .video-text {
            font-size: 1.1rem;
            font-weight: 600;
            color: #ffffff;
        }

        .video-subtext {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-top: 5px;
        }

        /* --- SHOWCASE INTERACTIVO --- */
        .showcase-section {
            background: rgba(10, 13, 20, 0.5);
            border: 1px solid rgba(25, 32, 46, 0.6);
            border-radius: 24px;
            padding: 40px;
            margin-bottom: 60px;
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
        }

        .showcase-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            align-items: center;
        }

        @media (max-width: 768px) {
            .showcase-layout { grid-template-columns: 1fr; }
            h1 { font-size: 2.3rem; }
            .cta-container { flex-direction: column; gap: 15px; }
            .bg-control-panel { top: auto; bottom: 20px; right: 50%; transform: translateX(50%); }
        }

        .controls-box h3 {
            margin-bottom: 15px;
            font-size: 1.4rem;
        }

        .selector-btn {
            display: block;
            width: 100%;
            background: #121722;
            border: 1px solid #20293a;
            color: var(--text-muted);
            padding: 16px 20px;
            border-radius: 12px;
            text-align: left;
            font-size: 1rem;
            cursor: pointer;
            margin-bottom: 12px;
            transition: all 0.2s ease;
        }

        .selector-btn:hover {
            background: #171e2c;
            color: #fff;
        }

        .selector-btn.active {
            background: rgba(0, 235, 212, 0.08);
            border-color: var(--accent);
            color: var(--accent);
            font-weight: 600;
        }

        /* Simulador de Discord */
        .discord-mock {
            background: var(--discord-profile);
            width: 100%;
            max-width: 380px;
            margin: 0 auto;
            border-radius: 14px;
            padding: 20px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.6);
            border: 1px solid #1e1f22;
        }

        .discord-header {
            font-size: 0.75rem;
            font-weight: 700;
            color: #b5bac1;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 14px;
        }

        .discord-activity {
            display: flex;
            gap: 14px;
        }

        .image-assets {
            position: relative;
            width: 95px;
            height: 135px;
            flex-shrink: 0;
            border-radius: 6px;
            background: #1e1f22;
            box-shadow: 0 4px 12px rgba(0,0,0,0.5);
        }

        .large-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 6px;
            display: block;
        }

        .small-image-container {
            position: absolute;
            bottom: -6px;
            right: -6px;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #004d40;
            border: 4px solid var(--discord-profile);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .small-image-container svg {
            width: 14px;
            height: 14px;
            fill: var(--accent);
            margin-left: 2px;
        }

        .activity-details {
            display: flex;
            flex-direction: column;
            justify-content: top;
            padding-top: 2px;
            overflow: hidden;
            width: 100%;
        }

        .details-title-app {
            font-weight: 700;
            font-size: 0.88rem;
            color: #3ba55d;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .details-title {
            font-weight: 600;
            font-size: 0.95rem;
            color: #f2f3f5;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .details-row {
            font-size: 0.85rem;
            color: #b5bac1;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-top: 3px;
        }

        .discord-timeline-container {
            margin-top: 10px;
            width: 100%;
        }

        .discord-timeline-bar {
            width: 100%;
            height: 4px;
            background: #4e5058;
            border-radius: 2px;
            position: relative;
            margin: 8px 0;
        }

        .discord-timeline-fill {
            height: 100%;
            background: #ffffff;
            width: 35%;
            border-radius: 2px;
            position: relative;
        }

        .discord-timeline-fill::after {
            content: '';
            position: absolute;
            right: -4px;
            top: -2px;
            width: 8px;
            height: 8px;
            background: #ffffff;
            border-radius: 50%;
        }

        .discord-timeline-labels {
            display: flex;
            justify-content: space-between;
            font-size: 0.78rem;
            color: #b5bac1;
            margin-top: 5px;
            font-family: monospace;
        }

        .discord-buttons {
            margin-top: 16px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .discord-btn {
            background: #4e5058;
            color: #fff;
            text-align: center;
            padding: 10px;
            border-radius: 4px;
            font-size: 0.88rem;
            font-weight: 500;
            text-decoration: none;
            transition: background 0.2s, transform 0.1s;
            border: 1px solid transparent;
        }

        .discord-btn:hover { background: #6d6f78; }
        .discord-btn:active { transform: scale(0.98); }

        /* Características inferiores */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-top: 20px;
            margin-bottom: 50px;
        }

        .features-card {
            background: var(--bg-card);
            border: 1px solid rgba(22, 31, 46, 0.6);
            padding: 25px;
            border-radius: 16px;
            transition: all 0.3s ease;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        .features-card:hover { 
            border-color: var(--accent);
            background: var(--bg-card-hover);
            transform: translateY(-2px);
        }

        .features-card h3 {
            font-size: 1.2rem;
            margin-bottom: 10px;
            color: #fff;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        footer.site-footer {
            text-align: center;
            margin-top: 60px;
            padding-top: 24px;
            border-top: 1px solid #161f2e;
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        /* --- CASCADA DE BOTONES MPV CON IDENTIFICADOR SUPERIOR --- */
        .mpv-cascade-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
        }

        /* Letras flotantes e indicador hacia arriba */
        .mpv-win-indicator {
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%) translateY(10px);
            font-size: 0.88rem;
            color: var(--accent);
            font-weight: 700;
            letter-spacing: 0.5px;
            opacity: 0;
            visibility: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            white-space: nowrap;
            pointer-events: none;
            margin-bottom: 8px;
            text-shadow: 0 0 8px var(--accent-glow);
        }

        .mpv-main-btn {
            position: relative;
            z-index: 3;
            width: 100%;
            text-align: center;
        }

        .mpv-sub-btn {
            display: inline-block;
            background-color: #1a1e27;
            color: #64ffda;
            border: 2px solid rgba(100, 255, 218, 0.6);
            text-decoration: none;
            font-weight: 600;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
            cursor: pointer;
            
            position: absolute;
            left: 50%;
            transform: translateX(-50%);
            opacity: 0;
            visibility: hidden;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .mpv-linux-btn { width: 85%; padding: 10px 20px; font-size: 1rem; border-radius: 0 0 20px 20px; top: 0; z-index: 2; }
        .mpv-macos-btn { width: 70%; padding: 8px 15px; font-size: 0.88rem; border-radius: 0 0 16px 16px; top: 0; z-index: 1; border-color: rgba(100, 255, 218, 0.4); }

        /* Estados de hover sincronizados */
        .mpv-cascade-container:hover .mpv-win-indicator {
            opacity: 1;
            visibility: visible;
            transform: translateX(-50%) translateY(0);
        }
        .mpv-cascade-container:hover .mpv-sub-btn { opacity: 1; visibility: visible; }
        .mpv-cascade-container:hover .mpv-linux-btn { top: 100%; margin-top: -14px; }
        .mpv-cascade-container:hover .mpv-macos-btn { top: 100%; margin-top: 22px; }

        .mpv-sub-btn:hover {
            background-color: #232936;
            color: #00ffea;
            border-color: #00ffea;
            box-shadow: 0 0 15px rgba(0, 235, 212, 0.4);
            transform: translateX(-50%) translateY(2px);
        }

        /* Modales */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(4, 5, 8, 0.85);
            backdrop-filter: blur(6px);
            -webkit-backdrop-filter: blur(6px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .modal-overlay.active { opacity: 1; visibility: visible; }

        .modal-content {
            background: #0d1117;
            border: 2px solid var(--accent);
            box-shadow: 0 0 40px rgba(0, 235, 212, 0.15), 0 20px 50px rgba(0,0,0,0.8);
            padding: 35px;
            border-radius: 20px;
            max-width: 550px;
            width: 90%;
            position: relative;
            transform: scale(0.9) translateY(20px);
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .modal-overlay.active .modal-content { transform: scale(1) translateY(0); }
        .modal-close { position: absolute; top: 15px; right: 20px; font-size: 2rem; color: var(--text-muted); cursor: pointer; transition: color 0.2s, transform 0.2s; line-height: 1; }
        .modal-close:hover { color: #ff5555; transform: scale(1.1); }
        .modal-title { font-size: 1.6rem; font-weight: 800; margin-bottom: 22px; border-bottom: 1px solid #1f2a3c; padding-bottom: 12px; color: var(--accent); display: flex; align-items: center; gap: 10px; }
        .command-block { margin-bottom: 18px; }
        .command-label { font-size: 0.92rem; color: #fff; margin-bottom: 6px; font-weight: 600; }
        
        .command-code {
            background: #161b22;
            padding: 14px 16px;
            border-radius: 10px;
            font-family: 'Consolas', 'Courier New', monospace;
            font-size: 0.92rem;
            color: #00ffea;
            border: 1px solid #21262d;
            overflow-x: auto;
            white-space: nowrap;
            -webkit-user-select: text;
            user-select: text;
        }

        @media (prefers-reduced-motion: reduce) { #bg-video { display: none; } }
    </style>
</head>
<body>

    <div class="video-bg-container">
        <video autoplay loop muted playsinline id="bg-video">
            <source src="assets/background.mp4" type="video/mp4">
        </video>
    </div>

    <div class="bg-control-panel">
        <button id="theme-toggle" class="bg-btn" onclick="toggleTheme()" title="Cambiar modo" style="margin-right: 2px; color: var(--text-muted);"></button>
        <button class="bg-btn bg-btn-num active" onclick="selectBackground(0)">1</button>
        <button class="bg-btn bg-btn-num" onclick="selectBackground(1)">2</button>
        <button class="bg-btn bg-btn-num" onclick="selectBackground(2)">3</button>
        <button class="bg-btn bg-btn-num" onclick="selectBackground(3)">4</button>
        <button class="bg-btn bg-btn-num" onclick="selectBackground(4)">5</button>
    </div>

    <div class="container">
        <header>
            <div class="profile-container">
                <img class="profile-img" src="https://github.com/MVP-Savyn.png" alt="MVP-Savyn">
                <span class="profile-name">MVP-Savyn</span>
            </div>
            <h1>Savin-cinema-rpc</h1>
            <p class="tagline">El script de Rich Presence definitivo para MPV. Sincroniza tus reproducciones con carátulas oficiales de TMDb de forma automatizada y con un diseño modular impecable.</p>
        </header>

        <div class="cta-container">
            <a href="https://github.com/MVP-Savyn/Savin-cinemaRPC/releases/latest" class="cta-btn" target="_blank" rel="noopener noreferrer">Descargar última versión</a>
            
            <div class="mpv-cascade-container">
                <span class="mpv-win-indicator">windows</span>
                <a href="https://github.com/shinchiro/mpv-winbuild-cmake/releases/download/20260607/mpv-x86_64-20260607-git-71ebd08.7z" class="cta-btn mpv-btn mpv-main-btn">Descargar MPV Player</a>
                <a id="btn-linux-modal" class="mpv-sub-btn mpv-linux-btn">Para Linux</a>
                <a id="btn-macos-modal" class="mpv-sub-btn mpv-macos-btn">Para macOS</a>
            </div>
            
            <a href="https://www.python.org/downloads/" class="cta-btn python-btn" target="_blank" rel="noopener noreferrer">Descargar Python 3</a>
        </div>

        <h2 class="section-title">Galería de Demostración</h2>
        <div class="carousel-wrapper" id="carouselWrapper">
            <div class="carousel-track" id="carouselTrack"></div>
        </div>

        <div class="video-showcase">
            <div class="video-placeholder">
                <div class="play-button">
                    <svg viewBox="0 0 24 24">
                        <polygon points="8,5 19,12 8,19"></polygon>
                    </svg>
                </div>
                <div class="video-text">Video Demostrativo del Mod</div>
                <div class="video-subtext">[Espacio reservado para tu review/guía de YouTube]</div>
            </div>
        </div>

        <h2 class="section-title">Previsualización Interactiva Completa</h2>
        <div class="showcase-section">
            <div class="showcase-layout">
                <div class="controls-box">
                    <h3>Modos de Visualización</h3>
                    <p style="color: var(--text-muted); margin-bottom: 20px; font-size: 0.95rem;">
                        Alterna entre las opciones estructurales avanzadas del mod. La barra de progreso integrada reproduce fielmente el diseño de las líneas de tiempo de actividad multimedia de Discord (fiel a tu configuración real):
                    </p>
                    
                    <button class="selector-btn active" onclick="updateMock('one_button')">
                        1. Un botón (Info o Github)
                        <span style="display:block; font-size:0.8rem; color:var(--text-muted); margin-top:4px;">Inyecta únicamente el botón de acceso configurado.</span>
                    </button>
                    
                    <button class="selector-btn" onclick="updateMock('two_buttons')">
                        2. Dos botones
                        <span style="display:block; font-size:0.8rem; color:var(--text-muted); margin-top:4px;">Combina el enlace multimedia de TMDb y el código fuente.</span>
                    </button>

                    <button class="selector-btn" onclick="updateMock('minimalist')">
                        3. Minimalista
                        <span style="display:block; font-size:0.8rem; color:var(--text-muted); margin-top:4px;">Oculta la botonera inferior, optimizando el espacio visual de la tarjeta.</span>
                    </button>
                </div>

                <div>
                    <div class="discord-mock">
                        <div class="discord-header">Jugando</div>
                        <div class="discord-activity">
                            <div class="image-assets">
                                <img class="large-image" id="mock-poster" src="assets/interestellar.png" alt="Carátula Interstellar">
                                <div class="small-image-container">
                                    <svg viewBox="0 0 24 24">
                                        <polygon points="8,5 19,12 8,19"></polygon>
                                    </svg>
                                </div>
                            </div>
                            <div class="activity-details">
                                <div class="details-title-app">CINEEE</div>
                                <div class="details-title" id="mock-media-title">Interstellar (2014)</div>
                                
                                <div class="discord-timeline-container">
                                    <div class="discord-timeline-bar">
                                        <div class="discord-timeline-fill"></div>
                                    </div>
                                    <div class="discord-timeline-labels">
                                        <span id="mock-time-start">00:38</span>
                                        <span id="mock-time-end">02:49:00</span>
                                    </div>
                                </div>

                                <div style="font-size: 0.82rem; color: #23a55a; margin-top: 4px; display: flex; align-items: center; gap: 4px;">
                                    <svg style="width:14px; height:14px; fill:#23a55a;" viewBox="0 0 24 24"><path d="M21 6H3c-1.1 0-2 .9-2 2v8c0 1.1.9 2 2 2h18c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm-10 7H8v3H6v-3H3v-2h3V8h2v3h3v2zm4.5 3c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm3-3c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z"/></svg>
                                    <span>0:00</span>
                                </div>
                            </div>
                        </div>
                        <div class="discord-buttons" id="mock-buttons-container"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="features-grid">
            <div class="features-card">
                <h3>🐍 Requisito: Python 3</h3>
                <p>El núcleo del script se ejecuta sobre Python 3. El instalador oficial detecta tu entorno automáticamente para asegurar la comunicación IPC.</p>
            </div>
            <div class="features-card">
                <h3>🧼 Regex Inteligente</h3>
                <p>Purga de forma automatizada etiquetas molestas de ripeo o servidores remotos (1080p, x265, Bluray, dual) para búsquedas perfectas.</p>
            </div>
            <div class="features-card">
                <h3>🌐 Fallback Bilingüe</h3>
                <p>Consulta inteligentemente en Español e Inglés en TMDb. Si falta información en un idioma, se complementa al instante.</p>
            </div>
            <div class="features-card">
                <h3>🍏 Multiplataforma Real</h3>
                <p>Mismo rendimiento optimizado y asistentes automatizados integrados para entornos Linux, macOS y Windows.</p>
            </div>
        </div>

        <footer class="site-footer">
            <p>© 2026 Savin-cinema-rpc. Creado por MVP-Savyn. Entorno de paridad absoluta multiplataforma.</p>
        </footer>
    </div>

    <div class="modal-overlay" id="mpv-installer-modal">
        <div class="modal-content">
            <span class="modal-close" id="modal-close-btn">&times;</span>
            <div id="modal-dynamic-body"></div>
        </div>
    </div>

    <script>
        /* --- INTERACTIVIDAD DE CAMBIO DE VÍDEO DE FONDO CON MODO CLARO/OSCURO --- */
        const darkBgs = ['background.mp4', 'background1.mp4', 'background2.mp4', 'background3.mp4', 'background4.mp4'];
        const lightBgs = ['modoclaro.mp4', 'modoclaro1.mp4', 'modoclaro2.mp4', 'modoclaro3.mp4', 'modoclaro4.mp4'];
        let currentBgIndex = 0;
        let currentTheme = 'dark';

        const moonIcon = `<svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor" style="display:block;"><path d="M12 3c.132 0 .263 0 .393.007a7.5 7.5 0 0 0 7.92 12.446A9 9 0 1 1 12 3z"/></svg>`;
        const sunIcon = `<svg viewBox="0 0 24 24" width="16" height="16" fill="#ffffff" stroke="#ffffff" stroke-width="1.5" stroke-linecap="round" style="display:block;"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>`;

        function applyBackground() {
            const videoElement = document.getElementById('bg-video');
            const videoFile = currentTheme === 'dark' ? darkBgs[currentBgIndex] : lightBgs[currentBgIndex];
            
            if (videoElement) {
                videoElement.style.opacity = '0';
                
                setTimeout(() => {
                    videoElement.src = `assets/${videoFile}`;
                    videoElement.load();
                    
                    videoElement.play().then(() => {
                        videoElement.style.opacity = '0.40';
                    }).catch(err => {
                        console.log("Espera de interacción requerida:", err);
                        videoElement.style.opacity = '0.40';
                    });
                }, 250);
            }

            // Actualizar clase activa en los botones numéricos
            const numButtons = document.querySelectorAll('.bg-control-panel .bg-btn-num');
            numButtons.forEach((btn, idx) => {
                if (idx === currentBgIndex) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });

            // Guardar preferencias en localStorage
            localStorage.setItem('savin_bg_index', currentBgIndex);
            localStorage.setItem('savin_bg_theme', currentTheme);
        }

        function selectBackground(index) {
            currentBgIndex = index;
            applyBackground();
        }

        function toggleTheme() {
            const toggleBtn = document.getElementById('theme-toggle');
            if (currentTheme === 'dark') {
                currentTheme = 'light';
                if (toggleBtn) toggleBtn.innerHTML = sunIcon;
            } else {
                currentTheme = 'dark';
                if (toggleBtn) toggleBtn.innerHTML = moonIcon;
            }
            applyBackground();
        }

        window.addEventListener('DOMContentLoaded', () => {
            const savedIndex = localStorage.getItem('savin_bg_index');
            const savedTheme = localStorage.getItem('savin_bg_theme');
            
            if (savedIndex !== null) {
                currentBgIndex = parseInt(savedIndex, 10);
            }
            if (savedTheme !== null) {
                currentTheme = savedTheme;
            }

            const toggleBtn = document.getElementById('theme-toggle');
            if (toggleBtn) {
                toggleBtn.innerHTML = currentTheme === 'light' ? sunIcon : moonIcon;
            }
            
            applyBackground();
        });


        /* --- LÓGICA DEL CARUSEL INFINITO --- */
        const totalImages = 7;
        const gap = 30;
        const track = document.getElementById('carouselTrack');
        let singleSetWidth = 0;

        function buildCarouselDOM() {
            track.innerHTML = '';
            for (let loop = 0; loop < 3; loop++) {
                for (let i = 1; i <= totalImages; i++) {
                    const item = document.createElement('div');
                    item.className = 'carousel-item';

                    const img = document.createElement('img');
                    img.src = `assets/demo${i}.png`;
                    img.alt = `Demostración ${i}`;
                    
                    const fallback = document.createElement('div');
                    fallback.className = 'img-fallback';
                    fallback.innerHTML = `<span>assets/demo${i}.png</span>Muestra de Rich Presence`;

                    img.onload = function() {
                        this.style.display = 'block';
                        fallback.style.display = 'none';
                        updateCarouselMetrics();
                    };

                    img.onerror = function() {
                        this.style.display = 'none';
                        fallback.style.display = 'flex';
                        updateCarouselMetrics();
                    };

                    item.appendChild(img);
                    item.appendChild(fallback);
                    track.appendChild(item);
                }
            }
        }

        function updateCarouselMetrics() {
            const items = document.querySelectorAll('.carousel-item');
            let total = 0;
            for (let i = 0; i < totalImages && i < items.length; i++) {
                total += items[i].offsetWidth + gap;
            }
            singleSetWidth = total;
        }

        buildCarouselDOM();

        let isDown = false;
        let startX;
        let scrollLeft;

        function updateBatoceraAnimation() {
            const trackRect = track.getBoundingClientRect();
            const trackCenter = trackRect.left + (trackRect.width / 2);
            const items = document.querySelectorAll('.carousel-item');
            
            items.forEach(item => {
                const itemRect = item.getBoundingClientRect();
                const itemCenter = itemRect.left + (itemRect.width / 2);
                
                const distanceFromCenter = Math.abs(trackCenter - itemCenter);
                const maxInfluenceRadius = 380;
                
                let influenceRatio = 1 - Math.min(1, distanceFromCenter / maxInfluenceRadius);
                influenceRatio = Math.pow(influenceRatio, 2);
                
                const scale = 0.86 + (0.26 * influenceRatio);       
                const opacity = 0.45 + (0.55 * influenceRatio);    
                const blur = 2.5 * (1 - influenceRatio);           
                const grayscale = 60 * (1 - influenceRatio);       
                
                item.style.transform = `scale(${scale})`;
                item.style.opacity = opacity;
                item.style.filter = `blur(${blur}px) grayscale(${grayscale}%)`;
                
                if (distanceFromCenter < (item.offsetWidth / 2)) {
                    item.classList.add('center-active');
                } else {
                    item.classList.remove('center-active');
                }
            });
        }

        window.addEventListener('load', () => {
            setTimeout(() => {
                updateCarouselMetrics();
                track.scrollLeft = singleSetWidth;
                updateBatoceraAnimation();
            }, 100);
        });

        track.addEventListener('mousedown', (e) => {
            isDown = true;
            track.style.transition = 'none';
            startX = e.pageX - track.offsetLeft;
            scrollLeft = track.scrollLeft;
        });

        track.addEventListener('mouseleave', () => { if (!isDown) return; isDown = false; snapToCenterSmooth(); });
        track.addEventListener('mouseup', () => { if (!isDown) return; isDown = false; snapToCenterSmooth(); });

        track.addEventListener('mousemove', (e) => {
            if(!isDown) return;
            e.preventDefault();
            const x = e.pageX - track.offsetLeft;
            const walk = (x - startX) * 1.5; 
            track.scrollLeft = scrollLeft - walk;
            handleInfiniteLoopBounds();
            updateBatoceraAnimation();
        });

        track.addEventListener('touchstart', (e) => {
            isDown = true;
            startX = e.touches[0].pageX - track.offsetLeft;
            scrollLeft = track.scrollLeft;
        });
        
        track.addEventListener('touchend', () => { isDown = false; snapToCenterSmooth(); });
        
        track.addEventListener('touchmove', (e) => {
            if(!isDown) return;
            const x = e.touches[0].pageX - track.offsetLeft;
            const walk = (x - startX) * 1.5;
            track.scrollLeft = scrollLeft - walk;
            handleInfiniteLoopBounds();
            updateBatoceraAnimation();
        });

        function handleInfiniteLoopBounds() {
            if (singleSetWidth === 0) return;
            if (track.scrollLeft >= singleSetWidth * 2) {
                track.scrollLeft -= singleSetWidth;
            } else if (track.scrollLeft <= 0) {
                track.scrollLeft += singleSetWidth;
            }
        }

        function snapToCenterSmooth() {
            const activeItem = document.querySelector('.carousel-item.center-active');
            if (activeItem) {
                const trackCenter = track.offsetWidth / 2;
                const itemCenter = activeItem.offsetLeft + (activeItem.offsetWidth / 2);
                track.scrollTo({ left: itemCenter - trackCenter, behavior: 'smooth' });
            }
        }

        track.addEventListener('scroll', () => {
            handleInfiniteLoopBounds();
            updateBatoceraAnimation();
        });

        /* --- CONTROL DE MOCK DE DISCORD --- */
        function updateMock(mode) {
            const buttons = document.querySelectorAll('.selector-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
                
            if(mode === 'one_button') buttons[0].classList.add('active');
            if(mode === 'two_buttons') buttons[1].classList.add('active');
            if(mode === 'minimalist') buttons[2].classList.add('active');
                
            const btnContainer = document.getElementById('mock-buttons-container');
        
            if (mode === 'one_button') {
                btnContainer.innerHTML = `<a href="https://www.themoviedb.org/movie/157336-interstellar" target="_blank" class="discord-btn">Ver información</a>`;
            } else if (mode === 'two_buttons') {
                btnContainer.innerHTML = `
                    <a href="https://www.themoviedb.org/movie/157336-interstellar" target="_blank" class="discord-btn">Ver información</a>
                    <a href="https://github.com/MVP-Savyn/Savin-cinemaRPC" target="_blank" class="discord-btn">Savin-CinemaRPC</a>
                `;
            } else if (mode === 'minimalist') {
                btnContainer.innerHTML = ""; 
            }
        }
        updateMock('one_button');

        /* --- ASISTENCIA DE MODALES MULTIPLATAFORMA --- */
        const modalOverlay = document.getElementById('mpv-installer-modal');
        const modalCloseBtn = document.getElementById('modal-close-btn');
        const modalDynamicBody = document.getElementById('modal-dynamic-body');
        const btnLinuxModal = document.getElementById('btn-linux-modal');
        const btnMacosModal = document.getElementById('btn-macos-modal');

        const linuxTemplate = `
            <h3 class="modal-title">Instalación en Linux</h3>
            <div class="command-block">
                <div class="command-label">Ubuntu / Debian / Linux Mint:</div>
                <div class="command-code">sudo apt update && sudo apt install mpv</div>
            </div>
            <div class="command-block">
                <div class="command-label">Arch Linux / Manjaro:</div>
                <div class="command-code">sudo pacman -S mpv</div>
            </div>
            <div class="command-block">
                <div class="command-label">Fedora:</div>
                <div class="command-code">sudo dnf install mpv</div>
            </div>
            <div class="command-block">
                <div class="command-label">Paquete Universal (Flatpak):</div>
                <div class="command-code">flatpak install flathub io.mpv.Mpv</div>
            </div>
        `;

        const macosTemplate = `
            <h3 class="modal-title">Instalación en macOS</h3>
            <div class="command-block">
                <div class="command-label">Comando de instalación estándar:</div>
                <div class="command-code">brew install mpv</div>
            </div>
            <div class="command-block" style="margin-top: 25px; border-top: 1px dashed #21262d; padding-top: 20px;">
                <div class="command-label" style="color: #ff5555; display:flex; align-items:center; gap:6px;">¿Te da error porque no tienes instalado Homebrew?</div>
                <div class="command-label" style="color: var(--text-muted); font-weight: normal; font-size: 0.88rem; margin-top: 4px; margin-bottom: 8px;">Ejecuta primero esta línea en tu terminal para instalar el gestor:</div>
                <div class="command-code" style="color: #ffbe0b; font-size: 0.85rem; white-space: normal; word-break: break-all;">/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"</div>
            </div>
        `;

        btnLinuxModal.addEventListener('click', () => { modalDynamicBody.innerHTML = linuxTemplate; modalOverlay.classList.add('active'); });
        btnMacosModal.addEventListener('click', () => { modalDynamicBody.innerHTML = macosTemplate; modalOverlay.classList.add('active'); });
        modalCloseBtn.addEventListener('click', () => { modalOverlay.classList.remove('active'); });
        window.addEventListener('click', (e) => { if (e.target === modalOverlay) { modalOverlay.classList.remove('active'); } });
    </script>
</body>
</html>