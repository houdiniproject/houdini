# Ansible Playbooks

Ansible® is an open source IT automation tool that automates provisioning, configuration management, application deployment, orchestration and many other manual IT processes. Compared to simpler management tools, Ansible users (system administrators, developers, and architects) can use Ansible automation rules to install software, automate routine tasks, provision infrastructure, improve security, compliance, and patch systems.

### Ansible Playbooks


#### install


### Running the playbooks

These first steps make sure the controller can talk to the target and execute commands.

#### First run

1.  Use the `hosts` file to configure the automation target 
2.  Copy your SSH public key to the target:  
    `ssh-copy-id admin@target-server.local`
3.  execute:  
    `ansible-playbook --extra-vars "target=imac-2.local" user.yml`


```
$ ssh-copy-id admin@target-server.local
```

#### run example

  execute:  
    `ansible-playbook --extra-vars "target=imac-2.local" user.yml`

```
$ ansible-playbook --extra-vars -i hosts "target=imac-2.local" user.yml`
```

### The hosts file

Hosts is simply an INI file listing known computers. It should look something like this:

    # file: hosts
    [imacs:vars]
    admin_user=macadmin

    [imacs]
    imac-1.local
    imac-2.local

Ansible won't run on computers which don't appear in hosts.

