import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import MapboxGeocoder from '@mapbox/mapbox-gl-geocoder';
import '@mapbox/mapbox-gl-geocoder/dist/mapbox-gl-geocoder.css';


const initMapbox = () => {
  const mapElement = document.getElementById('map');

  const fitMapToMarkers = (map, markers) => {
    const bounds = new mapboxgl.LngLatBounds();
    markers.forEach(marker => bounds.extend([ marker.lng, marker.lat ]));
    map.fitBounds(bounds, { padding: 70, maxZoom: 8, duration: 0 });
  };

  if (mapElement) { // only build a map if there's a div#map to inject into
    mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;

    const map = new mapboxgl.Map({
      container: 'map',
      style: 'mapbox://styles/mapbox/streets-v10'
    });

     const markers = JSON.parse(mapElement.dataset.markers);
     markers.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window);

      // const activity = document.getElementsByClassName("activity") // Array of activity name
      // activity.forEach((name) => {
      //   // console.log(entry);
      //   name
      // });
      // if ()

      if (marker.image_url) {
        const element = document.createElement('div');
        element.className = 'marker';
        element.style.backgroundImage = `url('${marker.image_url}')`;
        element.style.backgroundSize = 'contain';
        element.style.width = '25px';
        element.style.height = '25px';




        // const date =  document.getElementsByClassName("date") // Array of date
        // if (date.count === 1) {
          new mapboxgl.Marker(element)
            // color: "#FFFFFF",
            // draggable: true
            .setLngLat([ marker.lng, marker.lat ])
            .setPopup(popup)
            .addTo(map);
          }  else {
            new mapboxgl.Marker()
            // color: "#FFFFFF",
            // draggable: true
            .setLngLat([ marker.lng, marker.lat ])
            .setPopup(popup)
            .addTo(map);

            }


      // } else if (date.count === 2) {
      //   new mapboxgl.Marker({
      //     color: "#FFFFFF",
      //     draggable: true
      //     }).setLngLat([ marker.lng, marker.lat ])
      //     .setPopup(popup)
      //     .addTo(map);
      // }

  // Create a HTML element for your custom marker




    });
    map.addControl(new MapboxGeocoder({ accessToken: mapboxgl.accessToken,
                                      mapboxgl: mapboxgl }));
   fitMapToMarkers(map, markers);

  }

};

export { initMapbox };
