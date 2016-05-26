# Introduction

Minke is an opinionated build system for μServices and Docker, like a little envelope of quality it scaffolds the build, run and test (unit test and functional tests) phases of your μServices project allowing you to simply run and test your images using Docker Compose.

# Generators
Minke has the capability to scaffold a new service, to do this it uses generator plugins.  The table below shows the currently available generators, to create your own please follow the [creating generators guide](#).

| Language  |  Gem                                                                                      | Example      |
| --------- | ----------------------------------------------------------------------------------------- | ------------ |
| Go        | [Go μService Template](https://github.com/nicholasjackson/minke-generator-go)             |              |
| .NET Core | [.NET MVC μService Template](https://github.com/nicholasjackson/minke-generator-netmvc)   |              |
| Java      | [Spring Boot](https://github.com/notonthehighstreet/minke-generator-spring)               |              |
| Swift     | Kitura (Coming Soon)                                                                      |              |
| Node      | ExpressJS (Coming Soon)                                                                   |              |
| Ruby      | Rails (Coming Soon)                                                                       |              |

# Using Minke

## Create a Gemfile  

```ruby
source 'http://rubygems.org'

gem 'minke'
gem 'minke-generator-netmvc'
```  

## Install the gems
```bash
$ bundle install
```

## Run minke
```
$ minke
```

You should see the below output with the go generator successfully installed.

```

888b     d888 d8b          888
8888b   d8888 Y8P          888
88888b.d88888              888
888Y88888P888 888 88888b.  888  888  .d88b.
888 Y888P 888 888 888  88b 888 .88P d8P  Y8b
888  Y8P  888 888 888  888 888888K  88888888
888   "   888 888 888  888 888  88b Y8b.
888       888 888 888  888 888  888  "Y8888

Version: 1.2.0

# Loading installed generators:
  * minke-generator-netmvc

Please specify options use: minke --help for help on command line options
```

## Scaffold a project
We can now scaffold a new go μService using the following command:

```bash
$ minke -g minke-generator-netmvc -o ~/nicholasjackson/helloworld
  -a helloworld -n HelloWorld
```
 
If look at the output folder we will see something like the below folder structure, all our source code is in the root and there is a **_build** folder, this is where Minke stores things like the Docker and Docker Compose files and configuration.

```
total 12520
    0 drwxr-xr-x  17 nicj  NOTHS\Domain Users      578 23 May 15:09 .
    0 drwxr-xr-x  10 nicj  NOTHS\Domain Users      340 23 May 15:07 ..
    0 drwxr-xr-x   3 nicj  NOTHS\Domain Users      102 25 Apr 16:30 .bundle
    0 drwxr-xr-x  13 nicj  NOTHS\Domain Users      442 23 May 15:09 .git
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users      123 18 Apr 15:43 .gitignore
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users       11 18 Apr 15:43 .ruby-gemset
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users        6 18 Apr 15:43 .ruby-version
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users     1083 18 Apr 15:43 LICENSE
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users      258 18 Apr 15:43 Readme.md
    0 drwxr-xr-x  12 nicj  NOTHS\Domain Users      408 25 Apr 15:57 _build
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users      629 18 Apr 15:43 circle.yml
    0 drwxr-xr-x   3 nicj  NOTHS\Domain Users      102 18 Apr 15:43 global
    0 drwxr-xr-x  10 nicj  NOTHS\Domain Users      340 18 Apr 15:43 handlers
12464 -rwxr-xr-x   1 nicj  NOTHS\Domain Users  6379552 25 Apr 16:45 helloworld
    0 drwxr-xr-x   3 nicj  NOTHS\Domain Users      102 18 Apr 15:43 logging
    8 -rw-r--r--   1 nicj  NOTHS\Domain Users     1290 18 Apr 15:43 main.go
    0 drwxr-xr-x   3 nicj  NOTHS\Domain Users      102 18 Apr 15:43 mocks
```

## Building and testing your application
Change to the **_build** folder

```
$ cd _build
```
Since Minke is primarily uses Rake you can run `$ Rake -T` to see the various options available to you.

```
rake app:build              # build application
rake app:build_and_run      # build and run application with Docker Compose
rake app:build_image        # build Docker image for application
rake app:cucumber[feature]  # run end to end Cucumber tests USAGE: rake app:cucumber[@tag]
rake app:fetch              # fetch dependent packages
rake app:push               # push built image to Docker registry
rake app:run                # run application with Docker Compose
rake app:test               # run unit tests
rake docker:fetch_images    # pull images for golang from Docker registry if not already downloaded
rake docker:update_images   # updates build images for swagger and golang will overwrite existing images
```

### Building the application
To build the application simply execute:

```bash
$ rake app:build
```
This will download a docker image for the language (in this instance Go), and run the commands.  No build commands are executed directly on your machine which is great as you do not need to manage all the dependencies.  
The output will look something like below.

```bash
# Loading installed generators
registered minke-generator-netmvc
run fetch
## Update dependencies
/Users/nicj/Developer/transform/api-ipad:/apiipad
log  : Restoring packages for /apiipad/test/apiipad.Tests/project.json...
info :   GET https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnethostresolver/index.json
info :   OK https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnethostresolver/index.json 451ms
info :   GET https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnethost/index.json
info :   OK https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnethost/index.json 488ms

...

Project apiipad (.NETCoreApp,Version=v1.0) will be compiled because expected outputs are missing

Compiling
apiipad for .NETCoreApp,Version=v1.0

Compilation succeeded.
0 Warning(s)
0 Error(s)


Time elapsed 00:00:05.2253203
```

The build task has a dependency on the fetch task so before we try to build anything we will fetch the dependencies (in this instance from nuget) before executing the build.
All of the code is run inside the docker container however most generators will use the physical disk of the Docker server to cache the output.  This just speeds up the whole process and allows you to utilise any caching behaviour of your CI environment if needed.

### Running the unit tests
```bash
$ rake app:test
```
Running the unit tests is a similar process, before we run the tests we will build the application code and fetch any dependencies.  It all runs inside a container.

### Build yourself an image
So we are going to run the cucumber tests against a Docker container and ultimately you want to run this on your server anyway so lets build an image which can be launched.
```bash
$ rake app:build_image
```

Thats all you need this will build and test your application code then copy the assets into the right location to be packaged up into a Docker image, all of the steps is configurable checkout the section on Config for more information.

### Functional tests
Having unit tests for your code covers you a little however there is a real benefit to having a good behavioural test suite which may even test the integration of your application with other dependencies such as database servers.
Minke uses Cucumber and Docker to facilitate this, it spins up a stack using Docker Compose and executes the Cucumber tests against it.  
Running the functional tests is as easy as...

```bash
$ rake app:cucumber
```

This will start the stack with Docker Compose using a standard format compose file which can be found in the **_build** folder, it loads any config that we may require for the service into Consul and then waits for the service to start before executing the Cucumber tests.  
And you have to do nothing other than write the test and setup the config all logic for service discovery and waiting for the service to start is handled for you.
All being well you should see some output like the stuff listed below.

```bash
# Loading installed generators
registered minke-generator-netmvc
## Running cucumber with tags
Creating apiipad_statsd_1
Creating apiipad_consul_1
Creating apiipad_registrator_1
Creating apiipad_apiipad_1
Server: http://192.168.99.100:32886/v1/status/leader passed health check, 1 checks to go...
Server: http://192.168.99.100:32886/v1/status/leader healthy
./consul_keys.yml
Updating key: /apiipad/Credentials/mysql/username with value: root
Updating key: /apiipad/Credentials/mysql/password with value: my-secret-pw
Updating key: /apiipad/Settings/environment with value: dev
Updating key: /apiipad/Settings/mysql/db_name with value: apiipad
Updating key: /apiipad/Settings/statsd/host with value: statsd
Updating key: /apiipad/Settings/statsd/port with value: 8125
Waiting for server http://192.168.99.100:32888/v1/health to start
Server: http://192.168.99.100:32888/v1/health passed health check, 3 checks to go...

...

@healthcheck
Feature: Health check
	In order to ensure quality
	As a user
	I want to be able to test functionality of my API

  Scenario: Health check returns ok                            # features/health.feature:10
    Given I send and accept JSON                               # cucumber-api-0.3/lib/cucumber-api/steps.rb:11
    When I send a GET request to the api endpoint "/v1/health" # features/steps/http.rb:1
    Then the response status should be "200"                   # cucumber-api-0.3/lib/cucumber-api/steps.rb:107
    And the JSON response should have key "status"             # cucumber-api-0.3/lib/cucumber-api/steps.rb:132

1 scenario (1 passed)
4 steps (4 passed)
0m0.026s
Stopping apiipad_apiipad_1 ... done
Stopping apiipad_registrator_1 ... done
Stopping apiipad_consul_1 ... done
Stopping apiipad_statsd_1 ... done
```

It really is that easy now all you need to do is push the image to the server and open a beer.  If you have managed to get this far I recommend checking out the documentation on the configuration files to see how you can customise and extend your build.
