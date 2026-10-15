# Design tokens

Les constantes Dart de [lib/core/design_tokens.dart](../lib/core/design_tokens.dart) sont générées depuis `tokens.json` du dépôt central `Astrea-EIP/docs`, source partagée du design system Astrea.

Ne modifiez pas directement la sortie Dart : mettez à jour la source canonique dans `Astrea-EIP/docs/design-tokens/tokens.json`, lancez `pnpm tokens:generate` dans ce dépôt, puis synchronisez ce fichier.

Les familles Montserrat et Inter sont embarquées localement dans `assets/fonts/`, avec les graisses `400`, `600` et `700`, et déclarées dans `pubspec.yaml`. Les fichiers sont distribués sous la licence SIL Open Font License ; les notices `OFL.txt` sont conservées avec chaque famille.

Dans une PR qui met à jour ces fichiers, indiquer la version utilisée :

```text
Design tokens source: docs@<commit-or-tag>
```
