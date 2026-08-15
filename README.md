# moshi-hook-nix

`moshi-hook-nix` packages Moshi's official static Linux x86_64 `moshi-hook`
archive as a small reusable Nix flake. It exposes both `moshi-hook` and a
`moshi` alias in `bin`.

## Use

Add the flake as an input:

```nix
inputs.moshi-hook.url = "github:takeaship/moshi-hook-nix";
```

Then install `inputs.moshi-hook.packages.x86_64-linux.default`, or run the
alias directly:

```sh
nix run github:takeaship/moshi-hook-nix -- --help
```

The package supports only `x86_64-linux`, because it deliberately packages
the official Linux x86_64 static archive.

## Security and updates

The pinned version and Nix SRI hash live in `version.nix`. The update workflow
runs on a schedule and can also be started manually. It retrieves Moshi's
official `latest/version.txt` and that version's `checksums.txt`, downloads the
Linux x86_64 archive, and verifies its SHA-256 independently before changing
the pin. It builds the flake and confirms the binary reports the expected
version before committing an update to `main`.

The workflow has only `contents: write` permission, uses the repository's
ephemeral `GITHUB_TOKEN` solely for that validated direct commit, and uses no
user-managed secrets. GitHub Actions are pinned by full commit SHA.
