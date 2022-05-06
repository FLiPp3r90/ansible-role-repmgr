#!/bin/bash
# {{ ansible_managed }}

repmgr node check
if [ $? -ne 0 ]
then
    sudo {{ repmgr_service_stop_command }}
    repmgr standby clone -h {{ repmgr_cluster_scripts_replication_source }} -U {{ repmgr_user }} -d {{ repmgr_dbname }} -F
    sudo {{ repmgr_service_start_command }}
    repmgr standby register --force
fi

repmgr daemon start
repmgr service unpause
exit 0
