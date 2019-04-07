#!/bin/sh
result=$(curl -X POST -H "Content-Type: application/json" localhost:80/dejima/propagate -d '{"view":"public.dejima_bank", "insertions":[{"first_name":"John", "last_name":"Doe", "phone":null, "address":null}], "deletions":[]}')
echo $result
if  [ "$result" = "true" ];  then
    echo "true"
else exit 1
fi