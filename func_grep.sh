#!/bin/bash

#Notes: Make sure you have a tags database build already
#Exuberant tags format is required - http://ctags.sourceforge.net/FORMAT
#For eg: ctags -L cscope.files will build ctags from all files listed in the file cscope.files

usage()
{
  echo "$0 (-f|-s|-m) <list-of-grep-separated-by-space>"
  exit 1
}

if [ ! -f tags ] ; then
  echo "No tags file found !"
fi

choice=""

while getopts "fsm" opt; do
  case $opt in
    f)
      choice="f"
      ;;
    s)
      choice="s"
      ;;
    m)
      choice="m"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage $0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z $choice ] ; then
  echo "Sorry.. none of f/s/m is chosen"
  usage
fi

shift $((OPTIND-1))

if [ $# -eq 0 ] ; then
  echo "mention some grep pattern"
  usage
fi

command=""
for i in $* ; do
  command="$command | grep -i --color=always $i"
done

grep_arg="';\"[[:space:]]$choice'"
final_command="egrep $grep_arg tags $command | less -r -S"

eval $final_command
