# Project Defaults

Treat the rules in `.agents/AGENTS.md` and `.agents/rules/` as the default operating guidelines for this repository.

Priority order for work in this repo:
1. User instructions
2. Developer/system instructions
3. `.agents/AGENTS.md` and `.agents/rules/*.md`
4. Repository docs such as `README.md`

When editing Flutter code in this workspace, default to the following:
- Follow the monorepo structure in `.agents/rules/structure.md`
- Follow Flutter/Dart style guidance in `.agents/rules/flutter-dart.md`
- Follow BLoC conventions in `.agents/rules/bloc.md`
- Follow atomic design and shared UI usage in `.agents/rules/atomic-design-rule.md`
- Follow `auto_route` conventions in `.agents/rules/auto-route.md`
- Follow asset usage rules in `.agents/rules/assets-rules.md`
- Follow color and typography rules in `.agents/rules/color.md`

If a task conflicts with one of these rules, explain the tradeoff before making the change.
