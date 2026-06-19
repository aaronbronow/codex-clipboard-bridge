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

.PHONY: release clean
release:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Usage: make release VERSION=1.0.0"; \
		exit 1; \
	fi
	@echo "Verifying tests pass..."
	@$(MAKE) test
	@echo "Bumping version to $(VERSION) in .codex-plugin/plugin.json..."
	@sed -i 's/"version": "[^"]*"/"version": "$(VERSION)"/' .codex-plugin/plugin.json
	@echo "Committing version bump..."
	@git add .codex-plugin/plugin.json
	@git diff-index --quiet HEAD .codex-plugin/plugin.json || git commit -m "bump: version $(VERSION)"
	@echo "Pushing changes to remote..."
	@git push origin main
	@echo "Tagging release v$(VERSION)..."
	@git tag -a v$(VERSION) -m "Release v$(VERSION)"
	@git push origin v$(VERSION)
	@echo "Creating GitHub release v$(VERSION)..."
	@printf "Codex Clipboard Bridge v$(VERSION)\n\n## Installation & Update Instructions\n\n### 📥 Install Command\n\`\`\`bash\ncodex plugin marketplace add aaronbronow/codex-clipboard-bridge\n/plugin install codex-clipboard-bridge\n\`\`\`\n" > .release-notes.tmp
	@gh release create v$(VERSION) -F .release-notes.tmp -t "v$(VERSION)"
	@rm -f .release-notes.tmp
	@echo "Release v$(VERSION) successfully created!"

clean:
	rm -rf tests/
	rm -f clipboard_debug.log .release-notes.tmp
