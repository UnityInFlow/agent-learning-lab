#!/usr/bin/env bash
# Records machine conditions DURING the registered batch, so contamination is a measurement
# rather than something reconstructed afterwards. The previous batch (20260910T132311Z) was
# stopped for load it had no contemporaneous record of. Appends every 5 minutes while the
# batch pid is alive. Read-only; costs one `uptime` and one `ps` per sample.
BATCH_PID="$1"; OUT="$(dirname "$0")/load-samples.tsv"
printf 'ts\tload1\tload5\tload15\truns_done\ttop_cpu_proc\ttop_cpu\n' > "$OUT"
while kill -0 "$BATCH_PID" 2>/dev/null; do
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  la="$(uptime | sed 's/.*averages*: //' | tr -d ',' )"
  l1="$(echo "$la" | awk '{print $1}')"; l5="$(echo "$la" | awk '{print $2}')"; l15="$(echo "$la" | awk '{print $3}')"
  rd="$(awk -F'\t' 'NR>6{c++} END{print c+0}' "$(dirname "$0")/manifest.tsv" 2>/dev/null)"
  top="$(LC_ALL=C ps -Ao pcpu,comm -r 2>/dev/null | sed -n 2p)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$ts" "$l1" "$l5" "$l15" "${rd:-0}" "$(echo "$top" | awk '{print $2}' | xargs basename 2>/dev/null)" "$(echo "$top" | awk '{print $1}')" >> "$OUT"
  sleep 300
done
echo "load-watch: batch pid $BATCH_PID exited $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$OUT"
