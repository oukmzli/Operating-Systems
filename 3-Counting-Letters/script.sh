# Denys Kyrychenko - grupa 2
#!/bin/bash

read -r line
letter="${line:0:1}"
case_sensitive=true

if [[ "${line:1:1}" == "+" ]]; then
  case_sensitive=false
  line="$letter"
fi

if [ "$case_sensitive" = false ]; then
  letter=$(echo "$letter" | tr '[:upper:]' '[:lower:]')
fi

while read -r line; do
  if [ "$case_sensitive" = true ]; then
    count=0
    for (( i=0; i<${#line}; i++ )); do
      if [[ "${line:$i:1}" == "$letter" ]]; then
        ((count++))
      fi
    done
  else
    count=0
    line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    for (( i=0; i<${#line}; i++ )); do
      if [[ "${line:$i:1}" == "$letter" ]]; then
        ((count++))
      fi
    done
  fi
  echo $count
done
