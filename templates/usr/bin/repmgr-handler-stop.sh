#!/bin/bash
# {{ ansible_managed }}

primary_host=$(repmgr cluster show --compact | grep primary | awk -F' \| ' '{print $2}'\;)
my_host=$(hostname)

if [ $primary_host = $my_host ]
then
    standby_host=$(repmgr cluster show --compact | grep standby | awk -F' \| ' '{print $2}'\;)
    standby_follow_primary=$(repmgr cluster show --compact | grep standby | awk -F' \| ' '{print $5}'\;)

    if [ $my_host = $standby_follow_primary ]
    then
        ssh $standby_host "repmgr standby switchover --always-promote"
    fi
fi

exit 0