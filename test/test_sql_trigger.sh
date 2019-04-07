#!/bin/sh
result=$(curl -s -X POST -H "Content-Type: application/json" localhost:80/dejima/propagate -d '{"view":"public.dejima_bank", "insertions":[{"first_name":"John", "last_name":"Doe", "phone":null, "address":null}], "deletions":[]}')
if  [ "$result" = "true" ];  then
    echo "true"
else 
    echo $result
    exit 1
fi