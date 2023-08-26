#!/usr/bin/env python3

import hashlib
import sys

if len(sys.argv) != 2:
    print('ERROR: Script expects an argument')
    sys.exit(1)

service_name = sys.argv[1]  # "this string holds important and private information"

hashed_string = hashlib.sha256(service_name.encode("utf-8")).hexdigest()[:10]
# print(hashed_string)

print(f"CDK Qualifier: {hashed_string}")
