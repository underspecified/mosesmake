#!/usr/bin/env python
# -*- coding: utf-8 -*-
###############################################################################

# utf-8 i/o plz!
from functools import partial
import codecs
open = partial(codecs.open, encoding='utf-8')

import sys
reload(sys)
sys.setdefaultencoding('utf-8')
sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
sys.stdin = codecs.getreader('utf-8')(sys.stdin)
sys.stderr = codecs.getwriter('utf-8')(sys.stderr)
