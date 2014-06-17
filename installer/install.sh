#!/bin/bash
#
# Date:   2014-06-17
# Author: Daniel Zapico
# Desc:   diskUsageMon installer
#_____________________________________________________

ICETOOLSDIR="/opt/icetools"
TARGETDIR="$ICETOOLSDIR/diskUsageMon"
GREEN="\033[01;32m"
RED="\033[01;31m"
NORMAL="\033[01;00m"
TMPBASHRC="/tmp/bash.bashra.new.$(date +%Y%m%d%H%M%S)"

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

# Check if TARGETDIR/script exist
if [[ -d "$TARGETDIR/script" ]]; then
  # TARGETDIR exist. Check if it has any files inside already
  NUMFILES="$(ls -la $TARGETDIR | wc -l)" 
  if [[ "$NUMFILES" > "3" ]]; then
    echo "Error: $TARGETDIR is not empty. Aborting installation"
    exit "1"
  fi
else
  echo -n "Do you want to create $TARGETDIR/script? [Y|n]: "
  read ANSWER
  if [[ "$ANSWER" == "n" || "$ANSWER" == "N" ]]; then
    echo "Installation aborted by the user"
    exit 2
  fi
  echo -n "Creating $TARGETDIR ... "
  mkdir -p "$TARGETDIR/script"
  if [[ "$?" != "0" ]]; then
    echo -e "[${RED}Fail${NORMAL}]"
  else
    echo -e "[${GREEN}Ok${NORMAL}]"
  fi
fi

# Create ICETOOLSDIR/bin if it doesn't exist
if [[ ! -d "$ICETOOLSDIR/bin" ]]; then
  mkdir -p "$ICETOOLSDIR/bin"
fi

# Confirm the source directory exist
echo -n "Confirm that the source directory exist ... "
if [[ ! -d "$TOOLDIR/script" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  echo "Error: $TOOLDIR/script cannot be found. Nothing to install at all"
  exit "2"
else
  echo -e "[${GREEN}Ok${NORMAL}]"  
fi

# Confirm the source files exist
echo -n "Checking if files to be installed exist ... "
NUMFILES="$(ls $TOOLDIR/script | wc -l)"
if [[ "$NUMFILES" == "0" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  echo "Error: Directory $TOOLDIR/script is empty. Nothing to install at all"
  exit 3
else
  echo -e "[${GREEN}Ok${NORMAL}]"
fi

  
# Check if each file exist and has a correct sha512sum
for file in diskUsageMon.sh diskUsageMon.sh.functions diskUsageMon.sh.exitcodes  diskUsageMon.sh.props; do
  echo -n "   $file ... "
  if [[ -e "$TOOLDIR/script/$file" ]]; then
    echo -e "[${GREEN}Ok${NORMAL}]"
  else
    echo -e "[${RED}Fail${NORMAL}]"
    exit 4
  fi
done

# Copy source files to TARGETDIR/script
cp $TOOLDIR/script/diskUsageMon.sh* $TARGETDIR/script/

# Set permissions
echo -n "Setting permissions ... "
chmod 644 $TARGETDIR/script/*
RET1="$?"
chmod 755 $TARGETDIR/script/*.sh
RET2="$?"
if [[ "$RET1" != "0" || "$RET2" != "0" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  exit 5
else
  echo -e "[${GREEN}Ok${NORMAL}]"
fi

# Prepare ICETOOLSDIR_PATTERN to be used by AWK
ICETOOLSDIR_PATTERN="$(echo "$ICETOOLSDIR" | awk '{gsub(/\//,"\\/"); print}')"
# Change PATH in /etc/bash.bashrc
echo -n "Verifiying / Updating PATH variable in /etc/bash.bashrc ... "
awk '/^[ ]*PATH=/ && !/'$ICETOOLSDIR_PATTERN'/{PATH=$1; split(PATH,vec,"="); print "PATH=\"'$PATH':'$ICETOOLSDIR/bin'\""; modified="1"}/^[ ]*PATH=.*'$ICETOOLSDIR_PATTERN'/{pathok="1"; print}!/^[ ]*PATH=/{print}END{if(modified == "1" || pathok == "1")exit "0"; exit "1"}' /etc/bash.bashrc > "$TMPBASHRC"

if [[ "$?" != "0" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  exit 6
fi

# Backup current bash.bashrc file
cp -p /etc/bash.bashrc /etc/bash.bashrc.bak.$(date +%Y%m%d%H%M%S)

if [[ "$?" != "0" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  echo "Error: couldn't backup current /etc/bash.bashrc file"
  rm "$TMPBASHRC"
  exit 7
fi

# Update bash.bashrc
mv "$TMPBASHRC" /etc/bash.bashrc

if [[ "$?" != "0" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  exit 8
else
  echo -e "[${GREEN}Ok${NORMAL}]"
fi

# Create links in ICETOOLSDIR/bin
echo -n "Creating links in $ICETOOLSDIR/bin ... "
ln -s $TARGETDIR/script/diskUsageMon.sh $ICETOOLSDIR/bin/diskUsageMon.sh Â&>/dev/null

if [[ "$?" != "0" ]]; then
  echo -e "[${RED}Fail${NORMAL}]"
  exit 9
else
  echo -e "[${GREEN}Ok${NORMAL}]"
fi

exit 0
