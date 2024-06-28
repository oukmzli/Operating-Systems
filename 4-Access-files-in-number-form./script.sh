# Denys Kyrychenko - grupa 2
#!/bin/bash

while read -r line || [[ -n "$line" ]]; do
    permission=$(echo "$line" | awk '{print $1}')
    file_name=$(echo "$line" | awk '{print $9}')

    [[ $line == total* ]] && continue

    is_exec=${permission:3:1}
    is_dir=${permission:0:1}

    result=""
    for ((i=2; i<=${#permission}; i+=3)); do
        part=${permission:i-1:3} 
        num=0
        [[ ${part:0:1} == 'r' ]] && ((num+=4))
        [[ ${part:1:1} == 'w' ]] && ((num+=2))
        [[ ${part:2:1} == 'x' || ${part:2:1} == 's' ]] && ((num+=1))
        result+="$num"
    done
        
    if [[ $is_dir == "d" ]]; then 
        echo "$file_name/ $result"
    else
        if [[ $is_exec == "x" || $is_exec == "s" ]]; then
            echo "$file_name* $result"
        else
            echo "$file_name $result"
        fi
    fi
done

