module Minke
  module Generators
    SCRIPT = <<-EOF
    #!/bin/bash
    DOCKER_SOCK="/var/run/docker.sock:/var/run/docker.sock"
    RVM_COMMAND="source /usr/local/rvm/scripts/rvm"
    ERROR="Please specify a command e.g. ./minke.sh rake app:test"
    COMMAND=""
    NEW_UUID=$(base64 /dev/urandom | tr -d '/+' | head -c 32 | tr '[:upper:]' '[:lower:]')
    GEMSET=$(<.ruby-gemset)
    GEMSETFOLDER="/usr/local/rvm/gems/ruby-2.3.1@${GEMSET}"

    if [ "$1" == '' ]; then
      echo $ERROR;
      exit 1;
    fi

    COMMAND=$*
    DIR=$(dirname `pwd`)

    echo "Running command: ${COMMAND}"

    eval "docker network create minke_${NEW_UUID}"
    eval "docker run --rm -it --net=minke_${NEW_UUID} -v ${DOCKER_SOCK} -v ${DIR}:${DIR} -v ${DIR}/_build/vendor/gems:${GEMSETFOLDER} -e DOCKER_NETWORK=minke_${NEW_UUID} -w ${DIR}/_build nicholasjackson/minke /bin/bash -c '${RVM_COMMAND} && ${COMMAND}'"
    eval "docker network rm minke_${NEW_UUID}"
    EOF

    def write_bash_script path
      File.write(path, SCRIPT)
      File.chmod(0755, path)
    end

    def create_rvm_files folder, application_name
      File.write("#{folder}.ruby-gemset", application_name)
      File.write("#{folder}.ruby-version", '2')
    end

    module_function :write_bash_script
    module_function :create_rvm_files
  end
end
