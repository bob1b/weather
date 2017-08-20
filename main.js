function getWeatherIconURL( id ){
  var valid_ids = [ 1,2,3,4,5,6,7,8,11,12,13,14,15,16,17,18,19,20,
                    21,22,23,24,25,26,29,30,31,32,33,34,35,36,37,38,
                    39,40,41,42,43,44 ];
  if ( typeof(id) !== "undefined" && $.inArray( id, valid_ids >= 0 ) ){
    if (id < 10){
      id = "0" + id;
    }
    return "./media/" + id + "-s.png";
  } else {
    return "";
  }
}

/**
 * Function : dump()
 * Arguments: The data - array,hash(associative array),object
 *    The level - OPTIONAL
 * Returns  : The textual representation of the array.
 * This function was inspired by the print_r function of PHP.
 * This will accept some data as the argument and return a
 * text that will be a more readable version of the
 * array/hash/object that is given.
 * Docs: http://www.openjs.com/scripts/others/dump_function_php_print_r.php
 */
function dump(arr,level) {
    var dumped_text = "";
    if(!level) level = 0;

    //The padding given at the beginning of the line.
    var level_padding = "";
    for(var j=0;j<level+1;j++) level_padding += "    ";

    if(typeof(arr) == 'object') { //Array/Hashes/Objects
        for(var item in arr) {
            var value = arr[item];

            if(typeof(value) == 'object') { //If it is an array,
                dumped_text += level_padding + "'" + item + "' ...\n";
                dumped_text += dump(value,level+1);
            } else {
                dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
            }
        }
    } else { //Stings/Chars/Numbers etc.
        dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
    }
    return dumped_text;
}

function geoLink(geo){
  return '<a href="https://www.google.com/maps/search/' +
         geo.Latitude + "," + geo.Longitude + '" target="_blank" ' +
         'title="Google map">' +
         geo.Latitude + ", " + geo.Longitude + '</a>';
}

$(document).ready(function() {

  // autofocus location input box
  $("#location").focus();

  $('.theForm').submit( function(e) {
    var loc = $("#location").val().trim();
    var templ="";

    if ( loc !== "" ){
      var url = "http://70.32.24.233/cgi-bin/weather/fetch.pl?q=" + loc;
      $.getJSON( url, function( data ){
          var l = data.location;
          var w = data.weather;

          var keys = [ { n:"%name", v:l.Details.DMA.EnglishName },
                       { n:"%geo", v:geoLink(l.GeoPosition) },
                       { n:"%elev", v:l.GeoPosition.Elevation.Imperial.Value + " " +
                                      l.GeoPosition.Elevation.Imperial.Unit },
                       { n:"%timezone", v:l.TimeZone.Code },
                       { n:"%link", v:w.Link },
                       { n:"%temp", v:w.Temperature.Imperial.Value + " " +
                                      w.Temperature.Imperial.Unit },
                       { n:"%realFeelTemp", v:w.RealFeelTemperature.Imperial.Value + " " +
                                              w.RealFeelTemperature.Imperial.Unit },
                       { n:"%wind", v:w.Wind.Direction.Degrees + " degrees (" +
                                      w.Wind.Direction.English + ")<br> at " +
                                      w.Wind.Speed.Imperial.Value + " " +
                                      w.Wind.Speed.Imperial.Unit },
                       { n:"%humidity", v:w.RelativeHumidity + "%" },
                       { n:"%dewPoint", v:w.DewPoint.Imperial.Value + " " +
                                          w.DewPoint.Imperial.Unit },
                       { n:"%uv", v:w.UVIndexText },
                       { n:"%weatherText", v:w.WeatherText },
                       { n:"%weatherIconURL", v:getWeatherIconURL(w.WeatherIcon) } ];

          var tmpl = $("#report_template").html();

          // fill in template
          for ( var i = 0; i < keys.length; i++ ){
            tmpl = tmpl.replace(keys[i].n, keys[i].v);
          }


          $("#report").removeClass("inactive")
                      .html( tmpl );
          if (w.IsDayTime){
            $("#report").addClass("isNight");
          }

          $(".theForm").removeClass("big");

      });
    }

    e.preventDefault();
  });

});
