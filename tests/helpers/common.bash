command_exists() {
  command -v "$1" >/dev/null 2>&1
}

PYTHON3_MIN_VERSION="3.9"

assert_python3_available() {
  local bin found major minor min_major min_minor
  if ! command_exists python3; then
    fail "python3 is not on PATH; install Python $PYTHON3_MIN_VERSION or newer"
    return 1
  fi

  bin="$(command -v python3)"
  found="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)" || found=""
  if [[ ! "$found" =~ ^[0-9]+\.[0-9]+$ ]]; then
    fail "python3 at $bin answered the version probe with '$found' instead of major.minor"
    return 1
  fi

  major="${found%%.*}"
  minor="${found#*.}"
  min_major="${PYTHON3_MIN_VERSION%%.*}"
  min_minor="${PYTHON3_MIN_VERSION#*.}"
  if (( 10#$major < 10#$min_major || (10#$major == 10#$min_major && 10#$minor < 10#$min_minor) )); then
    fail "python3 at $bin is $found, older than required $PYTHON3_MIN_VERSION"
    return 1
  fi
}
