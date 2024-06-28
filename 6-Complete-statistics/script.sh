# Denys Kyrychenko - grupa 2
#!/bin/bash

i=50
count=0
sum=0

average=0
variance=0
numbers=()

while read n && [ $i -ge 0 ]; do
    (( i = i - 1 ))
    if [ -z "$n" ]; then 
        continue 
    fi

    (( count = count + 1 ))
    
    (( sum = sum + n))
    numbers+=($n)
done

((average = sum / count))

for n in "${numbers[@]}"; do
    (( temp = n - average ))
    (( variance += temp * temp ))
done

((variance = variance / count))

echo "$average"
echo "$variance"
