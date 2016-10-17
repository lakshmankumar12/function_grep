#!/bin/bash 

IGNORE_CASE=0
if [ "$1" = "-i" ] ; then
    IGNORE_CASE=1
    shift 1;
fi

if [ -z "$1" ] ; then
    echo "Supply sub-directory pattern grep from" ; 
    exit 1;
fi

export filelist_pattern=$1;
curr_dir=`pwd`;
shift 1;

REGEX=$1

REGEX=$(echo $REGEX | sed 's/\\</\\\\</')
REGEX=$(echo $REGEX | sed 's/\\>/\\\\>/')

greop_file=$curr_dir/grepOp

files=$(git ls-files | egrep $filelist_pattern | egrep '\.([chlys](xx|pp)*|cc|hh|tcl)$')

no_file=$(echo "$files" | wc -l)

echo "Grepping in $no_file files"

if [ -z "$1" ] ; then
    echo "Supply grep patter!!" ;
    exit 1;
fi

count=0

for i in $files ; do 

  gawk -v re=$REGEX -v file=$i -v ic=$IGNORE_CASE '

  BEGIN {
    CURR_FUNCTION="Outside-context"
    CURR_FUNCTION_LINE=0
    FUNCTION="None-found"
    FUNCTION_LINE=0
    if ( ic == 1 ) {
      IGNORECASE=1
    }
  }

  /^\{[[:space:]]*$/ {
   CURR_FUNCTION = FUNCTION
   next
  }

  /^\}[[:space:]]*$/ {
   CURR_FUNCTION = "Outside-context"
   CURR_FUNCTION_LINE = FUNCTION_LINE
   next
  }

  /[[:alnum:]]+[[:space:]]*\(/ { # mind you.. this can match even-function-calls.
    a=$0;
    match(a,"[[:alnum:]]+[[:space:]]*\\(",arr);
    FUNCTION=arr[0]
    FUNCTION_LINE=NR
  }

  $0 ~ re {
    printf "%s:%d:in-function %s at line %d: %s\n",file,NR,CURR_FUNCTION,CURR_FUNCTION_LINE,$0
  } ' $i

  count=$(expr $count + 1)
  rem=$(expr $count % 100)
  if [ $rem -eq 0 ] ; then >&2 echo "Finished $count files" ; fi

done > $greop_file


