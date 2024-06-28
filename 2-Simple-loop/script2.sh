# Denys Kyrychenko - grupa 2
#!/bin/bash

read n
for ((i=1; i<=$n; i++));
do
	if ((i == $n))
	then
		echo -n "$i"
	else
		 echo -n "$i "
	fi
done
echo
