# Install the Official Grill with Docs Skill

This repository does not vendor or modify the official skill. Each teammate installs it into their own local agent environment.

From the repository root, run:

```bash
bash scripts/install-grill-with-docs.sh
```

The script installs the official `grill-with-docs` skill and its required official dependencies: `grilling` and `domain-modeling`.

After installation, start the workflow manually with:

```text
/grill-with-docs
```

The script requires Node.js/npm because the official distribution uses `npx`. It does not download skill files into this repository.
