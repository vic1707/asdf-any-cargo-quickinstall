#!/usr/bin/env bash

set -euo pipefail

# TOOL_NAME="$(basename "$(dirname "$(dirname "$0")")")"
TOOL_NAME="${0%/*/*}"
TOOL_NAME="${TOOL_NAME##*/}"

say() {
	echo "[asdf-any-cargo-quickinstall](%s): %s\n" "$TOOL_NAME" "$*"
}

fail() {
	say "$*" >&2
	exit 1
}

sort_semver() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' \
		| LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n \
		| awk '{print $2}'
}

list_github_semver_tags() {
	gh_repo="$1"
	tool_name="$2"

	git ls-remote --tags --refs "$gh_repo" \
		| grep -o "refs/tags/$tool_name-.*" \
		| cut -d/ -f3- \
		| sed "s/^$tool_name-//" \
		| grep -oE '^[0-9]+\.[0-9]+\.[0-9]+$' \
		| uniq
}

is_valid() {
	url="$1"
	if which curl > /dev/null; then
		curl -s --fail "$url"
	elif which wget > /dev/null; then
		wget -q --spider "$url" &> /dev/null
	else
		fail "Error: Neither curl nor wget is available."
	fi
}

download() {
	out_file="$1"
	url="$2"

	if which curl > /dev/null; then
		curl -fsSL ${GITHUB_API_TOKEN:+-H "Authorization: token $GITHUB_API_TOKEN"} -o "$out_file" "$url"
	elif which wget > /dev/null; then
		wget -q ${GITHUB_API_TOKEN:+--header="Authorization: token $GITHUB_API_TOKEN"} -O "$out_file" "$url"
	else
		fail "Error: Neither curl nor wget is available."
	fi
}

# returns an array of compatible triples (or quadruples depending on linux's libc)
get_target_triples() {
	platform=$(uname -s)
	arch=$(uname -m)

	case "$platform" in
		Darwin)
			case "$arch" in
				aarch64 | arm64) targets=("aarch64-apple-darwin" "x86_64-apple-darwin") ;; # Rosetta
				x86_64) targets=("x86_64-apple-darwin") ;;
				*) fail "Incompatible darwin architecture." ;;
			esac
			;;
		Linux)
			case "$arch" in
				aarch64 | arm64) base_triple="aarch64-unknown-linux" ;;
				armv7l | armv7) base_triple="armv7-unknown-linux" ;;
				x86_64) base_triple="x86_64-unknown-linux" ;;
				*) fail "Incompatible linux architecture." ;;
			esac

			libc_sufix=""
			[ "$arch" = "armv7" ] || [ "$arch" = "armv7l" ] && libc_sufix="eabihf"

			# Detect libc libraries for musl and glibc
			musl_lib="/lib/ld-musl-$arch.so.1"
			# glibc has special paths for specific architectures
			glibc_lib=""
			case "$arch" in
				x86_64) glibc_lib="/lib64/ld-linux-x86-64.so.2" ;;
				aarch64 | arm64) glibc_lib="/lib/ld-linux-aarch64.so.1" ;;
				armv7l | armv7) glibc_lib="/lib/ld-linux-armhf.so.3" ;;
			esac

			[ -f "$musl_lib" ]
			musl_exists=$?
			[ -f "$glibc_lib" ]
			glibc_exists=$?

			case "$musl_exists:$glibc_exists" in
				0:0) targets=("$base_triple-musl$libc_sufix" "$base_triple-gnu$libc_sufix") ;;
				0:1) targets=("$base_triple-musl$libc_sufix") ;;
				1:0) targets=("$base_triple-gnu$libc_sufix") ;;
				1:1) fail "Neither musl nor glibc detected." ;;
			esac
			;;
		*) fail "Incompatible platform." ;;
	esac

	printf '%s ' "${targets[@]}"
}
