# Minke

## NOTE:
Version 0.13.0 of the gem introduces breaking changes to the configuration files in order to support multiple language builds for swift and go.  Please use version 0.12.0 or upgrade your config to the new specification shown below.  

**Version 0.13.0**  
[![Build Status](https://travis-ci.org/nicholasjackson/minke.svg?branch=master)](https://travis-ci.org/nicholasjackson/minke)

Minke is an opinionated build system for Microservices and Docker, like a little envelope of quality it scaffolds the build, run and test (unit test and functional tests) phases of your microservice project allowing you to simply run and test your images using Docker Compose.  Currently supporting Google's Go, and experimental support for Swift, extensions are planned for Node.js or HTML / Javascript sites with Grunt or Gulp based builds.

## Supported languages
- Go
- Swift

## Languages coming soon
- Node
- Java

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minke'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minke

## Dependencies

### Docker
You need to have docker, docker-machine, and docker-compose installed on your build machine and the docker environment variables must be set.  If using the docker-toolkit on a mac you can set these by running...
```bash
eval "$(docker-machine env default)"
```

## Not for Docker for Mac Beta users
If you use docker for mac please set the environment variable, this will auto resolve once Docker for mac exits beta.
```
DOCKER_IP=[your docker vm ip]
```

## Usage
Include the rake tasks in your Rakefile
```ruby
require 'minke'

spec = Gem::Specification.find_by_name 'minke'
Rake.add_rakelib "#{spec.gem_dir}/lib/minke/rake"
```

By default Go builder looks for a config file (config.yml) in the same folder as your Rakefile

Go builder provides the following tasks...

### rake app:test
Gets your packages dependencies then executes go test against the package.

### rake app:build
Creates a linux binary for your application, runs app:test before execution.

### rake app:build_server
Creates a docker image for your application, runs app:build before execution.

### rake app:build_and_run
Creates a docker image for your application then starts the application using docker-compose, runs app:build_server before execution.

### rake app:cucumber[optional feature tag]
Starts the application and then runs cucumber to execute your features, you can optionally pass a feature tag to this command to configure which part of your test suite you would like to run.  Does not build the server before running, this needs to be done when you change your source code with app:build_server.

### rake app:push
Pushes the built image to the configured registry, does not build the image before execution, this can be done manually with app:build_server.

## Config File
The config file config.yml is where you set the various configuration for the build process.

### Example Config File
```yaml
namespace: 'github.com/nicholasjackson'
application_name: 'event-sauce'
language: go
docker_registry:
  url: <%= ENV['DOCKER_REGISTRY_URL'] %>
  user: <%= ENV['DOCKER_REGISTRY_USER'] %>
  password: <%= ENV['DOCKER_REGISTRY_PASS'] %>
  email: <%= ENV['DOCKER_REGISTRY_EMAIL'] %>
  namespace: <%= ENV['DOCKER_NAMESPACE'] %>
docker:
  docker_file: './dockerfiles/event-sauce/Dockerfile'
  compose_file: './dockercompose/event-sauce/docker-compose.yml'
  build:
    image: [optional]
    docker_file: [optional]
after_build:
  copy_assets:
    -
      from: <%= "#{ENV['GOPATH']}/src/github.com/nicholasjackson/event-sauce/event-sauce" %>
      to: './docker/event-sauce'
    -
      from: './swagger_spec/swagger.yml'
      to: './dockerfile/event-sauce/swagger_spec/swagger.yml'
run:
  consul_loader:
    enabled: true
    config_file: './config.yml'
    url: <%= "http://#{ENV['DOCKER_IP']}:9500" %>
  docker:
    compose_file: './dockercompose/event-sauce/docker-compose-alternate.yml'
cucumber:
  consul_loader:
    enabled: true
    config_file: './config.yml'
    url: <%= "http://#{ENV['DOCKER_IP']}:9500" %>
  health_check:
    enabled: true
    url: <%= "http://#{ENV['DOCKER_IP']}:8001/v1/health" %>
  after_start:
    - 'wait_for_elastic_search'
```

#### head:
This section contains the configuration for the build process.  
**namespace:** namespace for your application code within your GOPATH, this is generally the same as your repository.  
**application_name:** name of the built binary.  
**language** (go|swift) language type of the build swift is currently experimental and uses the v3 dev branch which is compatible with Kitura

#### docker_registry:
This section contains the configuration for the docker registry to push the image to.  Images are pushed to the registry prefixed with the namespace and application_name, e.g. nicholasjackson/event-sauce:latest.   
**url:** url for the docker registry.  
**user:** username to use when logging into the registry.  
**password:** password to use when logging into the registry.  
**email:** email address to use when logging into the registry.  
**namespace:** namespace of your image to use when pushing the image to the registry.  

#### after_build:
This section allows you to copy assets such as binaries or files which you would like to include into your Docker image.
##### copy_assets:  
An array of elements with the following parameters:  
**from:** the source file or directory  
**to:** the destination file or directory

#### docker:
This section contains configuration for the Docker build and run process.  
**docker_file:** path to the folder containing your Dockerfile used by the build_server task.  
**compose_file:** path to your docker-compose file for run and cucumber tasks.
**build:** This section allows you to override the language default used for building your application code.
- **image [optional]:** specify a different image from your registry or local machine to use for building the application.
- **docker_file [optional]:** specify a dockerfile which will be built into an image and then used for building the application.

#### run:
The run section defines config for running your microservice with Docker Compose.
##### consul_loader:
When the application is run using docker-compose you can load some default config into your consul server.  Told you this was opinionated, if you are building microservices you are using consul right?  
**enabled:** boolean determining if this feature is enabled.  
**config_file:** path to a yaml file containing the key values you would like to load into consul. consul_loader flattens the structure of your yaml file and converts this into key values. For more information please see []()
##### docker:
This section allows you to override the docker compose file specified in the main section incase you would like a different config for testing.  
**compose_file:** path to your docker-compose file for run and cucumber tasks.
##### after_start:
This section is an array of rake tasks which will be run after docker compose has started, you can define these rake tasks in your main Rakefile.  e.g.  
  - 'wait_for_elastic_search'
  - 'es:create_indexes'

#### cucumber:
The cucumber section defines config for running and testing your microservice with Docker Compose and cucumber, the config options are the same as in **run:** with the addition of health_check.
##### health_check:
After the Docker Compose startup the application can wait until the main application has started before running the cucumber tests, to enable this specify true for the enabled: section then specify your health check url.  
**enabled** (true|false) enable or disable the health check.  
**url** url to use for health checks.  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/go_builder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
