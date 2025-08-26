import { Loader } from "@googlemaps/js-api-loader";

const parser = new DOMParser();
const pinSvgString =
  '<svg xmlns="http://www.w3.org/2000/svg" fill="none" width="40" height="40" viewBox="0 0 81 105"><g filter="url(#a)"><path fill="#41429B" d="M40.09 3C20.711 3 5 17.93 5 36.34c.008 1.387.11 2.773.3 4.148C8.3 66.5 37.81 96.5 37.81 96.5c.437.473.949.864 1.52 1.16l1 .29 1-.29a5.972 5.972 0 0 0 1.542-1.16s29.09-30 32.02-56.07c.18-1.355.278-2.722.29-4.09C75.18 17.93 59.468 3 40.09 3Z"/><path fill="#fff" fill-rule="evenodd" d="M42.871 96.5s29.09-30 32.02-56.07c.18-1.355.278-2.722.29-4.09C75.18 17.93 59.468 3 40.09 3S5 17.93 5 36.34c.008 1.387.11 2.773.3 4.148C8.3 66.5 37.81 96.5 37.81 96.5c.437.473.949.864 1.52 1.16l1 .29 1-.29a5.972 5.972 0 0 0 1.542-1.16Zm-2.54-1.745c.133-.099.258-.209.374-.33l.006-.007.006-.006.015-.015.056-.059c.051-.053.129-.134.23-.242a95.5 95.5 0 0 0 .9-.966c.782-.85 1.908-2.1 3.271-3.682a178.366 178.366 0 0 0 10.147-12.943C62.922 65.82 70.535 52.33 71.91 40.095l.003-.03.004-.029c.163-1.231.252-2.471.263-3.709C72.173 19.723 57.954 6 40.09 6 22.225 6 8.005 19.725 8 36.332c.007 1.248.1 2.5.272 3.743l.005.035.004.035c1.407 12.196 9.132 25.669 16.832 36.35A179.35 179.35 0 0 0 35.41 89.431a153.818 153.818 0 0 0 3.319 3.682 96.24 96.24 0 0 0 1.147 1.209l.056.058.016.016.032.032.03.034c.1.107.207.205.32.292Z" clip-rule="evenodd"/><path fill="#141451" d="M54 37c0 7.732-6.268 14-14 14s-14-6.268-14-14 6.268-14 14-14 14 6.268 14 14Z"/></g><defs><filter id="a" width="80.18" height="104.95" x="0" y="0" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse"><feFlood flood-opacity="0" result="BackgroundImageFix"/><feColorMatrix in="SourceAlpha" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"/><feOffset dy="2"/><feGaussianBlur stdDeviation="2.5"/><feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.2 0"/><feBlend in2="BackgroundImageFix" result="effect1_dropShadow"/><feBlend in="SourceGraphic" in2="effect1_dropShadow" result="shape"/></filter></defs></svg>';
const customMarker = parser.parseFromString(
  pinSvgString,
  "image/svg+xml"
).documentElement;

const createSingleMap = async (mapHolder, loader) => {
  loader
    .importLibrary("maps")
    .then(({ Map }) => {
      let { lat, long } = mapHolder.dataset;
      let location = new google.maps.LatLng(parseFloat(lat), parseFloat(long));
      let map = new Map(mapHolder, {
        mapId: "single-map",
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17,
        center: location,
      });
      let marker = new google.maps.marker.AdvancedMarkerElement({
        position: location,
        map: map,
        content: customMarker.cloneNode(true),
      });
    })
    .catch((e) => {
      // do something
    });
};

const createListMap = async (mapHolder, loader) => {
  loader
    .importLibrary("maps")
    .then(({ Map }) => {
      let bounds = new google.maps.LatLngBounds();
      let map = new Map(mapHolder, {
        mapId: "list-map",
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17,
      });
      __LOCATIONS__.forEach((location) => {
        let position = new google.maps.LatLng(
          location.latitude,
          location.longitude
        );
        let marker = new google.maps.marker.AdvancedMarkerElement({
          position: position,
          map: map,
          title: location.display_name,
          content: customMarker.cloneNode(true),
        });

        const contentParts = [
          location.display_name
            ? location.admin_path
              ? `<h3><a href="${location.admin_path}">${location.display_name}</a></h3>`
              : `<h3>${location.display_name}</h3>`
            : "",
          "<p>",
          location.address_1
            ? `<strong>Address:</strong> ${location.address_1}`
            : "",
          location.city
            ? `<br /><strong>Town or area:</strong> ${location.city}`
            : "",
          location.postal_code
            ? `<br /><strong>Postcode:</strong> ${location.postal_code}`
            : "",
          location.servicesCount
            ? `<br /><strong>Services:</strong> ${location.servicesCount}`
            : "",
          location.admin_path
            ? `<br /><a href="${location.admin_path}">View location</a>`
            : "",
          "</p>",
        ];

        const contentString = contentParts.join("");
        const infoWindow = new google.maps.InfoWindow({
          content: contentString,
        });
        bounds.extend(position);
        marker.addListener("click", () => {
          infoWindow.open({
            anchor: marker,
            map,
          });
          // window.location.href = `/admin/locations/${location.id}`;
        });
      });
      map.fitBounds(bounds);
    })
    .catch((e) => {
      // do something
    });
};

document.addEventListener("turbolinks:load", () => {
  document.querySelectorAll(".map-holder").forEach((m) => {
    const loader = new Loader({
      apiKey:
        (typeof process !== "undefined"
          ? process.env.GOOGLE_CLIENT_KEY
          : GOOGLE_CLIENT_KEY) || "",
      version: "weekly",
      libraries: ["marker"],
    });

    if (m.dataset.listMap && __LOCATIONS__) {
      createListMap(m, loader);
    } else {
      createSingleMap(m, loader);
    }
  });
});
