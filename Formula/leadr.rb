class Leadr < Formula
  desc "Leader-key inspired command runner"
  homepage "https://github.com/ll-nick/leadr"
  version "2.8.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.3/leadr-v2.8.3-aarch64-apple-darwin"
      sha256 "SHA256_ARM_BINARY"
    elsif Hardware::CPU.intel?
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.3/leadr-v2.8.3-x86_64-apple-darwin"
      sha256 "58c7bd0d519ce46916288b6bffaa70c9c4c1139f2e3783b1eef01df1b95303e1"
    end
  end

  def install
    binary_name =
      if Hardware::CPU.arm?
        "leadr-v#{version}-aarch64-apple-darwin"
      else
        "leadr-v#{version}-x86_64-apple-darwin"
      end

    bin.install binary_name => "leadr"
  end

  test do
    system "#{bin}/leadr", "--help"
  end
end
