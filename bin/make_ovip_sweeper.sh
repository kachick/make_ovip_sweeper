#!/bin/sh
# make_ovip_sweeper.sh
# Copyright (c) 2011-2012, Kenichi Kamiya

initialize_environment()
{
  set -u
  LANG=C; export LANG
}

error()
{
  echo "Error: $@"
  exit 1
}>&2

filter_ipv4addr()
{
  grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
}

filter_node_id()
{
  perl -nle 'if ( $_ =~ /^\s*(\d+)/ ){print $1;}'
}

filter_interface_id()
{
  perl -nle 'if ( $_ =~ /^\s*\d+\/(\d+)/ ){print $1;}'
}

filter_main_ipaddr()
{
  perl -nle 'if ( $_ =~ /^\s*\d+\s+IP\s+[\w\d]\S+\s+\S+\s+(\S+)/ ){print $1;}'
}

check_ipv4addr_pattern()
{
  [ $( echo "$1" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' | wc -l ) -eq 1 ]
}

check_ov_oid_pattern()
{
  [ $( echo "$1" | grep -E '^[1-9][0-9]*$' | wc -l ) -eq 1 ]
}

get_otd()
{
  local -r result=$( ovtopodump -rRISC "$1" 2>/dev/null | tail -n +2 )
  local -r error=$( ovtopodump -rRISC "$1" 2>&1 1>/dev/null )

  if ( echo "$error" | grep -q -F "ERROR: Could not find object $1" ); then
    return 1
  fi

  if ( echo "$result" | grep -q -E '^ *[0-9]+' ); then
    echo "$result"
  else
    error 'ovtopodump error'
  fi
}

get_interface_id()
{
  local -r otd="$1"
  local -r ipaddr="$2"
  local -r result=$( 
    echo "$otd" | awk "\$5==\"$ipaddr\"{print \$0}" | filter_interface_id
  )

  if [ "$result" = '' ]; then
    echo '# matched under ovtopodump, but without ipaddress-field' >&2
    return 1
  fi
  
  if check_ov_oid_pattern "$result"; then
    echo "$result"
  else
    error 'Unknown InterfaceID-pattern.' "\nSource:\n$otd\nResult:\n$result"
  fi
}

get_node_id()
{
  local -r otd="$1"
  local -r result=$( echo "$otd" | filter_node_id | uniq )
  
  if check_ov_oid_pattern "$result"; then
    echo "$result"
  else
    error 'Unknown NodeID-pattern.' "\nSource:\n$otd\nResult:\n$result"
  fi
}

get_main_ipaddr()
{
  local -r otd="$1"
  local -r result=$( echo "$otd" | filter_main_ipaddr )
  
  if check_ipv4addr_pattern "$result"; then
    echo "$result"
  else
    error 'Unknown IPAddress-pattern.' "\nSource:\n$otd\nResult:\n$result"
  fi
}

make_ovip_sweeper_command() (
  readonly ipaddr="$1"
  echo '# -----------------------------------------------------------------------------'
  echo "# $ipaddr"
  echo '# -----------------------------------------------------------------------------'

  if ( get_otd "$ipaddr" 1>/dev/null 2>&1 ); then
    readonly otd_ip=$( get_otd "$ipaddr" )
  else
    echo '# Not found in this server'
    return 1
  fi

  readonly interface_id=$( get_interface_id "$otd_ip" "$ipaddr" )
  readonly node_id=$( get_node_id "$otd_ip" )
  readonly otd_node=$( get_otd "$node_id" )
  readonly relative_interface_ids=$( echo "$otd_node" | filter_interface_id )
  readonly main_ipaddr=$( get_main_ipaddr "$otd_node" )
  readonly command="/opt/OV/bin/ovtopofix -r $interface_id"

  if [ "$interface_id" ]; then
    if [ "$interface_id" = "$relative_interface_ids" ] || \
    [ "$ipaddr" != "$main_ipaddr" ]; then
      echo "$command"
      echo "###############################################################################"
      echo "# Result of $interface_id: "
      echo "$otd_ip" | perl -nle 'print "#$_"'
    else
      echo '# This object has relationships with other interfaces.'
      echo "# Check object '$node_id' and comment-in below line."
      echo "#$command"
      echo "###############################################################################"
      echo "# Result of $node_id: "
      echo "$otd_node" | perl -nle 'print "#$_"'
    fi
    
    echo
  else
    echo '# Not found in this server'
  fi
)

main() (
  echo '#!/bin/sh'
  echo
  
  filter_ipv4addr | while read ipaddr; do
    make_ovip_sweeper_command "$ipaddr"
  done
)

initialize_environment
main
