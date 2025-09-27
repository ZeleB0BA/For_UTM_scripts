#!/bin/bash

cur_date=`date +%d.%m.%Y`
cur_day=`date +%d`
cur_month=`date +%m`
cur_year=`date +%Y`

save_dir=/var/www/html/links/data/pages/utm
report_name=utm_versions.txt
out_file=$save_dir/$report_name
utm_site=https://egais-help.ru/download/utm
utm_from_site=`lynx -dump $utm_site | grep "УТМ 4." |head -1 | awk '{print $2$3}'`
heading='Информация по УТМ в магазинах'
Domain=tdsterh.local

#Color definition
color_0="<color /red>"
color_1="<color /magenta>"
color_2="<color /orange>"
color_3="<color /yellow>"
color_4="<color /green>"
color_w="<color /white>"

r_color_end="</color>"
g_color_end="</color>"

get_temp1=./temp_json_r.txt
get_temp2=./temp_json_g.txt


if [ -f $out_file ] 
then 
    rm $out_file 
fi
touch $out_file
    echo "===="$heading "на "$cur_date "====" >$out_file
    echo "Версия УТМ на сайте: [[$utm_site | $utm_from_site]]" >>$out_file
    echo "^  № маг  ^  версия УТМ  ^  ФСРАР ID  ^  RSA ключ  ^^  КПП  ^  ГОСТ ключ  ^^   Владелец  ^ " >>$out_file
    echo "^         ^              ^            ^  действует с:  ^  действует по:  ^^  действует с:  ^  действует по:   ^ ^" >>$out_file

# Full UTM list
for i in 01 02 03 04 05 07 08 09 10 11 12 13 14 15
 do 
    bold_font=" FIXME "
    Host=utm
    Num=$i
    echo "--- $Num ------------------------------------------------------------------------"
    echo -n "^  [[http://$Host$Num.$Domain:8080/|  $Num]]  |  " >>$out_file

# Get Version of UTM
    cur_version=`curl -X GET "http://$Host$Num.$Domain:8080/info/version" -H "accept: text/plain" | awk -F00 '{print $1$2}'`

# Compare with good version
    if [ "$cur_version" == "$utm_from_site" ]
    then 
      bold_font=""
    fi
    echo -n "$cur_version $bold_font  |  " >>$out_file

# Get RSA info
    touch $get_temp1
    curl -X GET "http://$Host$Num.$Domain:8080/api/rsa/orginfo" -H "accept: application/json" >"$get_temp1"
    echo -e "" >>"$get_temp1"

# split day,month,year of RSA "expires date"
    r_day_to=`jq -r .to $get_temp1 |awk -F. '{print $1}'`
    r_month_to=`jq -r .to $get_temp1 |awk -F. '{print $2}'`
    r_year_to=`jq -r .to $get_temp1 |awk -F. '{print $3}'|awk '{print $1}'`

# check how many month is left to change RSA EGAIS Key
r_month_left=`echo "($(date -d "$r_year_to$r_month_to$r_day_to" +%s) - $(date +%s)) / (2592000)" |bc`
    case $r_month_left in
	0)
	    r_color_beg=$color_0
	;;
	1)
	    r_color_beg=$color_1
	;;
	2)
	    r_color_beg=$color_2
	;;
	3)
	    r_color_beg=$color_3
	;;
	4)
	    r_color_beg=$color_4
	;;
	*)
	    r_color_beg=$color_w
	;;
    esac

# fill table
    echo -n `jq -r .cn $get_temp1` "  |  "`jq -r .from $get_temp1`"  |  "$r_color_beg `jq -r .to $get_temp1` $r_color_end"  |  " `jq -r .c $get_temp1` "  |  " >>$out_file

# Get GOST info
    touch $get_temp2
    curl -X GET "http://$Host$Num.$Domain:8080/api/gost/orginfo" -H "accept: application/json" >"$get_temp2"
    echo -e "" >>"$get_temp2"

# split day,month,year of GOST "expires date"
    g_day_to=`jq -r .to $get_temp2 |awk -F. '{print $1}'`
    g_month_to=`jq -r .to $get_temp2 |awk -F. '{print $2}'`
    g_year_to=`jq -r .to $get_temp2 |awk -F. '{print $3}'|awk '{print $1}'`

# check how many month is left to change GOST EGAIS Key
g_month_left=`echo "($(date -d "$r_year_to$r_month_to$r_day_to" +%s) - $(date +%s)) / (2592000)" |bc`
    case $g_month_left in
	0)
	    g_color_beg=$color_0
	;;
	1)
	    g_color_beg=$color_1
	;;
	2)
	    g_color_beg=$color_2
	;;
	3)
	    g_color_beg=$color_3
	;;
	4)
	    g_color_beg=$color_4
	;;
	*)
	    g_color_beg=$color_w
	;;
    esac

# fill table
    echo `jq -r .from $get_temp2`"  |  "$g_color_beg `jq -r .to $get_temp2` $g_color_end"  |"`jq -r .cn $get_temp2` "  |  " >>$out_file
 done
    echo "Осталось: $color_0 меньше месяца$g_color_end, $color_1 1 месяц$g_color_end, $color_2 2 месяца $g_color_end, $color_3 3 месяца$g_color_end, $color_4 4 месяца $g_color_end" >>$out_file
