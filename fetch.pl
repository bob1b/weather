#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);
print header('application/json');

require HTTP::Request;
use LWP::UserAgent;
use JSON;
use Data::Dumper;


my $api_key = "Umn6NxjyQjHqjdYhUmvKQDVI1uNfHiXt";
my $base = "http://dataservice.accuweather.com";
my $query = "86315";


# match zip code/city to location key
# http://dataservice.accuweather.com/locations/v1/cities/search?apikey=QycgAEC2iFEB8WdGDrmm1nB4ksyHE4Vd&q=prescott%20valley&details=true&offset=1

my $city_search_url = "$base/locations/v1/cities/search?apikey=$api_key&q=$query&details=true&offset=1";

# create and perform the API location request
my $request = HTTP::Request->new(GET => $city_search_url);
my $ua = LWP::UserAgent->new;
my $response = $ua->request($request);
my $content = $response->content;

my $locations_ref;
if ($response->is_success) {
    $locations_ref = JSON->new->utf8->decode($content);
} else {
    print "Error: url = $city_search_url, \nresponse = " . Dumper($response);
    exit(1);
}

## use only the first location for now
my @locations = @$locations_ref;
my $location = $locations[0];
my $loc_id = $location->{'Details'}->{'Key'};



# use location key to fetch current weather
# http://dataservice.accuweather.com/currentconditions/v1/37001_PC?apikey=QycgAEC2iFEB8WdGDrmm1nB4ksyHE4Vd

my $weather_url = "$base/currentconditions/v1/$loc_id?apikey=$api_key";
$request = HTTP::Request->new(GET => $weather_url);
$response = $ua->request($request);
my $weather = $response->content;

my $weather_info;
if ($response->is_success) {
	$weather_info = JSON->new->utf8->decode($content);
} else {
    print "Error: url = $weather_url, \nresponse = " . Dumper($response);
    exit(2);
}

# encode info hash as JSON
my %out = ( 'location' => $location, 'weather' => $weather_info );
my $json_out = JSON->new->utf8->encode(\%out);

print $json_out;
