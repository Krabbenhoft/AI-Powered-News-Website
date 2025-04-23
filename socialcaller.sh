#!/bin/bash
inputString=$(< "2025-04-23.html")
echo "$inputString"
./social.py "$inputString"