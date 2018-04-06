#!/usr/bin/env bash
# Author: Jeremy Lynch - jlynch@getwellnetwork.com
# Contributor: Add your name here if you work on this
# This will test if checkconfig comes back clean and if it does it will restart
# Nagios service
check=$(nagios --verify-config /etc/nagios/nagios.cfg)
error_total=$(echo "${check}"| grep "Total Warnings"|awk '{print $3}')
warn_total=$(echo "${check}" | grep "Total Errors"|awk '{print $3}')
last_commit=$(git log -1 --format="%H")
get_email=$(git log -1 --format='%ae' ${last_commit})
derper="${get_email%@*}"

# If there are any errors bail
if [[ "${error_total}" == 0 && "${warn_total}" == 0 ]]; then
  service nagios restart
  service nginx restart
  exit 0
else
  echo "ERRORS AND OR WARNINGS INVESTIGATE BAILING" >&2
  nagios --verify-config /etc/nagios/nagios.cfg > /tmp/checkconfigOutput.txt
  git show >> /tmp/checkconfigOutput.txt
  mail -s "[Nagios-Admin] D'oh ${derper} made Nagios Barf!!" "${derper}"@getwellnetwork.com  < /tmp/checkconfigOutput.txt
  rm -f /tmp/checkconfigOutput.txt
  exit 1
fi
