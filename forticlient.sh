#!/usr/bin/expect -f

set timeout $env(VPNTIMEOUT)

spawn "/opt/forticlient/forticlientsslvpn_cli" --server $env(VPNADDR) --vpnuser $env(VPNUSER) --keepalive
send -- "\r"
# Send command
expect -exact "Password for VPN:"
send -- "$env(VPNPASS)\n"

expect -exact "STATUS::Connecting..."

# In case of invalid certificate
expect -exact "Would you like to connect to this server? (Y/N)" {
  send -- "Y\n"
}

# Expect tunnel to actually start
expect {
  "STATUS::Tunnel running" {
  } timeout {
    send_user -- "Failed to bring tunnel up after $env(VPNTIMEOUT)s\n"
    exit 1
  }
}

# Expect tunnel to stop but not exit
set timeout -1
expect {
  "STATUS::Tunnel closed" {
    exit 1
  }
  eof {
    exit
  }
}
