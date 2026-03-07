# GitHub Setup Notes

## Repository suggestion

Target repository:
- `https://github.com/zhouhuawei2025/MySkill_Trae`

## Authentication

Use one of these methods before running sync:

1. SSH key
- Add local SSH public key to GitHub
- Use repo URL format: `git@github.com:<user>/<repo>.git`

2. HTTPS + Personal Access Token
- Create a GitHub token with `repo` scope
- Use credential manager so `git push` can authenticate

## Required commands

- `git`
- Optional: `gh` (for `--create-release`)

## Push mode

This skill uses direct Git operations in the source folder (`/Users/pa/.trae-cn/skills` by default):
- initialize repo if missing
- create/update `origin`
- `git add -A`, commit, `fetch + rebase` on remote branch, tag
- `git push origin <branch>` and `git push origin <tag>`

For multi-computer usage:
- maintain candidate local paths in `references/source_paths.txt`
- script picks the first existing path unless `--source` is provided
