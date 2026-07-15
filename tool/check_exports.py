import os
import re
from pathlib import Path

lib_dir = Path(__file__).resolve().parent.parent / 'lib'
src_dir = lib_dir / 'src'
export_file = lib_dir / 'openboard_wrapper.dart'

src_files = {f.name for f in src_dir.glob('*.dart')}

exported = set()
with open(export_file) as f:
    for line in f:
        line = line.strip()
        if line.startswith('//'):
            continue
        m = re.match(r"export\s+'src/([\w_]+\.dart)';", line)
        if m:
            exported.add(m.group(1))

not_exported = sorted(src_files - exported)
if not_exported:
    print("Files in lib/src/ NOT exported by openboard_wrapper.dart:")
    for f in not_exported:
        print(f"  {f}")
else:
    print("All files in lib/src/ are exported by openboard_wrapper.dart.")
