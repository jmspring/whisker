#!/bin/bash
# Test Fighter class creation
echo "Testing Fighter class creation..."
echo -e "3\n1\n1\nquit" | lua main.lua stories/examples/shadows_of_thornhaven.whisker 2>&1 | tail -100
