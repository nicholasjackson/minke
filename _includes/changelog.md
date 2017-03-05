# Version 1.14.2
Added capability to gain shell access into the build container.  

Example:  
```
./minke -v shell
```
This new feature allows you to start your compose stack including dependent services before starting a shell session into the build container with your source code.  Exceptionally useful for debugging a build or if you do not have the required dependencies to develop locally.

[![asciicast](https://asciinema.org/a/105822.png)](https://asciinema.org/a/105822)  

# Version 1.13.19
Ability to forward SSH keys to build container for docker-machine for Mac and linux, currently docker for mac does not support this feature.

Example:  
```
DOCKER_MACHINE=default ./minke -A -v build
```

# Version 1.13.9
* New bash script with cleaner parameters
* Updated logging for output
* Ability to use paths and git repos in your gemfiles

# Version 1.12.9
* Downgraded Docker version for CircleCI compatibility;
* Changed location of temporary docker-compose file to allow easier volume setting to relative path.

# Version 1.12.3
It is a bit of a beast of a release.

## Consul
This version removes the requirement for adding Consul to the services in your docker-compose files, If you specify a consul section inside of the config file then Minke will automatically start an instance of Consul and load the data in the consul_keys.yml.  

Any service which is listed in the docker-compose file will automatically have a link added to the consul service with the service name *consul*.

The benefit of this movement is one step towards a pluggable service discovery layer to support things like Etcd.

Config files which were written like the below...

```yaml
run:
  pre:
    consul_loader:
      config_file: './consul_keys.yml'
      url:
        address: consul
        port: 8500
        type: bridge
cucumber:
  pre:
    consul_loader:
      config_file: './consul_keys.yml'
      url:
        address: consul
        port: 8500
        type: bridge
    health_check:
      address: <%= application_name %>
      port: 8001
      path: /v1/health
      type: bridge
```

need to change removing the consul_loader and health_check sections from the pre section...

```yaml
run:
  consul_loader:
    config_file: './consul_keys.yml'
    url:
      address: consul
      port: 8500
      type: bridge
cucumber:
  consul_loader:
    config_file: './consul_keys.yml'
    url:
      address: consul
      port: 8500
      type: bridge
  health_check:
    address: <%= application_name %>
    port: 8001
    path: /v1/health
    type: bridge
```



## Networking
This version also introduces the use of separate Docker networks for running minke instances, that means that no longer are you going to get any nasty port clashes when running parallel jobs on CI.

When you run a task with Minke, Minke will create a randomly named Docker Bridge network and bind all containers to this network.  The added bonus is that you no longer need Ruby installed on your local computer all tasks can be run with the ./minke.sh script which starts a docker container with Ruby to run the tasks.  No more waiting for Nokogiri to install!!!
