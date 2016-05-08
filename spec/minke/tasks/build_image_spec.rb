require 'spec_helper'

describe Minke::Tasks::Build do
  let(:config) { double "config" }
  let(:docker_runner) { double "docker_runner" }
  let(:logger) { double "logger" }

  let(:task) do
    Minke::Tasks::Build.new config, docker_runner, logger
  end

  

end
