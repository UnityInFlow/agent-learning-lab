#!/usr/bin/env bash
# Reproduce the defect and its fix without spending a benchmark run: does the read inside the
# function clobber the caller's loop label?
set -u
broken() { local arm="$1" seq="$2"; read -r a s i <<<"x y z"; echo "  broken: label seen by printf = $seq"; }
fixed()  { local arm="$1" seq="$2" a s i; read -r a s i <<<"x y z"; echo "  fixed:  label seen by printf = $seq"; }
for i in 1 2; do
  s="$(printf '%02d' "$i")"
  echo "iteration $i, caller label s=$s"
  broken treated "$s"; echo "   -> caller s is now '$s'"; broken control "$s"
done
echo "---"
for i in 1 2; do
  s="$(printf '%02d' "$i")"
  echo "iteration $i, caller label s=$s"
  fixed treated "$s"; echo "   -> caller s is now '$s'"; fixed control "$s"
done
