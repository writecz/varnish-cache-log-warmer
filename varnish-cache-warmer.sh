#!/bin/bash
#
# Originally written by AC - 2015 <contact@chemaly.com> - sys0dm1n.com
# process run check, load detection and varnishncsa as data source by Write.cz - 2021 (dev@write.cz)
#

# check if script is already running
getscript() {
  pgrep -lf "varnish-cache-warmer" | wc -l
}

RUNNING=`getscript`

VERSION='1.0.1'

echo $RUNNING

# Allow only one instance running

if (($RUNNING > 2)); then
        getscript |  wc -l
        echo "Script already running"
        exit 0;
fi

NOTIFY="3"

TRUE="1"

warm_varnish() {
            # get unique URLS from varnisncsa logs and warm 'em up
            awk {'print $7'} /var/log/varnish/* | grep "\.html" | sort | uniq -c | sort -nr | awk {'print $2'} | while read newline; do
                time curl -sL $newline \
                  -H 'authority: luxusnioznameni.cz' \
                  -H 'accept-encoding: gzip, deflate, br' \
                  -H 'dnt: 1' \
                  -H 'upgrade-insecure-requests: 1' \
                  -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36 OPR/69.0.3686.49 VCW/1.0.1' \
                  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
                  -H 'sec-fetch-site: none' \
                  -H 'sec-fetch-mode: navigate' \
                  -H 'sec-fetch-user: ?1' \
                  -H 'sec-fetch-dest: document' \
                  -H 'accept-language: cs-CZ,cs;q=0.9' \
                  --compressed \
                  --cookie-jar /tmp/cookie.txt \
                  -o /dev/null 2>&1
                echo $newline
                
                # check 5 minute system load and pause script if load is high

                LOAD5MIN="$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d, -f2 | sed 's/ //g')"

                RESULT=$(echo "$LOAD5MIN > $NOTIFY" | bc)

                if [ "$RESULT" == "$TRUE" ]; then
                        sleep 5m;
                fi

                # stop the script when Varnish cache is purged

                PURGE=`tail -n 50 /var/log/varnish/varnishncsa.log | grep PURGE`
                if [ "$PURGE" ]; then
                        exit 0;
                fi
            done
}

warm_varnish
