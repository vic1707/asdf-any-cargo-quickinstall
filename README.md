<div align="center">

# asdf-any-cargo-quickinstall ![Test](https://github.com/vic1707/asdf-any-cargo-quickinstall/workflows/Test/badge.svg) ![Lint](https://github.com/vic1707/asdf-any-cargo-quickinstall/workflows/Lint/badge.svg)

A flexible [asdf](https://asdf-vm.com) plugin for installing any tool available via [cargo-quickinstall](https://github.com/cargo-bins/cargo-quickinstall).

</div>

# Contents

-   [Dependencies](#dependencies)
-   [Install](#install)
-   [Usage](#usage)
-   [Contributing](#contributing)
-   [License](#license)

# Dependencies

-   `bash`, `curl` or `wget`, `tar`.

# Install

You can install this plugin to manage any Rust-based tool available in the [cargo-quickinstall](https://github.com/cargo-bins/cargo-quickinstall) repository.
The plugin is dynamic, meaning it can be used for multiple tools without needing to hard-code each one.

In the following 2 sections, you'll need to replace `<cargo-quickinstall-tool>` with the actual tool name you wish to install.

```shell
asdf plugin add <cargo-quickinstall-tool> https://github.com/vic1707/asdf-any-cargo-quickinstall.git
```

# Usage

```shell
# Show all installable versions
asdf list-all <cargo-quickinstall-tool>

# Install specific version
asdf install <cargo-quickinstall-tool> latest

# Set a version globally (on your ~/.tool-versions file)
asdf global <cargo-quickinstall-tool> latest

# Now your tool's commands are available
<cargo-quickinstall-tool> --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Known limitations

This plugin depends heavily on what [cargo-quickinstall](https://github.com/cargo-bins/cargo-quickinstall) pre-builds.

For example, [bacon](https://github.com/Canop/bacon) in its [quickinstall 2.20.0](https://github.com/cargo-bins/cargo-quickinstall/releases/bacon-2.20.0) does not provide a linux `x86_64` binary using `glibc`, only `musl`.
Consequently, this plugin is unable to install [bacon](https://github.com/Canop/bacon) on `glibc`-dependent distros.

# Possible improvements

-   [ ] -   Try to make the scripts POSIX `sh` compliant because.
-   [x] -   Check all scripts against [asdf banned commands](https://github.com/asdf-vm/asdf/blob/master/test/banned_commands.bats).

# Contributing

Contributions of any kind welcome!

[Thanks goes to these contributors](https://github.com/vic1707/asdf-any-cargo-quickinstall/graphs/contributors)!

# License

`asdf-any-cargo-quickinstall` is highly inspired by [asdf-eza](https://github.com/lwiechec/asdf-eza) by [lwiechec](https://github.com/lwiechec) which is itself almost a direct copy of [asdf-zoxide](https://github.com/nyrst/asdf-zoxide) by [nyrst](https://github.com/nyrst); kudos!

See [LICENSE](LICENSE) © [Siegfried Ehret](https://github.com/SiegfriedEhret/)
