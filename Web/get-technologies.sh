#!/bin/bash

usage(){

	echo "Usage: $0 [-d DOMAIN]" >&2
	echo ' -d DOMAIN Specify your domain with address in format without protocol (e.g "chosen_domain.com")'
	echo ' -a ASN Number: Go to the site https://bgp.he.net/ and search for company that you are up to and enter their ASN number without "AS" prefix prefix [YOU NEED TO FIND THE VALID ASN NUMBER that has a IPv4 ranges connected to them!'
	echo ' Furthermore, please fill in the Acquisitions.txt file in order to scan Acquisitions too!'

		exit 1

}

#while getopts d: OPTION do
#	case $OPTION in
#		domain)
#		domain="$OPTARG"
#		;;
#		ASN)
#		ASN="$OPTARG"
#		;;
#		?)
#		usage
#		;;
#	esac
#done

while getopts d:a:u: OPTION; do
	case $OPTION in
		d)
		domain="$OPTARG"
		;;
		u)
		USER_EXEC="$OPTARG"
		;;
		?)
		usage
		;;
	esac
done


 if [ -z "${USER_EXEC}" ]; then
 	USER_EXEC=root
 fi

 if [ "$EUID" -ne 0 ]
   then echo "Please run as root"
   exit
 fi

 LAST_INIT_DATE=$(cat "$PWD"/"${domain}"/last-init-date.txt)
 while read -r domain; do

	 mkdir -p "${domain}"/"${LAST_INIT_DATE}"/"$domain"/tools-io
 	 dir=$PWD/${domain}/${LAST_INIT_DATE}/"$domain"
 	 bin=$dir/tools-io

	https_link=$(echo "${domain}" | httprobe | head -n 1)
	node "/home/${USER_EXEC}/tools/wappalyzer/src/drivers/npm/cli.js" "$https_link" -P | jq '.technologies[].name' | tee "$bin"/"${domain}"_technologies.txt
	
	whatwaf -u "${https_link}" -F -C -o "$bin"/"${domain}"_whatwaf.csv
	csv2md < "$bin"/"${domain}"_whatwaf.csv > "$bin"/"${domain}"_whatwaf.md
	rm "$bin"/"${domain}"_whatwaf.csv


done < "${PWD}"/"${domain}"/roots.txt
