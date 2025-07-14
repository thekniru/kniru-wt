class Wt < Formula
  desc "World-class CLI tool for managing Git worktrees"
  homepage "https://github.com/thekniru/kniru-wt"
  url "https://github.com/thekniru/kniru-wt/archive/v1.0.0.tar.gz"
  sha256 "7d5fa31a3f7c7736b85fa2c03efa12e0c030dbf689ce3f018ebf875fa9bcab74"
  license "Apache-2.0"
  head "https://github.com/thekniru/kniru-wt.git", branch: "main"

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
