# /assets — Audit DoDa assets

Lists all expected asset files and flags which ones are missing or zero-byte.

```bash
cd /mnt/c/Herve/doda

echo "=== Audio EN letters ==="
for l in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
  f="assets/audio/en/letters/$l.mp3"
  [ -s "$f" ] && echo "  ✓ $f" || echo "  ✗ MISSING: $f"
done

echo ""
echo "=== Audio EN words ==="
for w in apple ball cat dog egg fish goat house ice jar; do
  f="assets/audio/en/words/$w.mp3"
  [ -s "$f" ] && echo "  ✓ $f" || echo "  ✗ MISSING: $f"
done

echo ""
echo "=== Images words ==="
for w in apple ball cat dog egg fish goat house ice jar; do
  f="assets/images/words/$w.png"
  [ -s "$f" ] && echo "  ✓ $f" || echo "  ✗ MISSING: $f"
done

echo ""
echo "=== Fonts ==="
for font in Nunito-Regular Nunito-Bold Nunito-ExtraBold; do
  f="assets/fonts/$font.ttf"
  [ -s "$f" ] && echo "  ✓ $f" || echo "  ✗ MISSING: $f"
done
```
