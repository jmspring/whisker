#!/bin/bash
# Quick test script
echo "3" | lua main.lua stories/examples/shadows_of_thornhaven.whisker 2>&1 | head -50
