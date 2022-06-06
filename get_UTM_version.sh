#!/bin/bash

# result will be here
out_file=utm_versions.txt
if [ -f $out_file ] 
then 
    rm $out_file 
fi
touch $out_file
# numbers for shopnames
for i in 01 02 03 04 05 07 08 09 10 
 do 
    ShopHost=magaz-
    ShopNum=$i

    echo "$ShopHost$ShopNum "
    echo -n "$ShopHost$ShopNum = " >>$out_file
curl -X GET http://$ShopHost$ShopNum:8080/info/version >>$out_file
    echo -e "\r" >>$out_file

done
