# CAMBRIDGE LICENSES THE SOFTWARE "AS IS," AND MAKES NO EXPRESS OR IMPLIED WARRANTY OF ANY KIND. 
# CAMBRIDGE SPECIFICALLY DISCLAIMS ALL INDIRECT OR IMPLIED WARRANTIES TO THE FULL EXTENT ALLOWED BY APPLICABLE LAW,
# INCLUDING WITHOUT LIMITATION ALL IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, TITLE OR FITNESS FOR ANY PARTICULAR PURPOSE. 

# THE SOFTWARE IS DELIVERED IN ACCORDANCE WITH TERMS AND CONDITIONS SET OUT IN THE AGREED MEMORANDUM OF AGREEMENT (P5056-C-001 V1.0)
# AND THE SCHEDULE OF TECHNOLOGY WITH A RESTRICTIVE ENCUMBRANCE (P5056-M-005 V1.0). 

#!/bin/bash

TEMP_DIR=$(mktemp -d)
FINAL_ZIP=$PWD/'connect-auth-lambda.zip'
pip install -r requirements.txt --target $TEMP_DIR
# create a zip named destination from the temp dir which includes the requirements
pushd $TEMP_DIR
zip $FINAL_ZIP -r .
popd
# update final zip to include gpt_lambda.py
zip -g $FINAL_ZIP -r . --exclude 'scripts/*' 'venv/*' '**/__pycache__/*' .DS_Store README.md .gitignore requirements.txt requirements-dev.txt '*.zip' package.sh
rm -rf $WORK_DIR