# Introduction
Minke is an opinionated build system for μServices and Docker, it uses generator templates to create working source code, Dockerfiles, and anything else you may need to build and deploy a working microservice.

The intention is to produce a 0 dependency standardised build and test framework that works equally well on CI as it does on your local machine.

<asciinema-player src="/ascii/asciicast-105820.json" autoplay="1" preload="1" cols="120" rows="40"></asciinema-player>

You have two options keep reading and see just how quick you can build a microservice with Minke,  I promise it will be less than 5 minutes.  Or watch my talk from ContainerShed in 2016 where I demonstrate Minke live on stage, this talk also explains my ethos towards continuous delivery.

[https://skillsmatter.com/skillscasts/8097-0-to-microservice-in-5-minutes](https://skillsmatter.com/skillscasts/8097-0-to-microservice-in-5-minutes)

# Minke uses Docker
If you don't have it ...
Mac: [https://docs.docker.com/docker-for-mac/](https://docs.docker.com/docker-for-mac/)  
Linux: [https://docs.docker.com/engine/installation/linux/ubuntulinux/](https://docs.docker.com/engine/installation/linux/ubuntulinux/)  

If you are using Docker Toolbox for Mac you will need to set your DOCKER_HOST environment variable, this is quite simple just execute the below command.  The Linux install and Docker for Mac should not require this.

```bash
$ eval $(docker-machine env default)
```

# Like make on steroids
Minke is almost a 0 dependency setup for building your source code you will need three things.
1. A computer, Mac or Linux (Windows too if someone would like to write a .bat script).
2. Internet.
3. Docker.

Minke just deals with the other stuff; Minke and it's generators are built in Ruby however you do not need Ruby installed as the build scripts run in a Docker container.  The commands to build and test the application are built into the generator along with any application specific logic so the interface to the user is one of a few key simple commands.

```
fetch              # fetch dependent packages
test               # run unit tests
build              # build application
build_image        # build Docker image for application
build_and_run      # bonus points for guessing
run                # run application with Docker Compose
cucumber[feature]  # run end to end Cucumber tests USAGE: rake app:cucumber[@tag]
shell              # runs the application stack with docker compose and starts a shell session in the build container
```

It is completely extensible, for example you are building a Microservice and would like to automatically setup the database schema or load some initial data.  This can easily be achieved by writing your own Rake tasks.


# Isolated
The core concept of Minke is that it should be possible to run two Minke builds on the same machine with no port or container conflicts.  For this reason Minke automatically creates a Docker network and gives unique names to the containers to avoid conflict.  To avoid the need for exposing public ports for setup or functional testing Minke has service discovery built in you can simply use the discovery API to resolve any containers address.


# Secure
Minke can encrypt config variables with a private key so you don't have to expose your passwords to the whole internet.

# Generators
The table below shows the currently available generators, to create your own please follow the [creating generators guide](#).

| Language  |  Gem                                                                                      | Example      |
| --------- | ----------------------------------------------------------------------------------------- | ------------ |
| Go        | [Go μService Template](https://github.com/nicholasjackson/minke-generator-go)             |              |
| .NET Core | [.NET MVC](https://github.com/nicholasjackson/minke-generator-netmvc)                     |              |
| Java      | [Spring Boot](https://github.com/notonthehighstreet/minke-generator-spring)               |              |
| Swift 3.0 | [IBM Kitura](https://github.com/nicholasjackson/minke-generator-swift)                    |              |
| Node      | ExpressJS (Coming Soon)                                                                   |              |
| Ruby      | Rails (Coming Soon)                                                                       |              |

# Quick Start

## Scaffold a new service
1. Create the folder where you would like the new service and change into that directory.  Whilst we are building a Go microservice in this example you do not need to create this folder in your GOPATH if you are only going to build with Minke as the generator uses the new vendoring capability introduced in Go 1.5.

```bash
$ mkdir ~/myservice
$ cd ~/myservice
```

2. Run the generator command in a docker container. (note the space before -g)

```bash
$ curl -Ls https://get.minke.rocks | bash -s 'generate -g minke-generator-go -o $(pwd) -n github.com/nicholasjackson -a myservice'
```

3. Build a Docker image

```bash
$ cd _minke
$ ./minke -v build_image
```

The *-v* flag tells minke to output the verbose logs, if you omit this then you will see a much cleaner output.

4. Execute the functional tests

```bash
$ ./minke -v cucumber
```

You now have a working microservice ready to be pushed to a Docker registry and deployed to a server.  For more detailed information please see the [tutorial](tutorial.html).
