#!/usr/bin/python

from __future__ import print_function
import argparse
import sys
import re
import fileinput

parser = argparse.ArgumentParser()
parser.add_argument("-B","--begin", help="begin with this match")
parser.add_argument("-E","--end", help="end with this match")
parser.add_argument("-i","--ignorecase", help="ignore case", action="store_true")
parser.add_argument("-I","--ignorecontext", help="dont print matching context", action="store_true")
parser.add_argument("file_name", help="file-to-match")

args = parser.parse_args()

def usage(argv0):
  print("%s -B/--begin <begin-pattern> -E/--end <end-pattern> [-i/--ignorecase] [-I/ignorecontext] <file(or stdin)>")
  sys.exit(1)

if not args.begin or not args.end:
  usage(sys.argv[0])

flags = 0
ignore_context = 0

if args.ignorecase:
  flags |= re.I

if args.ignorecontext:
  ignore_context = 1

begin=re.compile(args.begin, flags)
end=re.compile(args.end, flags)

in_match = 0

if args.file_name == '-':
  fd = sys.stdin
else:
  fd = open(args.file_name,'r')

for line in fd:
  if not in_match:
    if begin.search(line):
      if not ignore_context:
        print(line, end="")
      in_match = 1
  else:
    if end.search(line):
      if not ignore_context:
        print(line, end="")
      in_match = 0
    else:
      print(line, end="")

