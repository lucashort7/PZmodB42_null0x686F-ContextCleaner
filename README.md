# HortWiz Context Cleaner

![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-B42-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Performance](https://img.shields.io/badge/Performance-O(1)-brightgreen)

Limpador de menu de contexto $O(1)$, standalone, para Project Zomboid Build 42. Esconda opções inúteis do menu de contexto em tempo real, sem lag (monkeypatch nativo em `ISContextMenu:addOption`).

## Requer
- **HortWiz Core** (dependência obrigatória — logger e utilitários compartilhados).

## Features
- Filtragem síncrona de menu de contexto em `OnFillInventoryObjectContextMenu` e `OnFillWorldObjectContextMenu`.
- Zero-GC allocations durante a renderização do menu.
- Regras configuráveis via UI nativa / ModOptions — esconder (`Hide List`) ou dobrar em submenu (`Fold List`), com suporte a wildcard e Lua pattern.
- Presets salvos em disco (`Zomboid/Lua/ContextCleaner_preset_default.txt`).
- Keybind nativo (`Numpad 7` por padrão) pra abrir a janela de configuração.

## Instalação (Manual)
1. Baixe o último `.zip` da aba [Releases](../../releases).
2. Extraia a pasta `hortWiz_ContextCleaner` dentro de `C:\Users\SEU_USUARIO\Zomboid\mods\`.
3. Instale também o **HortWiz Core** (dependência).
4. Ative os dois mods no menu principal do jogo.

## Contribuição
Leia o [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar Pull Requests. Nós levamos a performance MUITO a sério. Qualquer código com *Vibe Coding* (loops desnecessários no render) será rejeitado.
