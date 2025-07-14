#!/usr/bin/env bash

# Generate Homebrew formula for wt
# Usage: ./generate_formula.sh <version>

set -euo pipefail

VERSION="${1:-$(cat VERSION)}"
REPO_URL="https://github.com/kniru/wt"
TARBALL_URL="${REPO_URL}/archive/v${VERSION}.tar.gz"

# Calculate SHA256 (this would be done after creating the release)
# For now, we'll use a placeholder
SHA256="PLACEHOLDER_SHA256"

cat > wt.rb << EOF
class Wt < Formula
  desc "World-class CLI tool for managing Git worktrees"
  homepage "${REPO_URL}"
  url "${TARBALL_URL}"
  sha256 "${SHA256}"
  license "MIT"
  head "${REPO_URL}.git", branch: "main"

  depends_on "git"

  def install
    bin.install "bin/wt"
    bin.install "bin/wt-utils"

    # Install completions
    bash_completion.install "completions/wt.bash" => "wt"
    zsh_completion.install "completions/wt.zsh" => "_wt"
    fish_completion.install "completions/wt.fish"

    # Install man pages
    man1.install "docs/wt.1"
    man1.install "docs/wt-utils.1"

    # Install documentation
    doc.install "README.md"
    doc.install "LICENSE"
  end

  def caveats
    <<~EOS
      To use the wt-utils functions, add this to your shell config:
        source #{opt_bin}/wt-utils

      Configuration file can be created at:
        ~/.wtrc

      Example configuration:
        DEFAULT_BASE_BRANCH="develop"
        EDITOR_COMMAND="code"
    EOS
  end

  test do
    system "#{bin}/wt", "help"
    
    # Test in a git repo
    system "git", "init", "test-repo"
    Dir.chdir("test-repo") do
      system "git", "config", "user.email", "test@example.com"
      system "git", "config", "user.name", "Test User"
      system "git", "commit", "--allow-empty", "-m", "Initial commit"
      
      # Test worktree creation
      system "#{bin}/wt", "test-branch", "-n"
      assert_predicate testpath/"test-repo-worktrees/test-branch", :exist?
    end
  end
end
EOF

echo "Formula generated: wt.rb"
echo ""
echo "After creating the release:"
echo "1. Download the tarball: curl -L ${TARBALL_URL} -o wt-${VERSION}.tar.gz"
echo "2. Calculate SHA256: shasum -a 256 wt-${VERSION}.tar.gz"
echo "3. Update the SHA256 in wt.rb"
echo "4. Test locally: brew install --build-from-source ./wt.rb"