#!/usr/bin/python

"""moses_check_align.py: SMT sentence alignment verification tool

Performs the following checks a set of files assumed to contain
sentence alignments for use in a statistical machine translation
system:

1) verifies that all files have the same number of lines 

2) verifies that all sentences are within defined minimum and maximum
   lengths in sentences



Usage: moses_check_align.py <set of aligned files>

Options:
-n, --min    minimum sentence length (default is 0)
-x, --max    maximum sentence length (default is 40)
-r, --ratio  maximum length ratio between sentence pairs (default is 2.0)
"""

import codecs
import getopt
import itertools
import sys

# utf-8 support
from utf8plz import *

def different_lengths(files, items):
   '''Print an error message and return True if files have different
   lengths in number of lines.'''
   lengths = map(len, items)
   if filter(lambda l: l != lengths[0], lengths):
      print >>sys.stderr, "ERROR! lengths of files don't match!"
      for f, l in zip(files, lengths):
         print >>sys.stderr, f, l
      print >>sys.stderr, ''
      return True
   else:
      return False

def less_than_min(file, line, line_num):
   '''Print an error message and return True if a line has a length
   less than options.min.'''
   length = len(line.split())
   if length <= 0 or length < options.min:
      print >>sys.stderr, "ERROR! line length is zero or less than min (%d)!" \
          % options.min
      print >>sys.stderr, "%s:%d: (%d): %s" % (file, line_num, length, line)
      print >>sys.stderr, ''
      return True
   else:
      return False

def greater_than_max(file, line, line_num):
   '''Print an error message and return True if a line has a length
   less than options.max.'''
   length = len(line.split())
   if length > options.max:
      print >>sys.stderr, "ERROR! line length is greater than max (%d)!" % \
          options.max
      print >>sys.stderr, "%s:%d: (%d): %s" % (file, line_num, length, line)
      print >>sys.stderr, ''
      return True
   else:
      return False

def bad_ratio(file1, line1, file2, line2, line_num):
   '''Print an error message and return True if the ratio between
   line1 and line2 is greater than options.ratio.'''
   length1 = len(line1.split())
   length2 = len(line2.split())
   try:
      r1 = float(length1) / length2
   except Exception:
      r1 = 0.0
   try:
      r2 = float(length2) / length1
   except Exception:
      r2 = 0.0
   for r in (r1, r2):
      if r > options.ratio:
         print >>sys.stderr, "ERROR! ratio between file lengths is greater",
         print >>sys.stderr, "than ratio (%2.2f > %2.2f)!" % (r, options.ratio)
         print >>sys.stderr, "%s:%d: (%d): %s" % \
             (file1, line_num, length1, line1)
         print >>sys.stderr, "%s:%d: (%d): %s" % \
             (file2, line_num, length2, line2)
         print >>sys.stderr, ''
         return True
   return False

def check_files(files):
   '''Check if files are aligned properly. Return error code 1 if they
   aren't.'''
   exit_code = 0
   if files:
      items = [[l.strip() for l in open(f).readlines()] for f in files]
      if different_lengths(files, items):
         exit_code = 1
      items = zip(*items)
      for n, lines in enumerate(items):
         data = zip(files, lines)
         for f, l in data:
            if less_than_min(f, l, n) or greater_than_max(f, l, n):
               exit_code = 1
         for (f1, l1), (f2, l2) in itertools.combinations(data, 2):
            if bad_ratio(f1, l1, f2, l2, n):
               exit_code = 1
   else:
      exit_code = 1
   return exit_code

def setup_opts():
    from optparse import OptionParser
    usage = '%prog [options] <alignment-files>'
    parser = OptionParser(usage=usage)
    parser.add_option('-n', '--min',
                      type='int', default='0',
                      help='minimum sentence length (default=0)')
    parser.add_option('-x', '--max',
                      type='int', default='40',
                      help='maximum sentence length (default=40)')
    parser.add_option('-r', '--ratio',
                      type='float', default='2.0',
                      help='maximum length ratio between sentence pairs (default=2.0)')
    return parser

def main():
    global options
    exit_code = 0
    parser = setup_opts()
    (options, args) = parser.parse_args()
    if len(args) < 2:
        parser.print_help(sys.stderr)
        exit_code = 1
    else:
       exit_code = check_files(args)
    sys.exit(exit_code)

if __name__ == '__main__':
   main()
