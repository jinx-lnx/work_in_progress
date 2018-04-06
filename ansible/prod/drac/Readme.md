Ansible Playbooks for DRACs
======
This collection of playbooks automates common DRAC tasks.  It has been tested on DRAC v5 and some newer versions.

You'll need to have [ansible installed](http://docs.ansible.com/intro_installation.html) to use these playbooks.

See below for setup, a description of each, and how to run them.


## Playbooks
In general you can run `ansible-playbook` with the name of the playbook YAML file.

All commands have these common arguments (see `ansible-playbook -h` for more info):

`-f #` - run # threads at once (ansible default is currently 5)  
`-i <inventory file>` - path to ini-style inventory file (see example-hosts)  
`-l <group>` - group or host in inventory file to limit operations to  

Example:

`ansible-playbook -f 15 -i example-hosts -l google ping.yml`

### auto-attach-enable
Enables virtual media auto-attaching (required for remote files to work).

### debug
Connects and runs a "noop" command, printing full response from the remote.

The debug playbook is useful as a quick "status" check.  The tasks will almost always succeed but the output will tell you if the DRAC is responding, etc.

### only-allow-ssh
Limit DRAC services to ssh.

**NOTE:** This playbook will execute `racadm racreset` at the end of a successful run.  You may want to test this on a single DRAC first. :)

### os-install
Mount a remote install ISO and boot from it.  This example demonstrates using a remote (nearby) NFS server to mount the install image from.  SMB/CIFS is also [purported to work](http://www.dell.com/support/article/ed/en/msbsdt1/SLN266099/en).
```bash
ansible-playbook -e "remote_image=10.0.0.10:/media/iso/ubuntu-14.04.2-server-amd64.iso" -i example-hosts os-install.yml
```

### ping
Tests basic pingability of the DRAC from the local system.  Running the above example should result in some successful and some failed pings.

### ping_ssh
Tests ssh connectivity of the DRAC from the local system. Especially usefull when ping (ICMP) is not allowed.

### racadm
Checks to see if racadm is runnable.

### racreset
Runs a racreset on each DRAC.

### set-root-password
Sets the root password to the provided value.  Run it with an additional argument like this (replace _newpassword_ with your desired password):
```bash
ansible-playbook -e "root_password=newpassword" -i example-hosts set-root-password.yml
```

**NOTE:** Use a 20 character or less password for maximum compatibility.

### web-ui-enable/disable
Enables or disables the web UI.

## Bastions
If you proxy through a "bastion" (shell, jumpbox, etc.) system to access the DRACs then do the following:

1. `cp ssh_config.example ssh_config`
2. change `username` to your username (or remove those lines if they match your login user)
3. change `bastion.*.com` and `bastion.zero.com` to the actual host/wildcard that matches your configuration
4. uncomment the the denoted lines in `ansible.cfg`
5. you may need to install [sshpass](http://sourceforge.net/projects/sshpass/) if directed by ansible

At this point ansible runs should use the alternate ssh_config that tunnels connections through your bastion/jumpbox.


## Debugging
To add debug output to any task add the following:
```yaml
  register: result
- debug: var=result
```

See the `debug.yml` playbook for a complete example.

You can also use `-vvv` with the ansible-playbook command for additional debug output.

## Notes / Caveats
- running `exit` as a command confuses ansible-playbook when using a bastion/ssh_proxy setup (ansible ad-hoc will run it just fine though)
- if you setup an ssh proxy config in a separate file (e.g. not your ~/.ssh/config) remember to also refer to that same config file via `-F <ssh_config>` when specifying the ProxyCommand (or the subsequent ssh will use your default config instead)

## TODO
- add tests (need a remote drac simulator!)
- handle more failure cases
- add cipher0 check/fix
- conditionally update settings (check first, apply only if needed..maybe we can add custom drac facts?)
- find cases where we show success but actually failed still :(
