---

title: "Domain Setup Script"
date: 2021-09-19
draft: false

---

A simple bash script to automate the setup of new domains to my CentOS 7 bare metal server.

The script should create the directory structure and set a skeleton site file system along with setting up the apache vhost, nginx server blocks, and named zone file and configurations. For now, it will not assume PHP or MySQL is being used, but that could be added in the future.
