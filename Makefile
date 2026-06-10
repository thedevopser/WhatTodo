NAME     := WhatTodo
DEST_DIR := $(HOME)/addons/versions
VERSION  := $(shell git describe --tags --abbrev=0 2>/dev/null)

# Racines embarquées dans le zip (fichier explicite ou dossier parcouru récursivement).
# Tout le reste (docs, Makefile, CHANGELOG, README, LICENSE, .git…) est exclu.
INCLUDE := WhatTodo.toc WhatTodo.lua Locales Core UI Textures Libs

.PHONY: zip help

zip:
	@[ -n "$(VERSION)" ] || { echo "Erreur : aucun tag git trouvé. Exemple : git tag v1.0.0"; exit 1; }
	@mkdir -p "$(DEST_DIR)"
	@python3 -c "\
import os, zipfile; \
name = '$(NAME)'; \
dest = '$(DEST_DIR)/$(NAME)-$(VERSION).zip'; \
roots = '$(INCLUDE)'.split(); \
walk = lambda r: [r] if os.path.isfile(r) else [os.path.join(dp, f) for dp, _, fs in os.walk(r) for f in fs]; \
zf = zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED); \
[zf.write(p, name + '/' + p) for r in roots for p in walk(r)]; \
zf.close(); \
print('->', dest)"

help:
	@echo "Usage:"
	@echo "  git tag v1.0.0   # créer un tag"
	@echo "  make zip         # génère \$$HOME/addons/versions/$(NAME)-v1.0.0.zip"
