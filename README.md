ansible-repmgr
======

This role installs and configures repmgr for Postgresql replication

Requirements
------------

Assumes PostgreSQL is already installed and running.

Role Variables
--------------

See defaults/main.yml

Dependencies
------------
* Repmgr 5.x
* Postgres >= 9.6
* Role ANXS/postgresql

Usage
-----

In the playbook for the master:

```yaml
- host: servers
  roles:
  - role: ansible-repmgr
    repmgr_is_master: yes
    repmgr_node_id: 1
```

In the playbook for the standby:

```yml
- hosts: servers
  roles:
  - role: ansible-repmgr
    repmgr_node_id: 2
```

### Tricks and Tips

You will need to create a `repmgr` user on your master database with
appropriate permissions.  This two things.

1. Create a database use `repmgr` with the permissions
   `SUPERUSER,REPLICATION,LOGIN`
2. Add an entry to the `pg_hba.conf` file giving explicit access to the
   replication database to both the `repmgr` and the `postgres` users

  ```bash
  # pg_hba.conf
  host  replication  repmgr    192.168.0.0/16  trust
  host  replication  repmgr    10.0.0.0/8      trust
  host  replication  postgres  192.168.0.0/16  trust
  host  replication  postgres  10.0.0.0/8      trust

  ```

License
-------

Apache-2.0

Author Information
------------------

Filip Krahl
