#!/bin/bash
source "$(dirname $(realpath $0))/paths.sh"

function print-help() {
  printf "Usage: $0 [options]\n\n" >&2
  printf "Options: \n" >&2
  printf " -t %-15s Specify the template to use\n\n" "<template>" >&2
  printf " -l %-15s List the available templates\n\n" >&2
  printf " -p %-15s Specify the playground name to use\n\n" "<playground>" >&2
  printf " -L %-15s List the existing playgrounds\n\n" >&2
  printf " -j %-15s Use the most recently-edited playground\n\n" "" >&2
  printf " -n %-15s Create a new playground.\n" >&2
  printf "    %-15s If -p is specified, it will be used for\n" >&2
  printf "    %-15s the name of the new playground. Otherwise,\n" >&2
  printf "    %-15s the playground will be assigned a unique\n" >&2
  printf "    %-15s sequential name.\n\n" >&2
  printf " -o %-15s Open the playground source files in Vim.\n" >&2
  printf "    %-15s The playground files will be opened in the\n" >&2
  printf "    %-15s Vim servers whose ServerNames contain the\n" >&2
  printf "    %-15s string 'PLAY'.\n\n" >&2
  printf " -P %-15s Print the playground path\n\n" "<playground>" >&2
  printf " -q %-15s Run in quiet mode\n\n" "" >&2
  printf " -h %-15s Print this message\n\n" >&2
  printf " The following options must be used in conjunction with -p and/or -n:\n" >&2
  printf " -b %-15s Build the playground\n\n" >&2
  printf " -r %-15s Run the playground. Does not rebuild.\n\n" # >&2 #unless:\n" >&2
  printf " -R %-15s Build & Run the playground\n\n" >&2
  printf " -w %-15s Watch the playground, re-building & -running it\n"
  printf "    %-15s each time a source file changes.\n\n" >&2
}

QUIET=0

function log() {
  if [[ $QUIET == 1 ]]; then
    return
  fi
  echo $@ >&2
}

function template-path() {
  echo "$TEMPLATESDIR/$1"
}

function list-templates() {
  ls -1 $TEMPLATESDIR
}

function template-exists() {
  list-templates | grep -cx $1
}

function playground-path() {
  if [[ $2 == 1 ]]; then
    if [[  "$(playground-exists $1)" == 0 ]]; then
      log "Playground '$1' does not exist. Use -n to create it."
      exit 1
    fi
  fi
  realpath "$PLAYGROUNDSDIR/$1"
}

function playground-build-path() {
  local p="$(playground-path $1)"
  echo "$(realpath $p/$BUILDPATH)/$1"
}

function list-playgrounds() {
  ls -1 $PLAYGROUNDSDIR
}
function playground-most-recent() {
  ls -t1 $PLAYGROUNDSDIR | head -n 1
}

function playground-exists() {
  list-playgrounds | grep -cx $1
}

function list-playground-source-files() {
  local files="$(find -E $(playground-path $1) -regex '^.*\.go$')"
  for file in $files; do
    realpath $file
  done
}

function next-playground() {
  if [[ $(list-playgrounds | wc -l | sed 's/ //g') == "0" ]]; then
    echo 1
  else
    list-playgrounds | sort -nr | head -n1 | awk '{print $1+1}'
  fi
}

function make-playground() {
  mkdir "$(playground-path $1)"
  cp -R "$(template-path $2)/" "$(playground-path $1)"
}

function build-playground() {
  local sources="$(list-playground-source-files $1 | paste -sd ' ' -)"
  err=$(go build -o "$(playground-build-path $1)" $sources 2>&1 1>/dev/null)
  local code=$?
  if [[ "$code" != 0 ]]; then
    printf "Build failed with exit code $code:\n" >&2
    printf "$err" | awk '/^[^#]/ { print $0 }' | awk '{ print "    " $0 }' >&2
    exit $code
  fi
}

function run-playground() {
  p=$(playground-build-path $1)

  if [[ ! -f $p ]]; then
    log "Playground $1 has not been built yet. Use -b to build it, or -R to automatically build and run playgrounds in the future."
    exit 1
  fi

  local cmd="$p"

  local pp="$GOPATH/bin/pp"
  if [[ -x $pp ]]; then
    cmd="$p 2>&1 | $pp"
  fi

  eval "$cmd"
  local code=$?
  if [[ $code > 0 ]]; then
    log "Playground failed with exit code $code. Exiting..."
    exit $code
  fi
}

function watch-playground() {
  $SCRIPTSDIR/watch.sh $1 "$(list-playground-source-files $1)"
}

TEMPLATE="default"
PLAYGROUND="$(next-playground)"
SETP=0
NEW=0
OPEN=0
BUILD=0
RUN=0
WATCH=0
FROMWATCH=0

while getopts "hqt:p:jnolLP:brRwW" opt; do
  case $opt in
    h)
      print-help
      exit 1
      ;;
    q)
      QUIET=1
      ;;
    t)
      if [[ "$(template-exists $OPTARG)" == 1 ]]; then
        TEMPLATE=$OPTARG
      else
        log "Template not found: $OPTARG"
        exit 1
      fi
      ;;
    l)
      list-templates
      exit 0
      ;;
    p)
      PLAYGROUND=$OPTARG
      SETP=1
      ;;
    j)
      PLAYGROUND=$(playground-most-recent)
      SETP=1
      ;;
    L)
      list-playgrounds
      exit 0
      ;;
    n)
      NEW=1
      ;;
    o)
      OPEN=1
      ;;
    P)
      playground-path $OPTARG 1
      exit 0
      ;;
    b)
      BUILD=1
      ;;
    r)
      RUN=1
      ;;
    R)
      BUILD=1
      RUN=1
      ;;
    w)
      WATCH=1
      ;;
    W)
      QUIET=1
      FROMWATCH=1
      ;;
    \?)
      log "Invalid option: -$OPTARG"
      print-help
      exit 1
      ;;
  esac
done

if [[ "$(playground-exists $PLAYGROUND)" == 0 ]]; then
  if [[ "$NEW" == 1 ]]; then
    if [[ "$PLAYGROUND" == "" ]]; then
      log "Playground name cannot be empty"
      exit 1
    fi
    log "Creating playground '$PLAYGROUND' with template '$TEMPLATE'"
    make-playground $PLAYGROUND $TEMPLATE
  elif [[ "$SETP" == 1 ]]; then
    log "Playground '$PLAYGROUND' does not exist. Use -n to create it."
    exit 1
  else
    log "Please specify a playground name with -p."
    exit 1
  fi
elif [[ "$NEW" == 1 ]]; then
  log "Playground '$PLAYGROUND' already exists. Remove -n to select it."
  exit 1
fi

log "Playground $PLAYGROUND"

if [[ "$OPEN" == 1 ]]; then
  log "Opening playground..."

  vs="$(vim --serverlist | grep 'PLAY')"           # List of Vim Servers, newline-delimited
  sf="$(list-playground-source-files $PLAYGROUND)" # List of Source Files, newline-delimited

  if [[ "$vs" == "" ]]; then
    log 'No Vim servers found.'
    exit 1
  fi

  i=0
  v="$(echo "$vs" | wc -l | sed 's/ //g')" # Number of Vim Servers
  s="$(echo "$sf" | wc -l | sed 's/ //g')" # Number of Source Files
  d=$((($v-$s)))

  while read -r file; do
    if [[ $i > $v || $i > $s ]]; then
      break
    fi

    server=$(echo "$vs" | head -n $((($i+1))) | tail -n 1)
    vim --servername "$server" --remote "$file"

    ((i++))
  done <<< "$sf"

  # If there are more Vim Servers than Source Files,
  # open empty buffers in them.
  if [[ $d > 0 ]]; then
    t=$((($d+$i-1)))
    for j in $(seq $i $t); do
      server=$(echo "$vs" | head -n $((($j+1))) | tail -n 1)
      vim --servername "$server" --remote-send "<ESC><ESC>:enew<ENTER>"
    done
  fi
fi

if [[ "$BUILD" == 1 ]]; then
  if [[ $QUIET == 0 || $FROMWATCH == 1 ]]; then
    printf "Building playground...\n" >&2
  fi

  $(build-playground $PLAYGROUND)
  res=$?
  if [[ $res != 0 ]]; then
    printf "\n" >&2
    exit $res
  fi

  if [[ $QUIET == 0 || $FROMWATCH == 1 ]]; then
    printf "Done.\n" >&2
  fi
  log "Success."
fi

if [[ "$RUN" == 1 ]]; then
  if [[ $QUIET == 0 || $FROMWATCH == 1 ]]; then
    printf "Running playground...\n --- \n\n" >&2
  fi
  run-playground $PLAYGROUND
  if [[ $QUIET == 0 || $FROMWATCH == 1 ]]; then
    printf "\n ---\n\n" >&2
  fi
  log "Success."
fi

if [[ "$WATCH" == 1 ]]; then
  if [[ $QUIET == 0 ]]; then
    printf "Watching playground...\n" >&2
  fi
  watch-playground $PLAYGROUND
fi
