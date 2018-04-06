#!/usr/bin/env bash 
                                                                                           
date=$(date)
 
# What state is the service in?
case "${1}" in
OK)
        # The service just came back up, so don't do anything...
        ;;
WARNING)
        # We don't really care about warning states, since the service is probably still running...
        ;;
UNKNOWN)
        # We don't know what might be causing an unknown error, so don't do anything...
        ;;
CRITICAL)
        # Aha!  The service appears to have a problem - perhaps we should restart the server...
 
        # Is this a "soft" or a "hard" state?
        case "${2}" in
 
        # We're in a "soft" state, meaning that Nagios is in the middle of retrying the
        # check before it turns into a "hard" state and contacts get notified...
        SOFT)
                # What check attempt are we on?  We don't want to restart the web server on the first
                # check, because it may just be a fluke!
                case "${3}" in
 
                # Wait until the check has been tried 3 times before restarting the service.
                # If the check fails on the 4th time (after we restart the service), the state
                # type will turn to "hard" and contacts will be notified of the problem.
                # Hopefully this will restart the service successfully, so the 4th check will
                # result in a "soft" recovery.  If that happens no one gets notified because we
                # fixed the problem!
                3)
                        printf "%s" "Restarting service ${6} (3rd soft critical state)...\n"
                        # Call NRPE to restart the service on the remote machine
                        /usr/lib/nagios/plugins/check_nrpe -H "${4}" -c restart-service -a "${5}"
                        echo "${date} - ${7} - ${4} - restarting ${6} - SOFT"  >> /var/log/nagios/gwn-nagios-autorestart
                        ;;
                        esac
                ;;
 
        # The service somehow managed to turn into a hard error without getting fixed.
        # It should have been restarted by the code above, but for some reason it didn't.
        # Let's give it one last try, shall we?
        # Note: Contacts have already been notified of a problem with the service at this
        # point (unless you disabled notifications for this service)
        HARD)
                case "${3}" in
 
                4)
                        printf "%s" "Restarting ${6} service...\n"
                        # Call the init script to restart the service
                        echo "${date} - ${7} - ${4} - restarting ${6} - HARD"  >> /var/log/nagios/gwn-nagios-autorestart
                        /usr/lib/nagios/plugins/check_nrpe -H "${4}" -c restart-service -a "${5}"
                        ;;
                        esac
                ;;
        esac
        ;;
esac
exit 0
