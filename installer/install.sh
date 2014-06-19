#!/bin/bash
#
# Date:   2014-06-17
# Author: Daniel Zapico
# Desc:   diskUsageMon installer
#_____________________________________________________

LSSCRIPT="$(ls -l $0)"
echo "$LSSCRIPT" | awk '$1~/^l/{ecode="1";exit}{ecode="0";exit}END{exit ecode}'
if [[ "$?" == "1" ]]; then
  LINKDIR="$(echo $LSSCRIPT | awk '{print $(NF-2)}' | xargs dirname)"
  cd "$LINKDIR"
  SDIR="$(echo $LSSCRIPT | awk '{print $NF}' | xargs dirname)"
  cd "$SDIR"
  SDIR="$(pwd)"
  TOOLDIR="$(dirname $SDIR)"
else
  # Script and Tool directories
  TOOLDIR="$(cd $(dirname $0) && cd .. && pwd)"
  SDIR="$(cd $(dirname $0) && pwd)"
  # Change current directory to work directory
  cd "$SDIR"
fi

# Get script's name
SNAME="$(basename $0)"

# Get the user name
USER="$(id | nawk '{sub(/^.*\(/,"",$1); sub(/\).*$/,""); print}')"

# Get hostname
HOSTNAME="$(hostname)"

# Date and time
DATENTIME="$(date "+%Y%m%d%H%M%S")"

# Get Exec-line
EXECLINE="$0 $@"

# Includes
. "$SNAME.props"
. "$SNAME.exitcodes"
. "$SNAME.functions"

### MAIN ###
_ParseInputParams "$@"
if [[ "$UNINSTALL" != "1" ]]; then
  _InstalldiskUsageMon
else
  if [[ "$UNINSTALL" == "1" ]]; then
    _UninstalldiskUsageMon
  else
    echo "Error: not valid operation requested"
    _Usage
    exit "$NOTVALIDOP"
  fi
fi

exit "$DEFAULTEXITCODE"
############
