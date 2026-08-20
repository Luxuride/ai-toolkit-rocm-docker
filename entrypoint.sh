#!/bin/bash
set -e

/opt/init_defaults.sh

echo "Starting AI Toolkit UI..."
cd /opt/ai-toolkit/ui && npm run start