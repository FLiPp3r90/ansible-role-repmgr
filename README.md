ansible-role-repmgr
======

This role installs and configures repmgr for Postgresql replication

Requirements
------------

Assumes PostgreSQL is already installed and running.
But before you can deploy the whole role, you need to install repmgr first because you need the repmgr binaries when before starting the Postgresql database with repmgr shared preload libraries.

Role Variables
--------------

See defaults/main.yml

Dependencies
------------
* PostgreSQL installation

Usage
-----

In the playbook for the master:

```yaml
- hosts: db
  roles:
    - FLiPp3r90/repmgr
  vars:
    repmgr_install_only: True

- hosts: db
  roles:
     - role: anxs/postgresql
     - role: FLiPp3r90/repmgr
  vars:
    repmgr_is_master: True
    repmgr_node_id: 1
```

In the playbook for the slave:

```yaml
- hosts: db
  roles:
    - FLiPp3r90/repmgr
  vars:
    repmgr_install_only: True

- hosts: db
  roles:
     - role: anxs/postgresql
     - role: FLiPp3r90/repmgr
  vars:
    repmgr_node_id: 2
    repmgr_clone_standby: True
    repmgr_register_standby: True
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

If you use Firewalld on your database hosts you have to ensure that the Postgresql port is open.

If you have stricted sshd access configured on your database hosts you have to ensure that the postgres os user is able to connect via ssh key to all cluster member.

You have to set sudo rules that grants postgresql user to start/stop/restart postgresql database. 


License
-------

MIT

Author Information
------------------

[FLiPp3r90](https://github.com/FLiPp3r90)
