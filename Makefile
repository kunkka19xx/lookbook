.DEFAULT_GOAL := help

# Override if your sources live elsewhere (LOOK_SOURCES_DIR).
SOURCES_DIR ?= $(HOME)/.look/sources
BIN_DIR     ?= $(HOME)/.look/bin
LAYOUT_FILE ?= $(HOME)/.look/super-actions.toml

SOURCE_NAMES := $(notdir $(wildcard sources/*))
TILE_NAMES   := $(filter-out README.md,$(notdir $(wildcard tiles/*)))

.PHONY: help new new-tile check install uninstall show list

help:
	@echo "lookbook"
	@echo
	@echo "  sources -> $(SOURCES_DIR)"
	@echo
	@echo "  make new NAME=tmux       scaffold sources/tmux from the template"
	@echo "  make install NAME=git    copy a source into $(SOURCES_DIR)"
	@echo "  make install             copy every source there"
	@echo "  make uninstall NAME=git  remove it again"
	@echo
	@echo "  tiles -> $(LAYOUT_FILE), by hand"
	@echo
	@echo "  make new-tile NAME=disk  scaffold tiles/disk from the template"
	@echo "  make show NAME=disk      print the block to paste, and where"
	@echo
	@echo "  make check               check everything against CONTRIBUTING"
	@echo "  make check NAME=tmux     check just that one"
	@echo "  make list                what is in here"
	@echo
	@echo "Reload Look after either: Cmd+Shift+; (macOS), Ctrl+Shift+; (Linux, Windows)"

# Everything already renamed: folder, file, block ids, README, index row.
new:
	@./scripts/new.sh source "$(NAME)"

new-tile:
	@./scripts/new.sh tile "$(NAME)"

# Reads. Never runs your commands, so install it and use it before committing.
check:
	@./scripts/check.sh $(NAME)

install:
	@mkdir -p "$(SOURCES_DIR)"
ifeq ($(NAME),)
	@cp sources/*/*.toml "$(SOURCES_DIR)/"
	@echo "installed every source into $(SOURCES_DIR)"
else
	@test -d "sources/$(NAME)" || { \
		test -d "tiles/$(NAME)" \
			&& echo "$(NAME) is a tile: it is merged into $(LAYOUT_FILE), not copied. Try make show NAME=$(NAME)" \
			|| echo "no sources/$(NAME) (make list)"; \
		exit 1; }
	@cp sources/$(NAME)/*.toml "$(SOURCES_DIR)/"
	@if [ -d "sources/$(NAME)/bin" ]; then \
		mkdir -p "$(BIN_DIR)"; \
		cp sources/$(NAME)/bin/* "$(BIN_DIR)/"; \
		chmod +x "$(BIN_DIR)"/*; \
		echo "installed sources/$(NAME) into $(SOURCES_DIR), scripts into $(BIN_DIR)"; \
	else \
		echo "installed sources/$(NAME) into $(SOURCES_DIR)"; \
	fi
endif
	@echo "reload Look to pick it up, and open the .toml first: its paths and apps are the author's"

uninstall:
	@test -n "$(NAME)" || { echo "usage: make uninstall NAME=git"; exit 1; }
	@test -d "sources/$(NAME)" || { echo "no sources/$(NAME) (make list)"; exit 1; }
	@for file in sources/$(NAME)/*.toml; do rm -f "$(SOURCES_DIR)/$$(basename "$$file")"; done
	@echo "removed sources/$(NAME) from $(SOURCES_DIR); reload Look"

# Tiles are merged, not copied: $(LAYOUT_FILE) holds the whole strip, and a
# script that edited it would be rearranging tiles the user placed. So this
# prints what to paste and leaves the editing to them.
show:
	@test -n "$(NAME)" || { echo "usage: make show NAME=disk"; exit 1; }
	@test -d "tiles/$(NAME)" || { \
		test -d "sources/$(NAME)" \
			&& echo "$(NAME) is a source: make install NAME=$(NAME)" \
			|| echo "no tiles/$(NAME) (make list)"; \
		exit 1; }
	@echo "# 1. put \"$(NAME)\" somewhere in the layout drawing in $(LAYOUT_FILE)"
	@echo "# 2. paste the block below onto the end of that file"
	@echo "# 3. reload Look"
	@echo
	@cat tiles/$(NAME)/*.toml
	@echo
	@echo "# tiles/$(NAME)/README.md has the platform notes and what to change"

list:
	@echo "sources -> $(SOURCES_DIR)"
	@for name in $(SOURCE_NAMES); do \
		printf '  %-16s %s file(s)\n' "$$name" "$$(ls sources/$$name/*.toml | wc -l | tr -d ' ')"; \
	done
	@echo
	@echo "tiles -> $(LAYOUT_FILE), merged by hand"
	@for name in $(TILE_NAMES); do \
		printf '  %-16s %s file(s)\n' "$$name" "$$(ls tiles/$$name/*.toml | wc -l | tr -d ' ')"; \
	done
