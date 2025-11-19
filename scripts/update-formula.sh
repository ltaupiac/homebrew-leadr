#!/usr/bin/env bash
set -euo pipefail

#: "${VERSION:?Must specify VERSION (e.g. VERSION=v1.2.3)}"
VERSION="v2.8.4"

PROJECT_SLUG="ll-nick/leadr"
FORMULA_NAME="Leadr"
BINARY_NAME="leadr"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

ARTIFACTS=(
    "mac_amd64:${BINARY_NAME}-${VERSION}-x86_64-apple-darwin"
    "mac_arm64:${BINARY_NAME}-${VERSION}-aarch64-apple-darwin"
    "linux_amd64:${BINARY_NAME}-${VERSION}-x86_64-unknown-linux-musl"
    "linux_arm64:${BINARY_NAME}-${VERSION}-aarch64-unknown-linux-musl"
    "linux_armv7:${BINARY_NAME}-${VERSION}-armv7-unknown-linux-musleabihf"
)

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "https://github.com/${PROJECT_SLUG}/releases/tag/${VERSION}/")

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error: Release $VERSION does not exist on GitHub."
    exit 1
fi

echo "✔ Release $VERSION found."

declare -A SHASUMS

echo "Calculating SHA256 checksums from GitHub release artifacts..."
for entry in "${ARTIFACTS[@]}"; do
    key="${entry%%:*}"
    file="${entry#*:}"

    echo "  -> $file"
    if curl -fsI "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${file}" > /dev/null; then
        SHASUMS["$key"]="$(
            curl -sL "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${file}" |
                shasum -a 256 | awk '{ print $1 }'
        )"
    else
        echo "Error: Artifact $file does not exist."
        exit 1
    fi
done

FORMULA_PATH="${SCRIPT_DIR}/../Formula/${BINARY_NAME}.rb"
mkdir -p "$(dirname "$FORMULA_PATH")"

echo "Writing Homebrew formula to: $FORMULA_PATH"

cat << EOF > "$FORMULA_PATH"
class ${FORMULA_NAME} < Formula
  desc "Shell aliases on steroids"
  homepage "https://github.com/${PROJECT_SLUG}"
  version "${VERSION#v}"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${BINARY_NAME}-${VERSION}-aarch64-apple-darwin"
      sha256 "${SHASUMS[mac_arm64]}"
    else
      url "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${BINARY_NAME}-${VERSION}-x86_64-apple-darwin"
      sha256 "${SHASUMS[mac_amd64]}"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${BINARY_NAME}-${VERSION}-aarch64-unknown-linux-musl"
      sha256 "${SHASUMS[linux_arm64]}"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_32_bit?
      url "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${BINARY_NAME}-${VERSION}-armv7-unknown-linux-musleabihf"
      sha256 "${SHASUMS[linux_armv7]}"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/${PROJECT_SLUG}/releases/download/${VERSION}/${BINARY_NAME}-${VERSION}-x86_64-unknown-linux-musl"
      sha256 "${SHASUMS[linux_amd64]}"
    else
      odie "leadr: no prebuilt binary available for this CPU on Linux"
    end
  end

  def install
    if OS.mac?
      if Hardware::CPU.arm?
        binary_name = "${BINARY_NAME}-v#{version}-aarch64-apple-darwin"
      else
        binary_name = "${BINARY_NAME}-v#{version}-x86_64-apple-darwin"
      end
    else
      if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
        binary_name = "${BINARY_NAME}-v#{version}-x86_64-unknown-linux-musl"
      elsif Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
        binary_name = "${BINARY_NAME}-v#{version}-aarch64-unknown-linux-musl"
      else
        binary_name = "${BINARY_NAME}-v#{version}-armv7-unknown-linux-musleabihf"
      end
    end

    bin.install binary_name => "${BINARY_NAME}"
  end

  test do
    system "#{bin}/${BINARY_NAME}", "--version"
  end
end
EOF

echo "✔ Formula created successfully!"
