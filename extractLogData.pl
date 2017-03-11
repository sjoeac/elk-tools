#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;

my $gte =  1488738000000;
my $lte =  1488738010000;
my $home = '/LogBackups/s4_backup';

while ($lte <= (1488825800000)){
$gte = $lte;
$lte = $gte + 1000;

my $cmd = qq{ 

curl -XGET 'http://10.1.20.44:9200/*bankbridgeservice*/_search?pretty&filter_path=hits.hits._source' -d  '{
"size" : 10000,
"_source":  {
       "includes": ["\@timestamp", "message", "source"]
   },
"query": {
       "bool": {
           "must": [
       {
         "query_string": {
           "query": "beat.hostname: 's3'",
           "analyze_wildcard": true
         }
       },
               {
         "range": {
           "\@timestamp": {
             "gte": $gte,
     "lte": $lte,
             "format": "epoch_millis"
           }
         }
       }
           ]
       }
   }
}'




};


my $data = decode_json ` $cmd `;

foreach my $hit (@{$data->{'hits'}->{'hits'}}) {

if ($hit->{'_source'}->{'source'} =~ /bankbridge-service.log/i) {
    open(my $fd, ">> $home/bankbridge-service_mar6.txt") or die $!;
    print localtime() . $hit->{'_source'}->{'source'} . "\n" ;
    print $fd $hit->{'_source'}->{'message'} . "\n" ;
    close $fd;
}

if ($hit->{'_source'}->{'source'} =~ /warehouse/i) {
    open(my $fd, ">> $home/warehouse_mar6.txt") or die $1;
    print localtime() . $hit->{'_source'}->{'source'} . "\n" ;
    print $fd $hit->{'_source'}->{'message'} . "\n" ;
    close $fd;
}

}
}

