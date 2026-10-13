#!/usr/bin/env python3
"""Version consistency check.

The .toc, the README badge and the latest CHANGELOG.md entry must carry the
same version. The version announced by the in-game changelog popup may lag
behind it, since a technical release is not announced, but can never be ahead.
"""
import re
import sys

TOC = "WhatTodo.toc"
README = "README.md"
CHANGELOG = "CHANGELOG.md"
POPUP = "UI/ChangelogPopup.lua"

VERSION = r"(\d+\.\d+\.\d+)"


class VersionNotFound(Exception):
    pass


def _extract(pattern, content, description):
    match = re.search(pattern, content, re.MULTILINE)
    if match is None:
        raise VersionNotFound(description)
    return match.group(1)


def toc_version(content):
    return _extract(r"^## Version:\s*" + VERSION + r"\s*$", content, "'## Version' directive")


def readme_version(content):
    return _extract(r"badge/version-" + VERSION + r"-", content, "version badge")


def changelog_version(content):
    return _extract(r"^## \[" + VERSION + r"\]", content, "'## [x.y.z]' entry")


def popup_version(content):
    return _extract(r'^local CHANGELOG_VERSION = "' + VERSION + r'"', content, "CHANGELOG_VERSION")


def _as_numbers(version):
    return tuple(int(part) for part in version.split("."))


def find_problems(release_versions, announced_version):
    if len(set(release_versions.values())) > 1:
        listing = ", ".join(f"{source}: {version}" for source, version in release_versions.items())
        return [f"release versions differ ({listing})"]

    release_version = next(iter(release_versions.values()))
    if _as_numbers(announced_version) > _as_numbers(release_version):
        return [
            f"{POPUP} announces {announced_version}, ahead of the release version {release_version}"
        ]
    return []


def _read_versions(extractors):
    versions = {}
    for path, extract in extractors.items():
        with open(path, encoding="utf-8") as f:
            content = f.read()
        try:
            versions[path] = extract(content)
        except VersionNotFound as missing:
            sys.exit(f"Version check failed: {missing} not found in {path}")
    return versions


def main():
    release_versions = _read_versions(
        {TOC: toc_version, README: readme_version, CHANGELOG: changelog_version}
    )
    announced_version = _read_versions({POPUP: popup_version})[POPUP]

    problems = find_problems(release_versions, announced_version)
    if problems:
        sys.exit("Version check failed: " + "; ".join(problems))


if __name__ == "__main__":
    main()
