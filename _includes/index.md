# Introduction

Minke is an opinionated build system for μServices and Docker, like a little envelope of quality it scaffolds the build, run and test (unit test and functional tests) phases of your μServices project allowing you to simply run and test your images using Docker Compose.

# Generators
Minke has the capability to scaffold a new service, to do this it uses generator plugins.  The table below shows the currently available generators, to create your own please follow the [creating generators guide](#).

| Language  |                                                                                           |
| --------- | ----------------------------------------------------------------------------------------- |
| Go        | [Go μService Template](https://github.com/nicholasjackson/minke-generator-go)             |
| .NET Core | [.NET MVC μService Template](https://github.com/nicholasjackson/minke-generator-netmvc)   |
| Java      | [Spring Boot](https://github.com/notonthehighstreet/minke-generator-spring)               |
| Swift     | Kitura (Coming Soon)                                                                      |
| Node      | ExpressJS (Coming Soon)                                                                   |
| Ruby      | Rails (Coming Soon)                                                                       |

# Using Minke

## Create a Gemfile  

```ruby
source 'http://rubygems.org'

gem 'minke'
gem 'minke-generator-go'
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
888 Y888P 888 888 888 "88b 888 .88P d8P  Y8b
888  Y8P  888 888 888  888 888888K  88888888
888   "   888 888 888  888 888 "88b Y8b.
888       888 888 888  888 888  888  "Y8888

Version: 1.2.0

# Loading installed generators:
  * minke-generator-go

Please specify options use: minke --help for help on command line options
```

## Scaffold a project
We can now scaffold a new go μService using the following command:
```bash
$ minke -g minke-generator-go -o $GOPATH/src/github.com/nicholasjackson/helloworld
  -a helloworld -n github.com/nicholasjackson
```
since this is a Go service it needs to be in your GOPATH and the namespace needs to be the same as your github or bitbucket url for the import statements.  
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
