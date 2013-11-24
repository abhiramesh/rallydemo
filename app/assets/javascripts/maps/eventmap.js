
var initialLocation;
var siberia = new google.maps.LatLng(60, 105);
var newyork = new google.maps.LatLng(40.69847032728747, -73.9514422416687);
var browserSupportFlag =  new Boolean();
var citymap = {};
var cityCircle;
var eventsArray;


function initialize() {
  var myOptions = {
    zoom: 16,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
  };
  var map = new google.maps.Map(document.getElementById("map-canvas"), myOptions);

  $.ajax({
    type: "GET",
    url: '/get_event_coordinates',
    dataType: "json",
    async: false,
    complete: function(response) {
      eventsArray = response.responseJSON;
    }
  });
  

  // citymap['philly'] = {
  //   center: initialLocation,
  //   number: 12
  //   };
  //   for (var city in citymap) {
  //     var numberOptions = {
  //       strokeColor: '#e96936',
  //       strokeOpacity: 0.7,
  //       strokeWeight: 1,
  //       fillColor: '#e96936',
  //       fillOpacity: 0.7,
  //       map: map,
  //       center: citymap["philly"].center,
  //       radius: 100
  //     };
  //     // Add the circle for this city to the map.
  //     cityCircle = new google.maps.Circle(numberOptions);
  //   }

  
  // Try W3C Geolocation (Preferred)
  if(navigator.geolocation) {
    browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition(function(position) {
      initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
      map.setCenter(initialLocation);

        for (var e in eventsArray) {
          if (eventsArray[e]["lat"] && eventsArray[e]["lng"]){
            var point = new google.maps.LatLng(parseFloat(eventsArray[e]["lat"]), parseFloat(eventsArray[e]["lng"]));
            var eventOptions = {
              strokeColor: '#e96936',
              strokeOpacity: 0.7,
              strokeWeight: 1,
              fillColor: '#e96936',
              fillOpacity: 0.7,
              map: map,
              center: point,
              radius: 100000
            };
            console.log(point);
            eventCircle = new google.maps.Circle(eventOptions);
          };
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

