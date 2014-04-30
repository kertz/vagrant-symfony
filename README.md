vagrant-symfony
===============

My base Symfony 2.4.x Vagrant setup with Ubuntu 14.04 LTS. Used Puppet for provisioning.

Uses Vagrant cloud to get the box `spantree/ubuntu-trusty-64` (https://vagrantcloud.com/spantree/ubuntu-trusty-64).

How to use?
===========

Close the repo into your Symfony2 project base folder.

Run `vagrant up`

That's it. Now you should be able to access the project with http://localhost:8080

```
Note: Use the `manifests/site.pp` to install more packages that you require.
```
