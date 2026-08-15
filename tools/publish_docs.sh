#!/usr/bin/env bash
set -euo pipefail

PROJECT_KEY="Nim-ACL"

die() {
  echo "PUBLISH_DOCS_FAIL: $*" >&2
  exit 1
}

ROOT="$(
  git rev-parse \
    --show-toplevel
)"

cd "$ROOT"

SOURCE_BRANCH="$(
  git branch \
    --show-current
)"

SOURCE_HEAD="$(
  git rev-parse HEAD
)"

[[ "$SOURCE_BRANCH" == "master" ]] ||
  die "publication source must be master"

[[ -z "$(
  git status \
    --porcelain=v1 \
    --untracked-files=all
)" ]] ||
  die "publication source worktree must be clean"

USER_NAME="$(
  git config user.name \
  || true
)"

USER_EMAIL="$(
  git config user.email \
  || true
)"

[[ -n "$USER_NAME" ]] ||
  die "git user.name is required"

[[ -n "$USER_EMAIL" ]] ||
  die "git user.email is required"

if [[ -x "$ROOT/.venv-docs/bin/python" ]]; then
  DOC_PYTHON="$ROOT/.venv-docs/bin/python"
else
  DOC_PYTHON="$(
    command -v python3
  )"
fi

[[ -x "$DOC_PYTHON" ]] ||
  die "documentation Python is unavailable"

fetch_publication_refs() {
  git fetch \
    origin \
    '+refs/heads/master:refs/remotes/origin/master' \
    '+refs/heads/gh-pages:refs/remotes/origin/gh-pages'
}

fetch_publication_refs

[[ "$(
  git rev-parse origin/master
)" == "$SOURCE_HEAD" ]] ||
  die "local master must exactly match origin/master"

TMP="$(
  mktemp -d \
    "${TMPDIR:-/tmp}/nim_acl_publish_docs.XXXXXX"
)"

SOURCE_WT="$TMP/source"
PAGES_WT="$TMP/gh-pages"

SOURCE_WT_REGISTERED="NO"
PAGES_WT_REGISTERED="NO"

cleanup() {
  rc=$?
  trap - EXIT

  if [[ "$PAGES_WT_REGISTERED" == "YES" ]]; then
    git -C "$ROOT" \
      worktree remove \
      --force \
      "$PAGES_WT" \
      >/dev/null 2>&1 \
      || true
  fi

  if [[ "$SOURCE_WT_REGISTERED" == "YES" ]]; then
    git -C "$ROOT" \
      worktree remove \
      --force \
      "$SOURCE_WT" \
      >/dev/null 2>&1 \
      || true
  fi

  git -C "$ROOT" \
    worktree prune \
    >/dev/null 2>&1 \
    || true

  rm -rf "$TMP"

  exit "$rc"
}

trap cleanup EXIT

git worktree add \
  --detach \
  "$SOURCE_WT" \
  "$SOURCE_HEAD"

SOURCE_WT_REGISTERED="YES"

(
  cd "$SOURCE_WT"

  "$DOC_PYTHON" \
    tools/generate_document.py
)

# Fail closed if master changed while docs were being generated.
fetch_publication_refs

[[ "$(
  git rev-parse origin/master
)" == "$SOURCE_HEAD" ]] ||
  die "origin/master changed during documentation generation"

git worktree add \
  --detach \
  "$PAGES_WT" \
  origin/gh-pages

PAGES_WT_REGISTERED="YES"

rsync \
  -a \
  --delete \
  "$SOURCE_WT/document_ja/" \
  "$PAGES_WT/document_ja/"

rsync \
  -a \
  --delete \
  "$SOURCE_WT/document_en/" \
  "$PAGES_WT/document_en/"

touch \
  "$PAGES_WT/.nojekyll"

git -C "$PAGES_WT" \
  add \
  document_ja \
  document_en \
  .nojekyll

if git -C "$PAGES_WT" \
  diff \
  --cached \
  --quiet
then
  echo "DOCUMENTATION_PUBLICATION_STATUS=NO_CHANGES"
  echo "DOCUMENTATION_PUBLICATION_PUSH_PERFORMED=NO"

else
  git -C "$PAGES_WT" \
    -c user.name="$USER_NAME" \
    -c user.email="$USER_EMAIL" \
    commit \
    --no-gpg-sign \
    -m "Publish generated documentation"

  PAGES_COMMIT="$(
    git -C "$PAGES_WT" \
      rev-parse HEAD
  )"

  PAGES_TREE="$(
    git -C "$PAGES_WT" \
      rev-parse HEAD^{tree}
  )"

  git -C "$PAGES_WT" \
    push \
    --porcelain \
    origin \
    HEAD:refs/heads/gh-pages

  REMOTE_PAGES_COMMIT="$(
    git ls-remote \
      origin \
      refs/heads/gh-pages |
    awk \
      '$2=="refs/heads/gh-pages"{print $1}'
  )"

  [[ "$REMOTE_PAGES_COMMIT" == "$PAGES_COMMIT" ]] ||
    die "remote gh-pages verification failed"

  echo "DOCUMENTATION_PUBLICATION_STATUS=PUBLISHED"
  echo "DOCUMENTATION_PUBLICATION_PUSH_PERFORMED=YES"
  echo "DOCUMENTATION_PUBLICATION_COMMIT=$PAGES_COMMIT"
  echo "DOCUMENTATION_PUBLICATION_TREE=$PAGES_TREE"
fi

[[ "$(git rev-parse HEAD)" == "$SOURCE_HEAD" ]] ||
  die "source HEAD changed during documentation publication"

[[ -z "$(
  git status \
    --porcelain=v1 \
    --untracked-files=all
)" ]] ||
  die "source worktree changed during documentation publication"

echo "SOURCE_MASTER_MUTATION=NO"
echo "SOURCE_FILE_MUTATION=NO"
echo "PUBLISH_DOCS_STATUS=OK"
