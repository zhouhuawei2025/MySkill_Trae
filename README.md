# Sync Trae Skills to GitHub

## 目的

这个 skill 用来把本地 Trae/Codex skills 目录同步到 GitHub 仓库，并在每次同步时自动创建一个基于时间的版本标签，方便多台电脑协作和回溯历史版本。

默认目标仓库：
- `https://github.com/zhouhuawei2025/MySkill_Trae.git`

默认本地目录候选配置：
- `references/source_paths.txt`

## 解决的问题

- 多电脑上分别更新 skill，统一推送到同一个 GitHub 仓库
- 每次同步自动生成版本号（时间戳 tag）
- 推送前自动执行 `fetch + rebase`，降低分支冲突概率
- 支持目录候选列表，兼容 2 台、3 台、4 台电脑的不同本地路径

## 工作流程

脚本文件：
- `scripts/sync_skills.sh`

执行流程：
1. 选择本地源目录
- 若传入 `--source`，优先使用该路径
- 否则读取 `references/source_paths.txt`，选择第一个存在的目录
2. 进入该目录并初始化 Git（若尚未初始化）
3. 设置 `origin` 为目标仓库地址
4. 切换到目标分支（默认 `main`）
5. 执行 `git add -A` 并创建提交
6. 执行 `git fetch origin`，再 `git rebase origin/main`
7. 创建时间版本 tag（格式 `vYYYYMMDD-HHMMSS`）
8. 推送分支和 tag 到 GitHub

输出结果包含：
- `version_name`
- `commit`
- `repo`
- `branch`

## 使用方法

直接执行（使用默认仓库 + 默认目录列表）：

```bash
/Users/pa/Documents/New\ project/skills/sync-trae-skills-github/scripts/sync_skills.sh
```

显式指定源目录：

```bash
/Users/pa/Documents/New\ project/skills/sync-trae-skills-github/scripts/sync_skills.sh \
  --source /Users/pa/.trae-cn/skills
```

显式指定目录列表文件：

```bash
/Users/pa/Documents/New\ project/skills/sync-trae-skills-github/scripts/sync_skills.sh \
  --sources-file /path/to/source_paths.txt
```

## 多电脑配置建议

编辑 `references/source_paths.txt`，每行一个候选目录，例如：

```txt
/Users/pa/.trae-cn/skills
/Users/another/.trae-cn/skills
/home/linux-user/.trae-cn/skills
```

脚本会自动选择当前机器上第一个存在的目录。

## 冲突处理说明

本 skill 已采用 `main` 直推 + `rebase`：
- 推送前会先拉取远端并 rebase 到最新 `origin/main`
- 若出现冲突，按 Git 提示解决后执行：

```bash
git rebase --continue
```

然后重新运行同步脚本。

## 可选参数

- `--repo <url>` 覆盖默认仓库地址
- `--source <dir>` 强制指定本地源目录
- `--sources-file <file>` 指定目录候选列表文件
- `--branch <name>` 指定分支（默认 `main`）
- `--version-prefix <prefix>` 指定版本前缀（默认 `v`）
- `--create-release` 同时创建 GitHub Release（需 `gh`）
