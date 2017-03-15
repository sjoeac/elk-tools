#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;

my $home = '/home/csteve/s3_backup';
my $lte = 1489257000000;
my $final_lte = 1489343400000;
my $date = "mar12";

my $gte;
while ($lte < $final_lte){
$gte = $lte;
$lte = $gte + 1000;
my $cmd = qq{ 

curl -XGET 'http://10.1.20.45:9200/*bankbridgeservice*/_search?pretty&filter_path=hits.hits._source' -d  '{
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
    open(my $fd, ">> $home/bankbridge-service_$date.txt") or die $!;
    print localtime() . $hit->{'_source'}->{'source'} . "\n" ;
    print $fd $hit->{'_source'}->{'message'} . "\n" ;
    close $fd;
}

if ($hit->{'_source'}->{'source'} =~ /warehouse/i) {
    open(my $fd, ">> $home/warehouse_$date.txt") or die $1;
    print localtime() . $hit->{'_source'}->{'source'} . "\n" ;
    print $fd $hit->{'_source'}->{'message'} . "\n" ;
    close $fd;
}

}
}

