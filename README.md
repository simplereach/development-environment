# Running the events writer for development and testing.
# Prerequisites
Vagrant
Ruby
VirtualBox

# Use
```bash
git clone https://github.com/simplereach/vagrant
```

```bash
cd vagrant
```

- print some instructions on environment variables you need to set
```bash
vagrant
```

- if you haven't provisioned previously the provision flag is optional
```bash
vagrant up --provision && vagrant ssh
```
This will output a lot of information as it retrieves files, installs dependencies
etc.


