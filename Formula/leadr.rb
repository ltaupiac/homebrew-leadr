class Leadr < Formula
  desc "Shell aliases on steroids"
  homepage "https://github.com/ll-nick/leadr"
  version "2.8.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.4/leadr-v2.8.4-aarch64-apple-darwin"
      sha256 "347cabaefbb3d64677bd9a333f651539441629cdd8f4b32b2425374423a37409"
    else
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.4/leadr-v2.8.4-x86_64-apple-darwin"
      sha256 "d5b730b104e345731753c6daeeb54960e67ab6e6bcddca78e96abb0a53af51f5"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.4/leadr-v2.8.4-aarch64-unknown-linux-musl"
      sha256 "c4c03871c62c38ea9cd2a7c935fae0b6d43120264818b3b74f3a4621e4180846"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.4/leadr-v2.8.4-armv7-unknown-linux-musleabihf"
      sha256 "44894c3725e6b658fc872b91b6f0f1af99cd3092250db02a150a7237f231fbe9"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/ll-nick/leadr/releases/download/v2.8.4/leadr-v2.8.4-x86_64-unknown-linux-musl"
      sha256 "7f82a924d6bf039e8d0b69b3fb6f17824ee566fdc84a31b6ee71242ec28357c3"
    else
      odie "leadr: no prebuilt binary available for this CPU on Linux"
    end
  end

  def install
    if OS.mac?
      if Hardware::CPU.arm?
        binary_name = "leadr-v\#{version}-aarch64-apple-darwin"
      else
        binary_name = "leadr-v\#{version}-x86_64-apple-darwin"
      end
    else
      if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
        binary_name = "leadr-v\#{version}-x86_64-unknown-linux-musl"
      elsif Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
        binary_name = "leadr-v\#{version}-aarch64-unknown-linux-musl"
      else
        binary_name = "leadr-v\#{version}-armv7-unknown-linux-musleabihf"
      end
    end

    bin.install binary_name => "leadr"
  end

  test do
    system "\#{bin}/leadr", "--version"
  end
end
