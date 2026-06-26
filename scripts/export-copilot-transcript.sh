#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TRANSCRIPT_ROOT="${HOME}/.vscode-server/data/User/workspaceStorage"

SESSION_ID=""
REPO_TERM="reviewlens-ai"
OUTPUT_DIR="${REPO_ROOT}/ai-transcripts"
SKIP_READABLE="false"

show_help() {
  cat <<'HELP'
Usage:
  export-copilot-transcript.sh [options]

Options:
  -s, --session-id ID         Export one exact transcript session
  -r, --repo-term TERM        Text to match in transcript contents
                              Default: reviewlens-ai
  -o, --output-dir PATH       Output directory
                              Default: ./ai-transcripts
  --skip-readable             Only copy raw jsonl, skip markdown export
  -h, --help                  Show this help

Behavior:
  - Without --session-id, the script finds the newest transcript that
    contains the repo term and exports that one.
  - The raw transcript is copied as .raw.jsonl.
  - A readable markdown version is written as .readable.md.
HELP
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--session-id)
      SESSION_ID="${2:-}"
      shift 2
      ;;
    -r|--repo-term)
      REPO_TERM="${2:-}"
      shift 2
      ;;
    -o|--output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --skip-readable)
      SKIP_READABLE="true"
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo >&2
      show_help
      exit 1
      ;;
  esac
done

find_session_file() {
  local session_id="$1"
  find "${TRANSCRIPT_ROOT}" -path "*/GitHub.copilot-chat/transcripts/${session_id}.jsonl" -type f -print -quit
}

find_latest_matching_transcript() {
  local match_term="$1"
  local transcript
  local matches=()

  while IFS= read -r -d '' transcript; do
    if [[ -z "${match_term}" ]] || grep -q -F -- "${match_term}" "${transcript}"; then
      matches+=("${transcript}")
    fi
  done < <(find "${TRANSCRIPT_ROOT}" -path '*/GitHub.copilot-chat/transcripts/*.jsonl' -type f -print0)

  if [[ "${#matches[@]}" -eq 0 ]]; then
    return 1
  fi

  ls -t "${matches[@]}" | head -n 1
}

if [[ -n "${SESSION_ID}" ]]; then
  SRC="$(find_session_file "${SESSION_ID}")"
  if [[ -z "${SRC}" ]]; then
    echo "No transcript found for session id: ${SESSION_ID}" >&2
    exit 1
  fi
else
  SRC="$(find_latest_matching_transcript "${REPO_TERM}")" || {
    echo "No transcript matched repo term: ${REPO_TERM}" >&2
    exit 1
  }
fi

SESSION_NAME="$(basename "${SRC}" .jsonl)"
RAW_OUT="${OUTPUT_DIR}/copilot-session-${SESSION_NAME}.raw.jsonl"
MD_OUT="${OUTPUT_DIR}/copilot-session-${SESSION_NAME}.readable.md"

mkdir -p "${OUTPUT_DIR}"
cp "${SRC}" "${RAW_OUT}"

echo "Wrote raw transcript:"
echo "  ${RAW_OUT}"

if [[ "${SKIP_READABLE}" == "true" ]]; then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed; skipping readable markdown generation." >&2
  exit 0
fi

jq -r '
  def msgtext:
    (.data.content // .data.message // "");
  def role:
    if .type=="user.message" then "USER"
    elif .type=="assistant.message" then "ASSISTANT"
    else "OTHER" end;

  select(.type=="user.message" or .type=="assistant.message")
  | "## " + role + " | " + (.timestamp // "") + "\n\n"
    + (if (msgtext|length) > 0 then msgtext else "(no text content)" end) + "\n"
    + (
        if (.type=="assistant.message" and (.data.toolRequests|type)=="array" and (.data.toolRequests|length)>0)
        then "\nTools:\n" + ((.data.toolRequests | map("- " + (.name // "unknown"))) | join("\n")) + "\n"
        else ""
        end
      ) + "\n"
' "${SRC}" > "${MD_OUT}"

echo "Wrote readable transcript:"
echo "  ${MD_OUT}"