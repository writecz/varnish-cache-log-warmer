# varnish-cache-log-warmer

This is a bash script that uses curl to warm up Varnish by targeting URLs from Varnish log.

This script is designed to keep Varnish cache always in best shape. This script traverse top hits in Varnish log, pausing during high system load and stopping at Varnish cache purge. It's recommended to be run as a cron job to keep one instance of the script always running.

## Requirements

- enable Varnish logging to files
- user running the script must have an access to Varnish logs
- set up a cron job for maximal operability.

## Executing the script
    $ chmod +x varnish-cache-warmer.sh
    
    # Enable varnish logs
    $ systemctl enable varnishncsa --now

    # Add a line to cron job
    $ crontab -e
    * * * * * ~/varnish-cache-warmer.sh

## Room for improvement

- script is trying to warm up all URLs in Varnish log - hits and passes.
- if you find anything that needs to be improved, let me know.

Originally used at [Motopneu a díly Brno](https://www.moto-kvalitne.cz)
