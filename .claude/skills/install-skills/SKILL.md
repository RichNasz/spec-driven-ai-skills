---
name: install-skills
description: >
  Install a skill suite from the spec-driven-ai-skills marketplace into a
  target project. Run with no arguments to see available suites.
compatibility: Requires Python 3
metadata:
  suite: sdai-marketplace
---

# Install Skills

Installs a skill suite from this repository's marketplace into a target project directory.

## Usage

```
/install-skills [suite-name] [target-path]
```

Both arguments are optional. If omitted, the skill prompts for them interactively.

**Examples**

```
/install-skills
/install-skills articles
/install-skills articles ~/Development/my-project
```

## What it does

1. Reads `marketplace/catalog.yaml` to discover available suites
2. Confirms the suite and target path with you before touching anything
3. Copies all skill files into `<target>/.claude/skills/`
4. Reports every file copied and lists system prerequisites to satisfy

## Implementation

### Step 0 — Parse args

Extract `suite-name` and `target-path` from the invocation text (positional, space-separated, after the command name). Both are optional.

### Step 1 — Read catalog

Parse `marketplace/catalog.yaml` using Python string operations — no `import yaml`. Use `split(':', 1)` and `.strip().strip('"')` to extract values. Build a representation of the available suites.

If no `suite-name` was given, print the available suites in this format and ask the user to choose:

```
Available suites:

  articles   Spec-Driven Article Generation
             Generate articles from Google Doc specs, evaluate spec quality...

Enter suite name:
```

If a `suite-name` was given but is not in the catalog, stop and print the available suite keys.

### Step 2 — Get target path

If `target-path` was not provided, ask:

```
Install target directory (the root of your project):
```

Expand `~` using `os.path.expanduser`. Verify the path exists; if not, ask for confirmation before creating it.

### Step 3 — Confirm

Print a summary and ask the user to confirm before copying anything:

```
Installing: <suite name> v<version>
Target:     <target>/.claude/skills/
Skills:     <skill1>, <skill2>, ...

System prerequisites (install these before using the skills):
  - <requirement 1>
  - <requirement 2>

Proceed? (yes/no):
```

Do not proceed unless the user responds with "yes" or "y".

### Step 4 — Install

For each skill in the suite:

```python
import os, shutil

repo_root = os.getcwd()  # skill runs from repo root

for skill in suite['skills']:
    src = os.path.join(repo_root, skill['source'])
    dst = os.path.join(target_path, '.claude', 'skills', skill['name'])
    os.makedirs(dst, exist_ok=True)
    # Copy everything in the source directory
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)
        print(f"  copied: {d}")
```

### Step 5 — Report

After all files are copied:

```
Installation complete.

Installed <N> skills to <target>/.claude/skills/:
  ✓ generate-article
  ✓ spec-coach
  ✓ spec-auto-tune
  ✓ gws-utils

Before using these skills, ensure the following are installed:
  - gws CLI (https://github.com/stoe/gws) with Google Workspace credentials
  - Python 3

See <docs path> for usage instructions.
```

## Constraints

- Never write to or modify any file inside this repository — only read from `marketplace/catalog.yaml` and the skill source directories.
- Always confirm with the user before copying files.
- If any copy fails, report the error and stop — do not leave a partial install silently.
