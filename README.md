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
runs on a schedule and can also be started manually. A read-only job retrieves
Moshi's official `latest/version.txt` and that version's `checksums.txt`,
downloads the Linux x86_64 archive, verifies its SHA-256, and rejects
downgrades. A separate credential-free job builds the flake and confirms the
binary reports the expected version. Only then does a fresh write-enabled job
re-fetch and verify the release, ensure `main` has not changed, and commit the
new `version.nix`; it never executes the downloaded binary. The same package
check runs for every pull request and can also be started manually.

The workflow grants read and write permissions only to their respective jobs,
never persists Git credentials, and exposes the ephemeral `GITHUB_TOKEN` only
to its final push step. It uses no user-managed secrets. GitHub Actions are
pinned by full commit SHA and kept current by Dependabot.

### What the checksum does and does not prove

Moshi publishes no signatures or build provenance for `moshi-hook`, and
`checksums.txt` is served from the same `cdn.getmoshi.app` origin as the
archive. The SHA-256 check therefore proves only that the archive matches what
that origin advertises. It catches transfer corruption and a middlebox that
cannot also rewrite `checksums.txt`; it is not independent verification of the
upstream build, and anyone able to publish to the CDN can publish a matching
checksum next to a modified archive. Re-verifying in a second job does not
help against that attacker, because both jobs consult the same origin.

Pinning the hash in `version.nix` is what makes each *packaged* release
immutable and reproducible from then on. It does not authenticate the release
at the moment it is ingested. Because updates land on `main` unattended,
depending on this flake means trusting Moshi's release pipeline to the same
degree you already trust the binary, which is unfree and closed-source. If
upstream ever ships cosign or GPG signatures, the resolve job should verify
them before accepting a version.

### The validation job runs unvetted code

The validation job deliberately executes the freshly downloaded binary
(`moshi-hook --version`) before anything has vouched for it, because a version
string is the only end-to-end check available. That job checks out without
credentials, holds only `contents: read`, and uses no Actions cache, so a
malicious archive would execute in a scope with no durable state to reach and
no repository write access — but it does execute.
