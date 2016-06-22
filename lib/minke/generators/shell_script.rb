module Minke
  module Generators
    SCRIPT = <<-EOF
    #!/bin/bash

    DOCKER_SOCK="/var/run/docker.sock:/var/run/docker.sock"
    BUNDLE_COMMAND="set :bundle_flags, \"--path \#{shared_path}/bundles --quiet\" && bundle install -j3 && bundle update"
    ERROR="Please specify a command e.g. ./minke.sh rake app:test"
    COMMAND=""
    NEW_UUID=$(base64 /dev/urandom | tr -d '/+' | head -c 32 | tr '[:upper:]' '[:lower:]')

    if [ "$1" == '' ]; then
      echo $ERROR;
      exit 1;
    fi

    COMMAND=$*
    DIR=$(dirname `pwd`)

    echo "Running command: ${COMMAND}"

    eval "docker network create minke_${NEW_UUID}"
    eval "docker run --rm -it --net=minke_${NEW_UUID} -v ${DOCKER_SOCK} -v ${DIR}:${DIR} -e DOCKER_NETWORK=minke_${NEW_UUID} -w ${DIR}/_build nicholasjackson/minke /bin/bash -c '${BUNDLE_COMMAND} && ${COMMAND}'"
    eval "docker network rm minke_${NEW_UUID}"
    EOF

    def write_bash_script path
      File.write(path, SCRIPT)
      File.chmod(0755, path)
    end

    module_function :write_bash_script
  end
end
