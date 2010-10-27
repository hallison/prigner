#!/bin/bash
#$ <%=project.name%> v0.1.0
#$
#$ Usage:
#$   <%=project.name%> [options] [args]
#$
#$ Options:
#$   -h,--help      Show this message.
#$

function <%=project.name%> {
  local path="${BASH_SOURCE%/*}/"

  # This function show the message written in the header.
  function __help {
    local   origin="$(1<${0})"
    local comments="${origin}"

    comments="${comments#\#!*\#\$}"
    comments="${comments%\#\$*}"
    comments="${comments//\#\$ }"
    comments="${comments:1:${#comments}}"

    test "${comments//\$}" != "${origin}" && echo "${comments//\#\$}"
  }
  function _h { __help; return 0; }

  if [[ ${#} -eq 0 ]]; then
    __help
    exit 0
  elif [[ ${1} =~ -.|-- ]]; then
    source $path/<%=project.name%>rc

    local option=""

    [[ "${1}" =~ ^-.* ]] && option=${1//-/_}

    shift 1

    ${option} ${@}
  fi

}

<%=project.name%> ${@}
