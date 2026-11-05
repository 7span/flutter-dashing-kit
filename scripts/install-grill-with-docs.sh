#!/usr/bin/env bash

set -euo pipefail

if ! command -v npx >/dev/null 2>&1; then
  echo "npx is required to install the official grill-with-docs skill."
  echo "Install Node.js, then run this script again."
  exit 1
fi

skill_source="mattpocock/skills"

# grill-with-docs delegates to these two official dependencies.
npx skills@latest add "$skill_source" --skill=grill-with-docs
npx skills@latest add "$skill_source" --skill=grilling
npx skills@latest add "$skill_source" --skill=domain-modeling

echo "Official grill-with-docs and its dependencies are installed for this agent environment."
echo "Start it manually with: /grill-with-docs"
