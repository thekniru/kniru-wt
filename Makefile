# Git Worktree Manager Makefile
# Installation and management tasks

VERSION := $(shell cat VERSION)
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
SHAREDIR := $(PREFIX)/share/wt
MANDIR := $(PREFIX)/share/man/man1
COMPLETIONDIR := $(SHAREDIR)/completions

# Detect shell for completions
SHELL_TYPE := $(shell echo $$SHELL | grep -o '[^/]*$$')

.PHONY: all install uninstall test clean release homebrew-formula

all: test

install:
	@echo "Installing wt $(VERSION)..."
	@mkdir -p $(BINDIR)
	@mkdir -p $(SHAREDIR)
	@mkdir -p $(MANDIR)
	@mkdir -p $(COMPLETIONDIR)
	
	# Install binaries
	@install -m 755 bin/wt $(BINDIR)/wt
	@install -m 755 bin/wt-utils $(BINDIR)/wt-utils
	
	# Install completions
	@install -m 644 completions/wt.bash $(COMPLETIONDIR)/wt.bash
	@install -m 644 completions/wt.zsh $(COMPLETIONDIR)/_wt
	@install -m 644 completions/wt.fish $(COMPLETIONDIR)/wt.fish
	
	# Install man pages
	@install -m 644 docs/wt.1 $(MANDIR)/wt.1
	@install -m 644 docs/wt-utils.1 $(MANDIR)/wt-utils.1
	
	# Install documentation
	@install -m 644 README.md $(SHAREDIR)/README.md
	@install -m 644 LICENSE $(SHAREDIR)/LICENSE
	
	@echo "✓ Installation complete!"
	@echo ""
	@echo "To enable completions, add to your shell config:"
	@echo "  Bash: source $(COMPLETIONDIR)/wt.bash"
	@echo "  Zsh:  fpath=($(COMPLETIONDIR) $$fpath)"
	@echo "  Fish: source $(COMPLETIONDIR)/wt.fish"

uninstall:
	@echo "Uninstalling wt..."
	@rm -f $(BINDIR)/wt
	@rm -f $(BINDIR)/wt-utils
	@rm -rf $(SHAREDIR)
	@rm -f $(MANDIR)/wt.1
	@rm -f $(MANDIR)/wt-utils.1
	@echo "✓ Uninstall complete!"

test:
	@echo "Running tests..."
	@bash tests/simple_test.sh

clean:
	@echo "Cleaning up..."
	@rm -rf dist/
	@rm -f *.tar.gz
	@echo "✓ Clean complete!"

release: clean test
	@echo "Creating release $(VERSION)..."
	@mkdir -p dist
	@tar -czf dist/wt-$(VERSION).tar.gz \
		--exclude='.git*' \
		--exclude='dist' \
		--exclude='*.tar.gz' \
		.
	@echo "✓ Release package created: dist/wt-$(VERSION).tar.gz"
	@echo ""
	@echo "Next steps:"
	@echo "1. Create git tag: git tag -a v$(VERSION) -m 'Release $(VERSION)'"
	@echo "2. Push tag: git push origin v$(VERSION)"
	@echo "3. Create GitHub release and upload dist/wt-$(VERSION).tar.gz"

homebrew-formula:
	@echo "Generating Homebrew formula..."
	@scripts/generate_formula.sh $(VERSION)
	@echo "✓ Formula generated: wt.rb"
	@echo ""
	@echo "To publish:"
	@echo "1. Fork homebrew/homebrew-core"
	@echo "2. Copy wt.rb to Formula/"
	@echo "3. Create pull request"

check-version:
	@echo "Current version: $(VERSION)"

bump-version:
	@echo "Current version: $(VERSION)"
	@echo -n "New version: "
	@read NEW_VERSION && echo $$NEW_VERSION > VERSION
	@echo "Version updated to $$(cat VERSION)"

lint:
	@echo "Running shellcheck..."
	@shellcheck bin/wt bin/wt-utils tests/*.sh scripts/*.sh || true
	@echo "✓ Lint complete!"

dev-install:
	@echo "Installing for development..."
	@ln -sf $$(pwd)/bin/wt $(HOME)/bin/wt
	@ln -sf $$(pwd)/bin/wt-utils $(HOME)/bin/wt-utils
	@echo "✓ Development links created!"

help:
	@echo "Git Worktree Manager - Makefile targets"
	@echo ""
	@echo "  make install         Install wt system-wide"
	@echo "  make uninstall       Remove wt from system"
	@echo "  make test            Run test suite"
	@echo "  make clean           Clean build artifacts"
	@echo "  make release         Create release package"
	@echo "  make homebrew-formula Generate Homebrew formula"
	@echo "  make lint            Run shellcheck on scripts"
	@echo "  make dev-install     Install symlinks for development"
	@echo "  make help            Show this help message"