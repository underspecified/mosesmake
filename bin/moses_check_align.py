#!/usr/bin/python

"""moses_check_align.py: SMT sentence alignment verification tool

Performs the following checks a set of files assumed to contain sentence alignments for use in a statistical machine translation system:

1) verifies that all files have the same number of lines
2) verifies that all sentences are within defined minimum and maximum lengths in sentences

Usage: moses_check_align.py <set of aligned files>

Options:
-n, --min    specifies the minimum sentence length (default is 0)
-x, --max    specifies the maximum sentence length (default is 40)
"""

import codecs
import getopt
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

def less_than_min(files, line_num, items):
   '''Print an error message and return True if any line in items has
   a length less than min.'''
   lengths = [len(i.split()) for i in items]
   if filter(lambda l: l <= options.min, lengths):
      print >>sys.stderr, "ERROR! line lengths are less than min (%d)!" % \
          options.min
      for f, l, i in zip(files, lengths, items):
         print >>sys.stderr, "%s (%d): %s" % (f, line_num, l, i)
      print >>sys.stderr, ''
      return True
   else:
      return False

def greater_than_max(files, line_num, items):
   '''Print an error message and return True if any line in items has
   a length greater than max.'''
   lengths = [len(i.split()) for i in items]
   if filter(lambda l: l > options.max, lengths):
      print >>sys.stderr, "ERROR! line lengths are greater than max (%d)!" \
          % options.max
      for f, l, i in zip(files, lengths, items):
         print >>sys.stderr, "%s:%d (%d): %s" % (f, line_num, l, i)
      print >>sys.stderr, ''
      return True
   else:
      return False

def check_files(files):
   '''Check if files are aligned properly. Return error code 1 if they
   aren't.'''
   exit_code = 0
   if files:
      items = [[l.strip() for l in open(f).readlines()] for f in files]
      if different_lengths(files, items):
         exit_code = 1
      else:
         items = zip(*items)
         for n, d in enumerate(items):
            if less_than_min(files, n, d) or greater_than_max(files, n, d):
               exit_code = 1
   return exit_code

def setup_opts():
    from optparse import OptionParser
    usage = 'usage: %prog [options] <alignment-files>'
    parser = OptionParser(usage=usage)
    parser.add_option('-n', '--min',
              type='int', default='0',
              help='minimum sentence length (default=0)')
    parser.add_option('-x', '--max',
              type='int', default='40',
              help='maximum sentence length (default=40)')
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
