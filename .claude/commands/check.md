# /check — Analyze and test the DoDa project

Runs static analysis then the test suite.

```bash
cd /mnt/c/Herve/doda && flutter analyze && flutter test
```

For a quick compile check without running tests:
```bash
flutter build apk --debug 2>&1 | head -60
```
