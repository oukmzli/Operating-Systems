# Denys Kyrychenko - grupa 2
#!/bin/bash

ids=()
counts=()
min_count=999999

while read -r id; do
  if [[ -z "$id" ]]; then
    break
  fi
  
  found=false
  for i in "${!ids[@]}"; do
    if [[ "${ids[i]}" == "$id" ]]; then
      counts[i]=$((counts[i] + 1))
      found=true
      break
    fi
  done

  if ! $found; then
    ids+=("$id")
    counts+=(1)
  fi
done

for i in "${!ids[@]}"; do
  if [[ "${counts[i]}" -lt "$min_count" ]]; then
    min_count="${counts[i]}"
    rarest_id="${ids[i]}"
  fi
done

echo "$rarest_id $min_count"