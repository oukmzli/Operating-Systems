# Denys Kyrychenko - grupa 2
#!/bin/bash

read n
a=0
b=1

i=0
while [ $i -lt $n ]; do
    echo "$a"
    (( fn = a + b ))
    a=$b
    b=$fn
    (( i = i + 1 ))
done