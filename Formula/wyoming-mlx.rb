class WyomingMlx < Formula
  desc "Apple-Silicon-native TTS and STT for Home Assistant and OpenAI clients"
  homepage "https://github.com/rnorth/wyoming-mlx"
  url "https://github.com/rnorth/wyoming-mlx/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "2048069f3b1bc09d94181990a6493846f7fb6b5657da29089e9248afbde2b1a0"
  license "Apache-2.0"

  depends_on "uv" => :build
  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.12"

  def install
    uv = Formula["uv"].opt_bin/"uv"
    system uv, "venv", libexec, "--python", Formula["python@3.12"].opt_bin/"python3.12"
    system uv, "pip", "install", "--python", libexec/"bin/python", "--no-cache", buildpath.to_s
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
