#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="/Users/pa/.trae-cn/skills"
BRANCH="main"
VERSION_PREFIX="v"
CREATE_RELEASE="false"
REPO_URL="https://github.com/zhouhuawei2025/MySkill_Trae.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_FILE="$SCRIPT_DIR/../references/source_paths.txt"

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") [--repo <repo-url>] [--source <dir>] [--sources-file <file>] [--branch <branch>] [--version-prefix <prefix>] [--create-release]

Examples:
  $(basename "$0")
  $(basename "$0") --repo https://github.com/zhouhuawei2025/MySkill_Trae.git
  $(basename "$0") --sources-file ./my-source-paths.txt
  $(basename "$0") --source /Users/pa/.trae-cn/skills
  $(basename "$0") --repo git@github.com:zhouhuawei2025/MySkill_Trae.git --create-release
USAGE
}

pick_source_from_file() {
  local file="$1"
  local line

  [[ -f "$file" ]] || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue
    if [[ -d "$line" ]]; then
      SOURCE_DIR="$line"
      return 0
    fi
  done < "$file"

  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_URL="${2:-}"
      shift 2
      ;;
    --source)
      SOURCE_DIR="${2:-}"
      shift 2
      ;;
    --sources-file)
      SOURCES_FILE="${2:-}"
      shift 2
      ;;
    --branch)
      BRANCH="${2:-}"
      shift 2
      ;;
    --version-prefix)
      VERSION_PREFIX="${2:-}"
      shift 2
      ;;
    --create-release)
      CREATE_RELEASE="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$SOURCE_DIR" ]]; then
  if ! pick_source_from_file "$SOURCES_FILE"; then
    echo "Source directory does not exist: $SOURCE_DIR" >&2
    echo "No valid directory found in sources file: $SOURCES_FILE" >&2
    exit 1
  fi
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 1
fi

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
VERSION_NAME="${VERSION_PREFIX}${TIMESTAMP}"

echo "Version name: $VERSION_NAME"
echo "Source directory: $SOURCE_DIR"
cd "$SOURCE_DIR"

if [[ ! -d ".git" ]]; then
  git init
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH"
fi

git add -A

git commit --allow-empty -m "sync skills: $VERSION_NAME"

git fetch origin
git fetch --tags origin
if git rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
  if ! git rebase "origin/$BRANCH"; then
    echo "Rebase conflict detected. Resolve conflicts, then run: git rebase --continue" >&2
    echo "After rebase completes, rerun this script." >&2
    exit 1
  fi
fi

TAG_NAME="$VERSION_NAME"
SUFFIX=1
while git rev-parse --verify "refs/tags/$TAG_NAME" >/dev/null 2>&1; do
  TAG_NAME="${VERSION_NAME}-${SUFFIX}"
  SUFFIX=$((SUFFIX + 1))
done

git tag -a "$TAG_NAME" -m "Version $TAG_NAME"

git push origin "$BRANCH"
git push origin "$TAG_NAME"

if [[ "$CREATE_RELEASE" == "true" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI is required for --create-release" >&2
    exit 1
  fi
  gh release create "$TAG_NAME" --target "$BRANCH" --title "$TAG_NAME" --notes "Automated sync for $TAG_NAME"
fi

echo "Sync complete"
echo "version_name=$TAG_NAME"
echo "commit=$(git rev-parse HEAD)"
echo "repo=$REPO_URL"
echo "branch=$BRANCH"
