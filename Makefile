.DEFAULT_GOAL := help

# Override if your sources live elsewhere (LOOK_SOURCES_DIR).
SOURCES_DIR ?= $(HOME)/.look/sources
BIN_DIR     ?= $(HOME)/.look/bin

EXAMPLES := $(notdir $(wildcard examples/*))

.PHONY: help new check install uninstall list

help:
	@echo "lookbook"
	@echo
	@echo "  make new NAME=tmux       scaffold examples/tmux from the template"
	@echo "  make check               parse every example with Look's own parser"
	@echo "  make install NAME=git    copy an example into $(SOURCES_DIR)"
	@echo "  make install             copy every example there"
	@echo "  make uninstall NAME=git  remove it again"
	@echo "  make list                what is in here"
	@echo
	@echo "Reload Look after installing: Cmd+Shift+; (macOS), Ctrl+Shift+; (Linux, Windows)"

# Everything already renamed: folder, file, block ids, README, index row.
new:
	@./scripts/new.sh "$(NAME)"

# Parses. Never runs your commands, so install it and use it before committing.
check:
	@./scripts/check.sh

install:
	@mkdir -p "$(SOURCES_DIR)"
ifeq ($(NAME),)
	@cp examples/*/*.toml "$(SOURCES_DIR)/"
	@echo "installed every example into $(SOURCES_DIR)"
else
	@test -d "examples/$(NAME)" || { echo "no examples/$(NAME) (make list)"; exit 1; }
	@cp examples/$(NAME)/*.toml "$(SOURCES_DIR)/"
	@if [ -d "examples/$(NAME)/bin" ]; then \
		mkdir -p "$(BIN_DIR)"; \
		cp examples/$(NAME)/bin/* "$(BIN_DIR)/"; \
		chmod +x "$(BIN_DIR)"/*; \
		echo "installed examples/$(NAME) into $(SOURCES_DIR), scripts into $(BIN_DIR)"; \
	else \
		echo "installed examples/$(NAME) into $(SOURCES_DIR)"; \
	fi
endif
	@echo "reload Look to pick it up"

uninstall:
	@test -n "$(NAME)" || { echo "usage: make uninstall NAME=git"; exit 1; }
	@test -d "examples/$(NAME)" || { echo "no examples/$(NAME) (make list)"; exit 1; }
	@for file in examples/$(NAME)/*.toml; do rm -f "$(SOURCES_DIR)/$$(basename "$$file")"; done
	@echo "removed examples/$(NAME) from $(SOURCES_DIR); reload Look"

list:
	@for name in $(EXAMPLES); do \
		printf '%-14s %s\n' "$$name" "$$(ls examples/$$name/*.toml | wc -l | tr -d ' ') file(s)"; \
	done
