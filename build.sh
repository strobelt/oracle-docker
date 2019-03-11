#!/bin/bash
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# Define default arguments.
SCRIPT="build.cake"
CAKE_ARGUMENTS=()

# Parse arguments.
for i in "$@"; do
    case $1 in
        -s|--script) SCRIPT="$2"; shift ;;
        --) shift; CAKE_ARGUMENTS+=("$@"); break ;;
        *) CAKE_ARGUMENTS+=("$1") ;;
    esac
    shift
done

# Check .NET Core SDK version
vercomp () {
    if [[ $1 == $2 ]]
    then
        echo 0
        return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]; then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            echo 1
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            echo 2
            return
        fi
    done
    echo 0
}
if [ "$(vercomp $(dotnet --version) '2.1.300')" == "2" ]; then
  >&2 echo ".NET Core SDK version is bellow 2.1.300, cannot continue. Version is: $(dotnet --version)"
  exit 1
fi

# Install Cake.Tool if missing
if ! hash dotnet-cake 2>/dev/null; then
  rm -rf ~/.dotnet/tools/dotnet-cake &&
     dotnet tool install -g Cake.Tool
fi

# Load NVM if node is not available and NVM is available and not loaded
if ! hash node 2>/dev/null && [ -d $HOME/.nvm ]; then
  [ -z "${NVM_DIR}" ] && export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

dotnet cake $SCRIPT "${CAKE_ARGUMENTS[@]}"
