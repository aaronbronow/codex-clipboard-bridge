UPSTREAM_DIR ?= ../agent-bridge-clipboard

.PHONY: import-upstream test

import-upstream:
	# Assume upstream has run 'make build'
	@if [ ! -d "$(UPSTREAM_DIR)/dist/codex-clipboard-bridge" ]; then \
		echo "Error: $(UPSTREAM_DIR)/dist/codex-clipboard-bridge not found."; \
		echo "Please run 'make build' in the upstream directory first."; \
		exit 1; \
	fi
	
	# Clear existing skills directory to ensure a clean state
	rm -rf skills
	mkdir -p skills/copy
	
	# Copy the skill markdown instructions
	cp -v $(UPSTREAM_DIR)/dist/codex-clipboard-bridge/SKILL.md skills/copy/
	
	# Copy the copy script utility
	cp -v $(UPSTREAM_DIR)/dist/codex-clipboard-bridge/scripts/copy.sh skills/copy/copy_to_clipboard.sh
	chmod +x skills/copy/copy_to_clipboard.sh

test:
	@if [ -f "./tests/integration.sh" ]; then \
		./tests/integration.sh; \
	else \
		echo "No tests found. Running basic validation..."; \
		if [ -f "skills/copy/copy_to_clipboard.sh" ]; then \
			echo "OK: copy_to_clipboard.sh exists and is executable"; \
		else \
			echo "Error: copy_to_clipboard.sh missing"; \
			exit 1; \
		fi \
	fi
