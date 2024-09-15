#!/usr/bin/env bash

PLUGIN_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."

# shellcheck disable=SC2317 # export -f makes it reachable by find
check_file() {
	## Taken from https://github.com/asdf-vm/asdf/blob/master/test/banned_commands.bats
	banned_commands=(
		# Not POSIX compliant
		"<("
		# Not in POSIX
		column
		# echo isn't consistent across operating systems
		echo
		# eval == devil
		eval
		# Not default on OSX
		realpath
		# NotPOSIX compliant
		source
		# [ should be used instead
		test
		# OSX != Unix
		"sed.* -i"
	)
	banned_commands_regex=(
		# Invalid on alpine (grep -i)
		"grep.* -y"
		# Invalid on OSX
		"grep.* -P"
		# Ban grep long commands as they do not work on alpine
		"grep[^|]+--\w{2,}"
		# OSX != Unix
		'readlink.+-.*f.+["$]'
		# sort --sort-version isn't supported everywhere
		"sort.*-V"
		"sort.*--sort-versions"

		# ls often gets used when we want to glob for files that match a pattern
		# or when we want to find all files/directories that match a pattern or are
		# found in a certain location. Using shell globs is preferred over ls, and
		# find is better at locating files that are in a certain location or that
		# match certain filename patterns.
		# https://github-wiki-see.page/m/koalaman/shellcheck/wiki/SC2012
		"\bls "

		# Ban recursive asdf calls as they are inefficient and may introduce bugs.
		"\basdf "
	)

	local file="$1"
	local file_name="${file##*/../}"
	# Read file content and strip comments
	local file_content
	file_content=$(grep -v '^[[:space:]]*#' "$file")

	for cmd in "${banned_commands[@]}"; do
		if echo "$file_content" | grep -nHq "$cmd"; then
			echo "File '$file_name' contains banned command: $cmd"
			return 1
		fi
	done

	for regex in "${banned_commands_regex[@]}"; do
		if echo "$file_content" | grep -nHqE "$regex"; then
			echo "File '$file_name' contains banned pattern: $regex"
			return 1
		fi
	done

	return 0
}
export -f check_file

# Use find and store results
exit_status=0
while IFS= read -r -d '' file; do
	if ! bash -c "check_file \"$file\""; then
		exit_status=1
	fi
done < <(find "$PLUGIN_DIR/lib" "$PLUGIN_DIR/bin" -type f -print0)

if [[ $exit_status -eq 1 ]]; then
	echo "Illegal commands or patterns found. Exiting."
	exit 1
fi

echo "No illegal commands or patterns found."
exit 0
