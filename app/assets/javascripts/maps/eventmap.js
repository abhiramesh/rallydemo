var initialLocation;
var siberia = new google.maps.LatLng(60, 105);
var newyork = new google.maps.LatLng(40.69847032728747, -73.9514422416687);
var browserSupportFlag =  new Boolean();
var citymap = {};
var cityCircle;
var eventsArray;
var locationCity;
var actualLocation;
var eventLocation;
var styleArray = [
  {
    "stylers": [
      { "invert_lightness": true },
      { "visibility": "on" }
    ]
  }
];


function initialize() {
  var myOptions = {
    zoom: 13,
    scrollwheel: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    styles: styleArray

  };
  var map = new google.maps.Map(document.getElementById("map-canvas"), myOptions);


  // Try W3C Geolocation (Preferred)
  if(navigator.geolocation) {
    browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition(function(position) {
      initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
      map.setCenter(initialLocation);

        $.ajax({
          type: "GET",
          url: 'http://maps.googleapis.com/maps/api/geocode/json?latlng=' + position.coords.latitude + ',' + position.coords.longitude + '&sensor=false',
          dataType: "json",
          async: true,
          complete: function(response) {
            locationCity = response.responseJSON.results[0].address_components;
            $.each(locationCity, function(){
                if(this.types[0]=="administrative_area_level_2"){
                    actualLocation=this.short_name;
                }
            });
            getEventList(actualLocation);
          }
        });

        function getEventList(actualLocation){
            $.ajax({
              type: "GET",
              url: '/get_event_list',
              dataType: "json",
              async: true,
              complete: function(response) {
                eventsArray = response.responseJSON;
                getLocationCoords(eventsArray,actualLocation);
              }
            });
        };
      
        function getLocationCoords(eventsArray,actualLocation){
           for (var e in eventsArray) {
            $.ajax({
              type: "GET",
              url: "http://maps.googleapis.com/maps/api/geocode/json?address=" + eventsArray[e]["location"] + "+" + actualLocation + "&sensor=false",
              dataType: "json",
              async: true,
              complete: function(response) {
                eventLocation = response.responseJSON.results[0].geometry.location
                plotPoint(eventLocation);
              }
            });
          };
        }

      function plotPoint (eventLocation) {
        if (eventLocation.lat && eventLocation.lng) {
          var point = new google.maps.LatLng(eventLocation.lat, eventLocation.lng);
          var eventOptions = {
            strokeColor: '#e96936',
            strokeOpacity: 0.7,
            strokeWeight: 1,
            fillColor: '#e96936',
            fillOpacity: 0.8,
            map: map,
            center: point,
            radius: 250
            };
        };
        eventCircle = new google.maps.Circle(eventOptions);
      };
	  
    }, function() {
      handleNoGeolocation(browserSupportFlag);
    });
  }
  // Browser doesn't support Geolocation
  else {
    browserSupportFlag = false;
    handleNoGeolocation(browserSupportFlag);
  }

  function handleNoGeolocation(errorFlag) {
    if (errorFlag == true) {
      alert("Geolocation service failed.");
      initialLocation = newyork;
    } else {
      alert("Your browser doesn't support geolocation. We've placed you in Siberia.");
      initialLocation = siberia;
    }
    map.setCenter(initialLocation);
  }
}

google.maps.event.addDomListener(window, 'load', initialize);

