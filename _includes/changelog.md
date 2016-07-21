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