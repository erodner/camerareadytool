import argparse
import re

parser = argparse.ArgumentParser(description="parse an .fls file and zip everything")
parser.add_argument('flsfile', help='fls file created with pdflatex -recorder ...')
args = parser.parse_args()

files = {}
with open(args.flsfile, 'r') as f:
    for line in f:
        line = line.rstrip()
        m = re.match("^INPUT\s+(.+)$", line)
        if m:
            fn = m.groups(1)[0]
            if fn.startswith("./"):
                fn = fn[2:]
            if not fn.startswith('/'):
                files[fn] = 1

print ("\n".join(files))
