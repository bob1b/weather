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
# http://dataservice.accuweather.com/locations/v1/cities/search?apikey=Umn6NxjyQjHqjdYhUmvKQDVI1uNfHiXt&q=prescott%20valley&details=true&offset=1

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
# http://dataservice.accuweather.com/currentconditions/v1/2134108?apikey=Umn6NxjyQjHqjdYhUmvKQDVI1uNfHiXt

my $weather_url = "$base/currentconditions/v1/$loc_id?apikey=$api_key";
$request = HTTP::Request->new(GET => $weather_url);
$response = $ua->request($request);
$content = $response->content;

my $weathers_ref;
if ($response->is_success) {
	$weathers_ref = JSON->new->utf8->decode($content);
} else {
    print "Error: url = $weather_url, \nresponse = " . Dumper($response);
    exit(2);
}

# use only the first weather report for now
my @weathers = @$weathers_ref;
my $weather = $weathers[0];


# encode info hash as JSON
my %out = ( 'location' => $location, 'weather' => $weather );
my $json_out = JSON->new->utf8->encode(\%out);

print $json_out;
