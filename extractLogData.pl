#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;

my $gte =  1488724800000;
my $lte = 1;
my $home = '/LogBackups/s3_backup';

while ($lte <= (1488825800000)){
$lte = $gte + 10000;

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
    open(my $fd, ">>/tmp/bankbridge-service.txt");
    print $fd $hit->{'_source'}->{'message'} . "\n" ;
    close $fd;
}

if ($hit->{'_source'}->{'source'} =~ /warehouse.log/i) {
    open(my $fd, ">>/tmp/warehouse.txt");
    print $fd $hit->{'_source'}->{'message'} . "\n" ;
    close $fd;
}


}


}
