#!/bin/bash

if [ ! -f "config.sh" ]; then
    echo "Error: config.sh not found. Creating a default one."
    cat > config.sh <<EOF
THIRDORDER_PATH=""
EOF
    echo "Please edit config.sh to set THIRDORDER_PATH, then run this script again."
    exit 1
fi

source ./config.sh

if [ -z "$THIRDORDER_PATH" ]; then
    echo "Error: THIRDORDER_PATH is not set in config.sh. Please edit it and try again."
    exit 1
fi

if [ ! -f "$THIRDORDER_PATH" ]; then
    echo "Error: thirdorder file not found at $THIRDORDER_PATH. Please check the path."
    exit 1
fi

ORIGINAL_PATH="/home/general/lvjinxi/Software/thirdorder/thirdorder_vasp.py"

if [ ! -f "BatchX1.sh" ]; then
    echo "Error: BatchX1.sh not found."
    exit 1
fi

TEMPLATE_FILE="BatchX1_template.sh"
cp BatchX1.sh "$TEMPLATE_FILE"

sed -i "s|$ORIGINAL_PATH|$THIRDORDER_PATH|g" "$TEMPLATE_FILE"

echo "Configuration completed! Generated template: $TEMPLATE_FILE"
echo "You can now use $TEMPLATE_FILE for your calculations."

mkdir template
cp BatchX1_template.sh template
cp -r pr/ template/
cp -r plot/ template/