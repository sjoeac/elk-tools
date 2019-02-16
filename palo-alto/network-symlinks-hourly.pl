#!/usr/bin/perl
use strict;
use Data::Dumper;


if ( -l "/rsyslog/logs/network_logs/PA-3020/prod-firewall.log" ) {
    unlink "/rsyslog/logs/network_logs/PA-3020/prod-firewall.log"
        or warn "Failed to remove file /rsyslog/logs/network_logs/PA-3020/prod-firewall.log: $!\n";
}

my @list = `ls -t /rsyslog/logs/network_logs/PA-3020/`;
my $newest = $list[0];
chomp $newest;


system ("ln -s /rsyslog/logs/network_logs/PA-3020/$newest  /rsyslog/logs/network_logs/PA-3020/prod-firewall.log ");

