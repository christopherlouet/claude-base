#!/usr/bin/env python3
"""
build-prompt.py — substitute placeholders in translate-prompt.md template.

Usage:
    build-prompt.py --template <file> --file-path <rel-path> \\
        --content <file> --glossary <file> --blacklist <file>

Substitutes (literal string replacement, no escaping needed):
    {{FILE_PATH}}      ->  --file-path argument value
    {{FILE_CONTENT}}   ->  contents of --content file
    {{GLOSSARY_YAML}}  ->  contents of --glossary file
    {{BLACKLIST}}      ->  contents of --blacklist file

Output: assembled prompt to stdout.
"""

import argparse
import sys


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--template", required=True)
    p.add_argument("--file-path", required=True)
    p.add_argument("--content", required=True)
    p.add_argument("--glossary", required=True)
    p.add_argument("--blacklist", required=True)
    args = p.parse_args()

    with open(args.template, encoding="utf-8") as f:
        template = f.read()
    with open(args.content, encoding="utf-8") as f:
        content = f.read()
    with open(args.glossary, encoding="utf-8") as f:
        glossary = f.read()
    with open(args.blacklist, encoding="utf-8") as f:
        blacklist = f.read()

    out = (
        template.replace("{{FILE_PATH}}", args.file_path)
        .replace("{{FILE_CONTENT}}", content)
        .replace("{{GLOSSARY_YAML}}", glossary)
        .replace("{{BLACKLIST}}", blacklist)
    )
    sys.stdout.write(out)


if __name__ == "__main__":
    main()
