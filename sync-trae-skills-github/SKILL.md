---
name: sync-trae-skills-github
description: Synchronize all skills under /Users/pa/.trae-cn/skills to a GitHub repository and create a timestamp-based version name for each sync run. Use when the user asks to back up, publish, mirror, or regularly sync local Trae/Codex skills to GitHub with version tracking.
---

# Sync Trae Skills to GitHub

## Overview

Use this skill to manage Git directly inside `/Users/pa/.trae-cn/skills`, then push commits and tags to a GitHub repository with one timestamped version per sync.

## Workflow

1. Confirm target repository URL (HTTPS or SSH).
2. Confirm local source directory selection:
- If `--source` is provided, use it.
- Otherwise read [references/source_paths.txt](references/source_paths.txt) and choose the first existing path.
3. Confirm access is already configured for `git push`.
3. Run the sync script:

```bash
scripts/sync_skills.sh
```

4. Report back:
- Version name created in this run
- Commit hash
- Target repository URL
- Whether rebase was required

## Script Usage

Run from any folder:

```bash
scripts/sync_skills.sh \
  --repo https://github.com/zhouhuawei2025/MySkill_Trae.git \
  --sources-file references/source_paths.txt \
  --branch main
```

Optional flags:
- `--repo <repo-url>`: Override default repo. Default: `https://github.com/zhouhuawei2025/MySkill_Trae.git`
- `--source <dir>`: Force a specific local source directory on current machine.
- `--sources-file <file>`: Path list file for multi-computer environments. Default: `references/source_paths.txt`
- `--version-prefix <prefix>`: Prefix for version tags. Default: `v`
- `--create-release`: Also create a GitHub Release with `gh` CLI (requires auth)

## Output Contract

After execution, provide these values:
- `version_name`: Timestamp-based tag name, format `<prefix>YYYYMMDD-HHMMSS` (if already exists, auto suffix `-1`, `-2`, ...)
- `commit`: New commit hash that contains the synced skills
- `repo`: Remote repository URL
- `branch`: Target branch

## Failure Handling

1. If `git push` fails due to auth, stop and ask user to configure SSH key or PAT.
2. If source directory does not exist and no valid entry is found in sources file, stop and report both paths.
3. If rebase conflicts occur, stop and ask user to resolve conflicts, run `git rebase --continue`, then rerun script.
4. If `gh` release creation fails, keep sync success and report release step failure separately.

## Resources

- Script: [scripts/sync_skills.sh](scripts/sync_skills.sh)
- Multi-machine path list: [references/source_paths.txt](references/source_paths.txt)
- Setup notes: [references/github_setup.md](references/github_setup.md)
