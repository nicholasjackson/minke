# Minke

|     |     |
|-----|-----|
| Stories Ready: | [![Stories in Ready](https://badge.waffle.io/nicholasjackson/minke.png?label=ready&title=Ready)](https://waffle.io/nicholasjackson/minke) |
| Test Coverage: | [![Test Coverage](https://codeclimate.com/github/nicholasjackson/minke/badges/coverage.svg)](https://codeclimate.com/github/nicholasjackson/minke/coverage) |
| Build Status: | [![Build Status](https://travis-ci.org/nicholasjackson/minke.svg?branch=master)](https://travis-ci.org/nicholasjackson/minke) |
| Chat: | [![Join the chat at https://gitter.im/nicholasjackson/minke](https://badges.gitter.im/nicholasjackson/minke.svg)](https://gitter.im/nicholasjackson/minke?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |

# Documentation and Tutorial 
[https://minke.rocks/index.html](http://minke.rocks/index.html)

# Quick Start
Minke is an opinionated build system for μServices and Docker, it uses generator templates to create working source code, Dockerfiles, and anything else you may need to build and deploy a working microservice.

The intention is to produce a 0 dependency standardised build and test framework that works equally well on CI as it does on your local machine.

## Scaffold a new service
1. Create the folder where you would like the new service and change into that directory.  Whilst we are building a Go microservice in this example you do not need to create this folder in your GOPATH if you are only going to build with Minke as the generator uses the new vendoring capability introduced in Go 1.5.

```bash
$ mkdir ~/myservice
$ cd ~/myservice
```

2. Run the generator command in a docker container. (note the space before -g)

```bash
$ curl -L -s get.minke.rocks | bash -s ' -g minke-generator-go -o $(pwd) -n github.com/nicholasjackson -a myservice'
```

3. Build a Docker image

```bash
$ cd _build
$ ./minke.sh rake app:build_image
```

4. Execute the functional tests

```bash
$ ./minke.sh rake app:cucumber
```

You now have a working microservice ready to be pushed to a Docker registry and deployed to a server.  For more detailed information please see the [tutorial](tutorial.html).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/go_builder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
