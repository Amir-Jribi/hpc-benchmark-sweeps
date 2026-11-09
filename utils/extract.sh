#!/usr/bin/env bash

# This script is to know all the dependencies of a software (diret dep and indirect ones)
# <name-of-the-script> <module name>
# use case example : ./ex.sh HDF5/1.12.2-iimpi-2022a
# module file of the module name should be not hidden in order to work but we can add this case also
if [ $# -ne 1 ]; then
  echo "Usage: $0 <ModuleName>"
  echo "Example: $0 Ruby/3.0.1-GCCcore-11.2.0"
  exit 1
fi

MODULE="$1"
MODULEDIR="/srv/software/easybuild/modules/all"
LUA_FILE="$MODULEDIR/$MODULE.lua"
MODULEDIR1="/srv/software/easybuild/modules/all"
LUA_FILE1="$MODULEDIR1/$MODULE.lua"

MODULEDIR2="/srv/software/modulefiles/cpu_cclake"
LUA_FILE2="$MODULEDIR2/$MODULE.lua"
if [ -f "$LUA_FILE1" ]; then
  LUA_FILE="$LUA_FILE1"
  #this has been rem
  #echo "modulefile found: $LUA_FILE"
elif [ -f "$LUA_FILE2" ]; then
  LUA_FILE="$LUA_FILE2"
  echo "modulefile found: $LUA_FILE"
else
  echo "Error: modulefile not found: $LUA_FILE1"
  echo "Error: modulefile not found: $LUA_FILE2"
  exit 2
fi
# MODULEDIR="/srv/software/modulefiles/cpu_cclake"
# LUA_FILE="$MODULEDIR/$MODULE.lua"

mapfile -t deps < <(
  grep -oP '(load|depends_on)\("\K[^"]+' "$LUA_FILE" | sort -u
)

declare -A visited          # visited[module]=1
declare -a queue            # BFS queue

#echo "Dependencies for $MODULE:"
for dep in "${deps[@]}"; do
    #echo "  - $dep"
  queue+=("$dep")
done




# ---- helper: extract deps from lua file ----
extract_deps() {
  local lua_file="$1"
  grep -oP '(load|depends_on)\("\K[^"]+' "$lua_file" 2>/dev/null || true
}

# ---- BFS loop ----
while ((${#queue[@]} > 0)); do
  module="${queue[0]}"
  queue=("${queue[@]:1}")

  # already processed
  [[ -n "${visited[$module]}" ]] && continue

  # this has been added from last work
  echo "$module"
  visited["$module"]=1

  lua_file="$MODULEDIR/$module.lua"
  hidden_lua_file="$MODULEDIR/${module%/*}/.${module##*/}.lua"
  status="MISSING"
  backed=0
  if [[ -f "$lua_file" ]]; then
    software="${module%/*}" #remove anything starting from the last /
    #echo $software
    dest_dir="$HOME/othmane-proposal/modulefiles/current/cpu_cclake/$software"

    mkdir -p "$dest_dir"

    # Copy modulefile
    dest="$dest_dir/${module##*/}.lua"
    cp "$lua_file" "$dest"
    sed -i -E '
        /^[[:space:]]*(load|depends_on)\(/ {
        /"cpu_cclake\//! s/"([^"]+)"/"cpu_cclake\/\1"/g
        }' "$dest"

    status="OK"
  elif [[ -f "$hidden_lua_file" ]]; then
    # disable the comment below if you want to revert this hidden file !
    #cp "$hidden_lua_file" "$lua_file"
    #lua_file="$hidden_lua_file"
    backed=1
    status="HIDDEN"
  else
    echo "[$status] $module"
    continue
  fi

  #echo "[$status] $module"
  if (( backed )) && [[ -f "$lua_file" ]]; then
    echo "$module" >> hidden.log
    #echo "this $module is backed again!"
  fi


  # read dependencies into array
  mapfile -t deps < <(extract_deps "$lua_file" | sort -u)

  for dep in "${deps[@]}"; do
    if [[ -z "${visited[$dep]}" ]]; then
      queue+=("$dep")
    fi
  done
done
