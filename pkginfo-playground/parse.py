from pkginfo import Wheel

from pathlib import Path

for p in sorted(Path(".").glob("*.whl")):
    print(f"Parsing {p}")
    whl = Wheel(str(p))
    whl.extractMetadata()
    print(f"\tmetadata_version: {whl.metadata_version}")
    print(f"\trequires_dist: {whl.requires_dist}")
