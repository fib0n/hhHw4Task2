#!/bin/bash

rm -f tmppipe
mkfifo tmppipe
trap "rm -f tmppipe" EXIT
while true
do
  cat tmppipe | nc -l 8081 2>>error.log |(
        x=0;
        while read lines[$x] && [ ${#lines[$x]} -gt 1 ];
        do
            if [ $x -eq  0 ]; then
                url=$(echo ${lines[0]} |cut -d" " -f2)
            fi
            
            if [[ "$url" == /hello ]]; then
                html=$(echo -en '<html><body><h1>hello world</h1></body></html>')
                echo -en "HTTP/1.1 200 OK\nContent-Type: text/html; charset=utf-8\nContent-Length: ${#html}\n\n$html" > tmppipe
                break
            elif [[ "$url" == /echo ]]; then
                x=$[$x +1]
            else
                text=$(echo 'Not Found')
                echo -en "HTTP/1.1 404 Not Found\nContent-Type: text/plain; charset=utf-8\nContent-Length: ${#text}\n\n$text" > tmppipe
                break
            fi
        done;
        
        if [ $x -gt  0 ]; then
            ( IFS=$'\n'; echo "${lines[*]}" > tmppipe );
        fi
  )
done
