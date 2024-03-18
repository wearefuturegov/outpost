import { Loader } from "@googlemaps/js-api-loader";
import { googleLoaderOptions } from "./google";

const loader = new Loader({
  ...googleLoaderOptions,
});

const createSingleMap = async (mapHolder) => {
  loader
    .importLibrary("maps")
    .then(({ Map }) => {
      let { lat, long } = mapHolder.dataset;
      let location = new google.maps.LatLng(parseFloat(lat), parseFloat(long));
      let map = new Map(mapHolder, {
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17,
        center: location,
        mapId: "single_map",
      });
      console.log(map);
      let marker = new google.maps.marker.AdvancedMarkerElement({
        position: location,
        map: map,
      });
    })
    .catch((e) => {
      // do something
    });
};

const createListMap = async (mapHolder) => {
  loader
    .importLibrary("maps")
    .then(({ Map }) => {
      let bounds = new google.maps.LatLngBounds();
      let map = new Map(mapHolder, {
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17,
        mapId: "list_map",
      });
      __LOCATIONS__.forEach((location) => {
        let position = new google.maps.LatLng(
          location.latitude,
          location.longitude
        );
        let marker = new google.maps.marker.AdvancedMarkerElement({
          position: position,
          map: map,
          title: location.name,
        });
        bounds.extend(position);
        marker.addListener("click", () => {
          window.location.href = `/admin/locations/${location.id}`;
        });
      });
      map.fitBounds(bounds);
    })
    .catch((e) => {
      // do something
    });
};

document.querySelectorAll(".map-holder").forEach((m) => {
  if (m.dataset.listMap && __LOCATIONS__) {
    createListMap(m);
  } else {
    createSingleMap(m);
  }
});
