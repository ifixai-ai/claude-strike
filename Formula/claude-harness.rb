# SPDX-License-Identifier: MIT
class ClaudeHarness < Formula
  desc "Curated Claude Code harness: behavioural contract, 13 agents, spec-kit glue"
  homepage "https://github.com/n-papaioannou/claude-harness"
  license "MIT"

  # When v0.1.0 ships, uncomment this block and fill in the sha256 from
  # `shasum -a 256 <(curl -fsSL https://github.com/n-papaioannou/claude-harness/archive/refs/tags/v0.1.0.tar.gz)`
  #
  # url "https://github.com/n-papaioannou/claude-harness/archive/refs/tags/v0.1.0.tar.gz"
  # sha256 "<replace-with-sha256-of-v0.1.0-tarball>"
  # version "0.1.0"

  head "https://github.com/n-papaioannou/claude-harness.git", branch: "main"

  depends_on "bash"
  depends_on "git"

  def install
    libexec.install Dir["*"]
    (bin/"claude-harness").write <<~SH
      #!/usr/bin/env bash
      exec "#{libexec}/setup.sh" "$@"
    SH
    (bin/"claude-harness").chmod 0755
  end

  def caveats
    <<~EOS
      claude-harness installs the `claude-harness` command. To use it:

        claude-harness                       # global install to ~/.claude/
        claude-harness --project             # project install into ./ + spec-kit init
        claude-harness --project --no-spec-kit

      Spec-kit init requires `uv` on PATH (`brew install uv`) and a `.git/` in
      the target directory. Missing `uv` does not block the agents/CLAUDE.md
      install — it just skips `specify init` with a warning.

      To uninstall the files written into ~/.claude/ or ./.claude/, run the
      matching `uninstall.sh` that ships with the harness:

        #{opt_libexec}/uninstall.sh          # global
        #{opt_libexec}/uninstall.sh --project # project
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/claude-harness --help 2>&1", 2)
  end
end
