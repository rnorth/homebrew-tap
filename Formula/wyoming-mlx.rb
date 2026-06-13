class WyomingMlx < Formula
  desc "Apple-Silicon-native TTS and STT for Home Assistant and OpenAI clients"
  homepage "https://github.com/rnorth/wyoming-mlx"
  url "https://github.com/rnorth/wyoming-mlx/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "ad2206211e3d5389623dc967682d429b78b5202614a10b9f0b614678e8df6bc8"
  license "Apache-2.0"
  revision 1

  depends_on "uv" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.12"

  def install
    uv = Formula["uv"].opt_bin/"uv"
    system uv, "venv", libexec, "--python", Formula["python@3.12"].opt_bin/"python3.12"
    system uv, "pip", "install", "--python", libexec/"bin/python", "--no-cache", buildpath.to_s
    # Kokoro's English G2P (misaki) needs spaCy's en_core_web_sm model. Without it,
    # misaki pip-installs the model at first synth — which fails in the read-only
    # Cellar venv under the llmsvc daemon, so every English TTS call dies after the
    # WAV header. Install it now. The venv has no pip (uv venv is unseeded), so we
    # install the model wheel directly instead of `python -m spacy download`.
    # Pin must track spaCy's minor version (currently 3.8.x).
    system uv, "pip", "install", "--python", libexec/"bin/python", "--no-cache",
           "https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.8.0/en_core_web_sm-3.8.0-py3-none-any.whl"
    bin.install_symlink libexec/"bin/wyoming-mlx"
  end

  service do
    run [opt_bin/"wyoming-mlx"]
    keep_alive true
    log_path var/"log/wyoming-mlx.log"
    error_log_path var/"log/wyoming-mlx.log"
  end

  test do
    assert_match "wyoming-mlx", shell_output("#{bin}/wyoming-mlx --help")
  end
end
