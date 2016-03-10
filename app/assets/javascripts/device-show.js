$(document).on('ready page:change', function() {
  if ($(".c-devices.a-show").length === 0) {
    return;
  } else {
  //page specific code

  map.addControl(L.mapbox.geocoderControl('mapbox.places'));
  var lc = L.control.locate({
    follow: false,
    setView: false,
    markerClass: L.marker,
    markerStyle: {
      icon: L.mapbox.marker.icon({
        'marker-size': 'large',
        'marker-symbol': 'star',
        'marker-color': '#01579B',
      }),
      riseOnHover: true,
    },
    strings: {
      title: 'Your current location',
      popup: 'Your current location within {distance} {unit}.<br><a href="#" id="current-location">Create checkin here</a>',
    },

  }).addTo(map);
  lc.stop();
  lc.start();
  }
});

//OH HAI IT'S GLOBAL SCOPE OUT HERE

function refreshMarkers(){
  markers.clearLayers();
  renderMarkers();
}

function renderMarkers(){
  markers = new L.MarkerClusterGroup();
    for (var i = 0; i < checkins.length; i++) {
      var checkin = checkins[i];
      var marker = L.marker(new L.LatLng(checkin.lat, checkin.lng), {
        icon: L.mapbox.marker.icon({
          'marker-symbol': 'heliport',
          'marker-color': '#ff6900',
        }),
        title: 'ID: ' + checkin.id,
        alt: 'ID: ' + checkin.id
      });
      marker.bindPopup('<h3>ID: ' + checkin.id + '</h3>' + (checkin.address || checkin.fogged_area))

      marker.on('click', function() {
        map.panTo(this.getLatLng());
      });

      markers.addLayer(marker);
    }

  map.addLayer(markers);
}
