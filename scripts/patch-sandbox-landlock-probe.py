#!/usr/bin/env python3
"""Backport upstream PR "probe Landlock without requiring securityfs".

Background
----------
Upstream ``_probe_linux_landlock()`` refused to detect Landlock unless it could
read ``/sys/kernel/security/lsm``. Containers normally get an empty
``/sys/kernel/security`` (securityfs is not mounted), so the probe returned
``supported=False`` even though the kernel Landlock LSM was fully functional.
With ``security.sandbox_enabled=true`` that mismatch made every Code Mode
``run_code`` call fail with::

    Script failed: Sandbox is enabled but unavailable

What this does
--------------
Applies the reviewed upstream fix (branch
``fix/landlock-probe-without-securityfs``) to a released QwenPaw source. Three
hunks:

1. Docstring: steps 2 and 3 are optional evidence; step 3 (the syscall) is the
   only authoritative one, so an unreadable LSM list must not short-circuit it.
2. Step 2 becomes best-effort: an unreadable list records ``lsm_confirmed =
   False`` and falls through; a readable list that omits ``landlock`` is still
   a genuine "no".
3. The unknown-architecture branch no longer assumes support. Without a syscall
   number and without a readable LSM list there is no evidence at all, so it
   returns ``supported=False`` instead of guessing.

Hunk 3 is the part a naive "just delete the OSError return" patch gets wrong: it
would start reporting ``supported=True`` on unknown architectures (riscv64, ...)
without verifying anything.

The patched probe is byte-identical to the upstream PR head; only the
surrounding file differs, because 2.3.0.post1 also ships the unrelated
"never write a sandbox ACE on a volume root" change (#8018). The pinned
post-patch digests below are therefore per release, and each is verified before
anything is written.

As of 2.3.0.post1 the upstream fix is *not* merged: the released
``_probe_linux_landlock()`` is unchanged and still returns
``supported=False`` when securityfs is absent, so this backport is still
required.

Safety model
------------
This script edits third-party code that ships from PyPI, so it refuses to act
on a file it has not verified:

1. The installed package must report a version pinned in ``TARGETS``.
2. Every hunk's search text must match exactly once.
3. The result must hash to that version's pinned post-patch digest *before* it
   is written.

Any mismatch exits non-zero and changes nothing, which fails the image build
rather than shipping silently-modified code.

Pinned releases (LF-normalised SHA-256 of ``qwenpaw/sandbox/config.py``)::

    2.3.0        pre  a12dae8ea7ce16765870fb30a9b4fe6467f214435c74f00c019053808e5bbd11
                 post 2ec1c73ab43a5057d6e4744a81b91542787b8ba7c2a6ae15d8513ea85cba3141
                 (upstream PR head 54edf0e8)
    2.3.0.post1  pre  b833da543e575ea001b7f59147272ab5632a1c0c8b6960835f3db4113cc5d6d9
                 post 0d4731a17087e71f51e97556957a02280681bb657997a094dd63866d03717b35

Both ``pre`` digests were confirmed against the PyPI wheel, not just the git
tag, so the backport is exact rather than approximate.

Regenerating the hashes for a future reviewed upgrade::

    python scripts/patch-sandbox-landlock-probe.py --print-hashes \\
        /path/to/site-packages/qwenpaw/sandbox/config.py
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Target:
    """One reviewed QwenPaw release this backport is pinned to.

    Attributes:
        version: ``qwenpaw.__version__`` of the release.
        pre_sha256: Digest of the shipped (unpatched) ``sandbox/config.py``.
        post_sha256: Digest of the same file after this backport.
    """

    version: str
    pre_sha256: str
    post_sha256: str


# ── Pinned upstream revisions ────────────────────────────────────────────────
# Hashes are LF-normalised so a CRLF checkout still verifies. Add a row only
# after reviewing that release's probe; the version file is the discriminator
# because several releases ship byte-identical (or near-identical) copies.
TARGETS: tuple[Target, ...] = (
    Target(
        version="2.3.0",
        pre_sha256=(
            "a12dae8ea7ce16765870fb30a9b4fe6467f214435c74f00c019053808e5bbd11"
        ),
        post_sha256=(
            "2ec1c73ab43a5057d6e4744a81b91542787b8ba7c2a6ae15d8513ea85cba3141"
        ),
    ),
    Target(
        version="2.3.0.post1",
        pre_sha256=(
            "b833da543e575ea001b7f59147272ab5632a1c0c8b6960835f3db4113cc5d6d9"
        ),
        post_sha256=(
            "0d4731a17087e71f51e97556957a02280681bb657997a094dd63866d03717b35"
        ),
    ),
)

# Marker for an already-patched file. Present in hunk 1's replacement text.
APPLIED_MARKER = "step 2\n    must not short-circuit step 3."


# ── Hunk 1: docstring ───────────────────────────────────────────────────────
HUNK1_OLD = '''        2. ``/sys/kernel/security/lsm`` contains ``"landlock"``.
        3. ``landlock_create_ruleset`` syscall returns ABI version.
'''

HUNK1_NEW = '''        2. ``/sys/kernel/security/lsm`` contains ``"landlock"``, when that
           file is readable.
        3. ``landlock_create_ruleset`` syscall returns ABI version.

    Steps 2 and 3 are both optional evidence, but step 3 is the only
    authoritative one. Containers usually cannot read the LSM list
    (securityfs is not mounted) while the kernel LSM works fine, so step 2
    must not short-circuit step 3.
'''

# ── Hunk 2: best-effort LSM check ───────────────────────────────────────────
HUNK2_OLD = '''    # Step 2: Check LSM list
    try:
        with open("/sys/kernel/security/lsm", "r", encoding="utf-8") as f:
            lsm_list = f.read().strip()
        if "landlock" not in lsm_list:
            return SandboxCapability(
                supported=False,
                mode=SandboxMode.NONE,
                reason=f"Landlock not in LSM list: {lsm_list}",
            )
    except OSError:
        return SandboxCapability(
            supported=False,
            mode=SandboxMode.NONE,
            reason="Cannot read /sys/kernel/security/lsm",
        )
'''

HUNK2_NEW = '''    # Step 2: Check LSM list (best effort). Unreadable means securityfs is
    # not mounted, which says nothing about kernel support.
    try:
        with open("/sys/kernel/security/lsm", "r", encoding="utf-8") as f:
            lsm_list = f.read().strip()
    except OSError as e:
        lsm_confirmed = False
        logger.debug(
            "Landlock probe: cannot read /sys/kernel/security/lsm (%s); "
            "deferring to the syscall probe.",
            e,
        )
    else:
        if "landlock" not in lsm_list:
            return SandboxCapability(
                supported=False,
                mode=SandboxMode.NONE,
                reason=f"Landlock not in LSM list: {lsm_list}",
            )
        lsm_confirmed = True
'''

# ── Hunk 3: never guess on unknown architectures ────────────────────────────
HUNK3_OLD = '''            # Fallback: assume support based on kernel + LSM check
            return SandboxCapability(
'''

HUNK3_NEW = '''            # No syscall number for this arch: only the LSM list can
            # corroborate support, so refuse to guess without it.
            if not lsm_confirmed:
                return SandboxCapability(
                    supported=False,
                    mode=SandboxMode.NONE,
                    reason=(
                        "Cannot verify Landlock: /sys/kernel/security/lsm "
                        f"unreadable and no syscall number known for {arch}"
                    ),
                )
            return SandboxCapability(
'''

HUNKS: tuple[tuple[str, str], ...] = (
    (HUNK1_OLD, HUNK1_NEW),
    (HUNK2_OLD, HUNK2_NEW),
    (HUNK3_OLD, HUNK3_NEW),
)


def find_config_module() -> Path | None:
    """Locate the installed file by walking sys.path (no package import)."""
    for entry in sys.path:
        if not entry:
            continue
        candidate = Path(entry) / "qwenpaw" / "sandbox" / "config.py"
        if candidate.is_file():
            return candidate
    return None


def read_installed_version(config_path: Path) -> str | None:
    """Read ``qwenpaw/__version__.py`` without importing the package.

    Several releases ship a byte-identical ``sandbox/config.py`` (2.2.2 and
    2.3.0 are identical), so the file hash alone cannot scope this patch. The
    package version file is the only reliable discriminator.
    """
    version_file = config_path.parent.parent / "__version__.py"
    try:
        text = version_file.read_text(encoding="utf-8")
    except OSError:
        return None
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("__version__"):
            _, _, value = stripped.partition("=")
            return value.strip().strip("'\"")
    return None


def read_preserving_newlines(path: Path) -> tuple[str, bool]:
    """Read the file without universal-newline translation.

    ``Path.read_text()`` rewrites CRLF to LF on read, which would silently
    convert a CRLF checkout to LF on write. Decode the raw bytes instead and
    report which line ending the file actually uses.
    """
    data = path.read_bytes()
    return data.decode("utf-8"), b"\r\n" in data


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def normalise(text: str) -> str:
    return text.replace("\r\n", "\n")


def fail(message: str) -> int:
    print(f"ERROR: {message}", file=sys.stderr)
    return 1


def apply_hunks(norm: str) -> str | None:
    """Apply every hunk exactly once; return None if any hunk is off."""
    out = norm
    for index, (old, new) in enumerate(HUNKS, start=1):
        occurrences = out.count(old)
        if occurrences != 1:
            return None
        out = out.replace(old, new, 1)
    return out


def target_for_version(version: str | None) -> Target | None:
    """Return the pinned release for *version*, or None if unsupported."""
    for target in TARGETS:
        if target.version == version:
            return target
    return None


def post_hash_match(pre_hash: str) -> Target | None:
    """Return the target whose reviewed result equals *pre_hash*."""
    for target in TARGETS:
        if target.post_sha256 == pre_hash:
            return target
    return None


def pinned_versions() -> str:
    """Human-readable list of the pinned releases."""
    return ", ".join(target.version for target in TARGETS)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "path",
        nargs="?",
        help="config.py to patch (default: locate qwenpaw on sys.path)",
    )
    parser.add_argument(
        "--allow-unknown",
        action="store_true",
        help="patch even when the version or file hash is not pinned "
        "(requires manual review of that exact file)",
    )
    parser.add_argument(
        "--print-hashes",
        action="store_true",
        help="print the LF-normalised pre/post hashes and exit (no write)",
    )
    args = parser.parse_args(argv)

    path = Path(args.path) if args.path else find_config_module()
    if path is None:
        return fail(
            "qwenpaw/sandbox/config.py not found on sys.path; "
            "is QwenPaw installed?",
        )
    if not path.is_file():
        return fail(f"no such file: {path}")

    text, uses_crlf = read_preserving_newlines(path)
    norm = normalise(text)
    pre_hash = sha256_text(norm)
    installed_version = read_installed_version(path)
    target = target_for_version(installed_version)

    # ── Already patched: confirm it is a reviewed result ────────────────────
    if APPLIED_MARKER in norm:
        reviewed = post_hash_match(pre_hash)
        if reviewed is not None:
            print(
                f"Already patched (installed QwenPaw "
                f"{installed_version or 'unknown'}, matches the reviewed "
                f"{reviewed.version} result): {path}",
            )
        else:
            print(
                f"Already patched, but the result hash {pre_hash} is not any "
                f"pinned post-patch digest ({pinned_versions()}). Someone "
                f"edited this file by hand; verify it yourself: {path}",
                file=sys.stderr,
            )
        return 0

    if args.print_hashes:
        candidate = apply_hunks(norm)
        print(f"path:      {path}")
        print(f"version:   {installed_version}")
        print(f"pinned:    {target.version if target else 'NO'}")
        print(f"crlf:      {uses_crlf}")
        print(f"pre-sha256 {pre_hash}")
        print(
            f"post-sha256 {sha256_text(candidate) if candidate else 'hunks did not apply'}",
        )
        print(f"hunk matches: {[norm.count(o) for o, _ in HUNKS]}")
        if target is None:
            print(
                f"note:      QwenPaw {installed_version or 'unknown'} is not "
                f"pinned; copy the hashes above into TARGETS after review",
            )
        return 0

    # ── Only pinned releases are patched ────────────────────────────────────
    if target is None and not args.allow_unknown:
        return fail(
            f"installed QwenPaw is {installed_version or 'unknown'}, "
            f"which is not pinned ({pinned_versions()}) ({path}).\n"
            f"This backport is scoped to reviewed releases only. Review the "
            "upstream probe for the installed release, then add a Target row "
            "in TARGETS; or re-run with --allow-unknown for a one-off build.",
        )
    expected_pre = target.pre_sha256 if target else None
    expected_post = target.post_sha256 if target else None
    if expected_pre is not None and pre_hash != expected_pre:
        return fail(
            f"QwenPaw {target.version} file hash mismatch at {path}.\n"
            f"  expected {expected_pre}\n"
            f"  got      {pre_hash}\n"
            "The version says "
            f"{target.version} but the probe file is not the reviewed "
            "one: either the wheel was republished or this file was edited "
            "locally. Refusing to patch. Next steps:\n"
            "  1. inspect the file and the blocks this patch replaces:\n"
            f"       grep -n -F 'security/lsm' {path}\n"
            "  2. confirm the replacement still makes sense for it\n"
            "  3. pin the new hashes, or re-run with --allow-unknown",
        )
    if expected_pre is None:
        print(
            f"WARNING: patching unreviewed QwenPaw "
            f"{installed_version or 'unknown'} (hash {pre_hash}) because "
            "--allow-unknown was given. You are responsible for having "
            "reviewed this file.",
            file=sys.stderr,
        )

    # ── Apply, verify the pinned result, only then write ────────────────────
    counts = [norm.count(old) for old, _ in HUNKS]
    if counts != [1, 1, 1]:
        return fail(
            f"expected exactly one match per hunk in {path}, "
            f"got {counts}; refusing to guess",
        )

    patched_norm = apply_hunks(norm)
    assert patched_norm is not None
    post_hash = sha256_text(patched_norm)
    if expected_post is not None and post_hash != expected_post:
        return fail(
            f"post-patch digest mismatch: got {post_hash}, "
            f"expected {expected_post}; nothing was written",
        )

    if uses_crlf:
        patched_text = patched_norm.replace("\n", "\r\n")
    else:
        patched_text = patched_norm
    path.write_bytes(patched_text.encode("utf-8"))

    print(f"Patched {path}")
    print(f"  upstream:  QwenPaw {installed_version}")
    print(f"  backport:  fix/landlock-probe-without-securityfs")
    print(f"  pre-hash:  {pre_hash}")
    print(f"  post-hash: {post_hash}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
