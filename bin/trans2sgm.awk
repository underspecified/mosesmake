#!/usr/bin/awk -f

BEGIN {
    print "<tstset setid=\"translations\" srclang=\"src\" trglang=\"tgt\">"
    print "<DOC docid=\"doc\" sysid=\"sys\">"
}
{
    print "<hl>"
    print "    <seg id=" NF ">" $0 "</seg>"
    print "</h1>"
}
END {
    print "</DOC>"
}
