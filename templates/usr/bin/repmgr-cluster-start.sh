#!/bin/bash
# {{ ansible_managed }}

function actions_vip_online {
    # Using online VIP as reference
    if echo $1 | grep -q {{ ansible_default_ipv4.address }}
    then
        echo "Node responding is this one, no action required."
    else
        echo "Node should be standy, start cloning"
        sudo {{ repmgr_service_stop_command }}
        repmgr standby clone -h {{ repmgr_cluster_scripts_replication_source }} -U {{ repmgr_user }} -d {{ repmgr_dbname }} -F
        sudo {{ repmgr_service_start_command }}
        repmgr standby register --force
    fi
}

function actions_vip_offline {
    echo "VIP is offline, trying to take the lead"
    server_role=$(repmgr node check |grep "Server role")
    if echo $server_role |grep -q standby
    then
        echo "Trying promote this node to primary"
        repmgr standby promote -F
    elif echo $server_role |grep -q primary
    then
        echo "Something went wrong, VIP offline but this node think it's primary."
    else
        echo "Something went wrong, this node has incoherent server role : $server_role"
    fi

}


timer_tick=0

# Test VIP availability

vip_return=$(psql -q "host={{ repmgr_cluster_scripts_replication_source }} port=5432 dbname={{ repmgr_dbname }} user={{ repmgr_user }} connect_timeout=2 sslmode=disable" -c 'select inet_server_addr();')
code_return=$?
until_switch=$code_return

# Wait & retry 5 times if the VIP is offline
until [ $until_switch -eq 0 ]
do
    echo "Waiting 30s the VIP to be online"
    sleep 30
    ((timer_tick++))
    vip_return=$(psql -q -c '\c "host={{ repmgr_cluster_scripts_replication_source }} port=5432 dbname={{ repmgr_dbname }} user={{ repmgr_user }} connect_timeout=2 sslmode=disable"' -c 'select inet_server_addr();')
    code_return=$?

    if [ $timer_tick -eq 5 ]
    then
        until_switch=0
    else
        until_switch=$code_return
    fi
done

if [ $code_return -eq 0 ]
then
    echo "VIP is online"
    actions_vip_online $vip_return
else
    echo "VIP is offline"
    actions_vip_offline
fi


repmgr daemon start
repmgr service unpause

exit 0
