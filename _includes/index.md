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
