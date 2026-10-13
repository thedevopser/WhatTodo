NAME     := WhatTodo
DEST_DIR := $(HOME)/addons/versions
VERSION  := $(shell git describe --tags --abbrev=0 2>/dev/null)

TEST_IMAGE  := whattodo-test
DOCKER_RUN  := docker run --rm -v "$(CURDIR)":/addon $(TEST_IMAGE)
LUA_SOURCES := WhatTodo.lua $(wildcard Core/*.lua UI/*.lua Locales/*.lua tests/*.lua)

# Fichiers du code addon, listés explicitement (garde-fou check-packaging).
# Libs/ est ajouté récursivement au zip (Ace3 ≈ 40 fichiers chargés via
# Libs/embeds.xml, non listés un à un dans le .toc).
ADDON_FILES := \
	WhatTodo.toc \
	WhatTodo.lua \
	Locales/enUS.lua \
	Locales/frFR.lua \
	Core/Reset.lua \
	Core/Migrations.lua \
	Core/Themes.lua \
	Core/DisplaySettings.lua \
	Core/Tasks.lua \
	Core/SeasonTemplates.lua \
	Core/Changelog.lua \
	UI/AdminPanel.lua \
	UI/Display.lua \
	UI/Options.lua \
	UI/Minimap.lua \
	UI/ChangelogPopup.lua \
	Libs/embeds.xml \
	Textures/icon.tga

.PHONY: zip help image syntax lint test check-packaging check-version check

image:
	docker build -q -t $(TEST_IMAGE) - < Dockerfile.test

syntax: image
	$(DOCKER_RUN) luac5.1 -p $(LUA_SOURCES)

lint: image
	$(DOCKER_RUN) luacheck .

test: image
	$(DOCKER_RUN) busted --pattern _test tests/
	python3 -m unittest discover -s tests/tools

check-packaging:
	python3 tools/check-packaging.py $(ADDON_FILES)

check-version:
	python3 tools/check-version.py

check: syntax lint test check-packaging check-version

zip: check-packaging
	@[ -n "$(VERSION)" ] || { echo "Erreur : aucun tag git trouvé. Exemple : git tag v1.0.0"; exit 1; }
	@mkdir -p "$(DEST_DIR)"
	@python3 -c "\
import os, zipfile; \
name = '$(NAME)'; \
dest = '$(DEST_DIR)/$(NAME)-$(VERSION).zip'; \
files = '$(ADDON_FILES)'.split(); \
libs = [os.path.join(dp, f) for dp, _, fs in os.walk('Libs') for f in fs]; \
seen = set(); \
zf = zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED); \
[ (zf.write(p, name + '/' + p), seen.add(p)) for p in files + libs if p not in seen ]; \
zf.close(); \
print('->', dest)"

help:
	@echo "Usage:"
	@echo "  make check            # every check below, as run by the CI"
	@echo "  make syntax           # compile every Lua source without running it"
	@echo "  make lint             # run luacheck"
	@echo "  make test             # run the Busted suite and the tests of tools/"
	@echo "  make check-packaging  # check that every file of the .toc is packaged"
	@echo "  make check-version    # check that the version numbers are consistent"
	@echo "  make image            # build the Docker image used by syntax, lint and test"
	@echo "  git tag v1.0.0 && make zip   # build \$$HOME/addons/versions/$(NAME)-v1.0.0.zip"
