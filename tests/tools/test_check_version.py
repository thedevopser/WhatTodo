import importlib.util
import pathlib
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[2] / "tools" / "check-version.py"
spec = importlib.util.spec_from_file_location("check_version", SCRIPT)
check_version = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check_version)


class TocVersionTest(unittest.TestCase):
    def test_reads_the_version_directive(self):
        content = "## Interface: 120100\n## Version: 1.6.0\n## Title: WhatTodo\n"
        self.assertEqual("1.6.0", check_version.toc_version(content))

    def test_rejects_a_toc_without_version_directive(self):
        with self.assertRaises(check_version.VersionNotFound):
            check_version.toc_version("## Interface: 120100\n")


class ReadmeVersionTest(unittest.TestCase):
    def test_reads_the_version_badge(self):
        content = "![Version](https://img.shields.io/badge/version-1.6.0-blue)\n"
        self.assertEqual("1.6.0", check_version.readme_version(content))

    def test_ignores_the_other_badges(self):
        content = (
            "![Lua](https://img.shields.io/badge/Lua-5.1-blue)\n"
            "![Version](https://img.shields.io/badge/version-1.6.0-blue)\n"
        )
        self.assertEqual("1.6.0", check_version.readme_version(content))

    def test_rejects_a_readme_without_version_badge(self):
        with self.assertRaises(check_version.VersionNotFound):
            check_version.readme_version("# WhatTodo\n")


class ChangelogVersionTest(unittest.TestCase):
    def test_reads_the_most_recent_entry(self):
        content = "# Changelog\n\n## [1.6.0]\n\n### Added\n\n## [1.5.2]\n"
        self.assertEqual("1.6.0", check_version.changelog_version(content))

    def test_rejects_a_changelog_without_entry(self):
        with self.assertRaises(check_version.VersionNotFound):
            check_version.changelog_version("# Changelog\n")


class PopupVersionTest(unittest.TestCase):
    def test_reads_the_announced_version(self):
        content = 'local L = WhatTodo_L\nlocal CHANGELOG_VERSION = "1.6.0"\n'
        self.assertEqual("1.6.0", check_version.popup_version(content))

    def test_rejects_a_file_without_announced_version(self):
        with self.assertRaises(check_version.VersionNotFound):
            check_version.popup_version("local L = WhatTodo_L\n")


class FindProblemsTest(unittest.TestCase):
    def test_accepts_aligned_versions(self):
        release = {"WhatTodo.toc": "1.6.0", "README.md": "1.6.0", "CHANGELOG.md": "1.6.0"}
        self.assertEqual([], check_version.find_problems(release, "1.6.0"))

    def test_accepts_a_popup_lagging_behind_the_release(self):
        release = {"WhatTodo.toc": "1.5.1", "README.md": "1.5.1", "CHANGELOG.md": "1.5.1"}
        self.assertEqual([], check_version.find_problems(release, "1.5.0"))

    def test_reports_every_source_when_release_versions_differ(self):
        release = {"WhatTodo.toc": "1.6.0", "README.md": "1.5.2", "CHANGELOG.md": "1.6.0"}
        problems = check_version.find_problems(release, "1.5.0")
        self.assertEqual(1, len(problems))
        self.assertIn("WhatTodo.toc: 1.6.0", problems[0])
        self.assertIn("README.md: 1.5.2", problems[0])
        self.assertIn("CHANGELOG.md: 1.6.0", problems[0])

    def test_reports_a_popup_ahead_of_the_release(self):
        release = {"WhatTodo.toc": "1.6.0", "README.md": "1.6.0", "CHANGELOG.md": "1.6.0"}
        problems = check_version.find_problems(release, "1.7.0")
        self.assertEqual(1, len(problems))
        self.assertIn("1.7.0", problems[0])

    def test_compares_version_numbers_and_not_strings(self):
        release = {"WhatTodo.toc": "1.10.0", "README.md": "1.10.0", "CHANGELOG.md": "1.10.0"}
        self.assertEqual([], check_version.find_problems(release, "1.9.0"))

    def test_does_not_judge_the_popup_when_release_versions_differ(self):
        release = {"WhatTodo.toc": "1.6.0", "README.md": "1.5.2", "CHANGELOG.md": "1.6.0"}
        self.assertEqual(1, len(check_version.find_problems(release, "1.9.0")))


if __name__ == "__main__":
    unittest.main()
