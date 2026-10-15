# Design tokens

The Dart constants in [lib/core/design_tokens.dart](../lib/core/design_tokens.dart) are generated from `tokens.json` in the central `Astrea-EIP/docs` repository, the shared source for the Astrea design system.

Do not edit the Dart output directly: update the canonical source in `Astrea-EIP/docs/design-tokens/tokens.json`, run `pnpm tokens:generate` in that repository, then synchronize this file.

The Montserrat and Inter families are bundled locally in `assets/fonts/`, with weights `400`, `600`, and `700`, and declared in `pubspec.yaml`. The files are distributed under the SIL Open Font License; `OFL.txt` notices are kept with each family.

In a pull request that updates these files, state the version used:

```text
Design tokens source: docs@<commit-or-tag>
```
