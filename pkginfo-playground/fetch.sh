#!/usr/bin/env bash

set -euo pipefail

rm -f ./*.whl
wget --quie-quiet https://files.pythonhosted.org/packages/3a/bb/40528a09a33845bd7fd75c33b3be7faec3b5c8f15f68a58931da67420fb9/hatchling-1.21.1-py3-none-any.whl
wget --quie-quiet https://files.pythonhosted.org/packages/f7/92/2f698e9ff35ad9682bcb77462a267a2b99b316fec48a2083ade7d1750b59/hatchling-1.22.0-py3-none-any.whl
wget --quie-quiet https://files.pythonhosted.org/packages/42/d4/7efdf54bdf0005a1da0359753123a45a7f3b8a03df3135ece52f8d2600e9/hatchling-1.22.1-py3-none-any.whl
wget --quie-quiet https://files.pythonhosted.org/packages/7d/a4/c69d252d72d61591c2f9354f30fe39927256ec0615f77d16d419a7b98d28/hatchling-1.22.2-py3-none-any.whl
wget --quie-quiet https://files.pythonhosted.org/packages/2d/31/b4ffda996d1e21bb7096fd377b0437f4925351c2f60dbe9563e83705744c/hatchling-1.22.3-py3-none-any.whl
