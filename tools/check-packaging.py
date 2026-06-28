#!/usr/bin/env python3
"""Garde-fou d'empaquetage.

Vérifie que chaque fichier .lua/.xml référencé comme ligne de chargement dans
WhatTodo.toc figure bien dans la liste ADDON_FILES (passée en arguments par le
Makefile). Empêche le bug « fichier présent dans le .toc mais absent du zip ».

Vérification uni-directionnelle (toc sous-ensemble de ADDON_FILES) : ADDON_FILES
contient légitimement des fichiers non listés comme lignes de script dans le .toc
(Textures/icon.tga via ## IconTexture), et le contenu interne de Libs/ est chargé
par Libs/embeds.xml, pas listé un à un dans le .toc.
"""
import sys

TOC = "WhatTodo.toc"


def toc_script_refs(path):
    refs = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("##"):
                continue
            ref = line.replace("\\", "/")
            if ref.lower().endswith((".lua", ".xml")):
                refs.append(ref)
    return refs


def main(addon_files):
    packaged = set(addon_files)
    missing = [r for r in toc_script_refs(TOC) if r not in packaged]
    if missing:
        sys.exit(
            "Erreur d'empaquetage : fichiers du .toc absents de ADDON_FILES : "
            + ", ".join(missing)
        )


if __name__ == "__main__":
    main(sys.argv[1:])
