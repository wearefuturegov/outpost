import { Loader } from "@googlemaps/js-api-loader";

function createCustomMarker(src, width = 40, height = 40) {
  const img = document.createElement("img");
  img.src = src;
  img.style.width = `${width}px`;
  img.style.height = `${height}px`;
  img.style.objectFit = "contain";
  img.style.pointerEvents = "none";
  return img;
}

const createSingleMap = async (mapHolder, loader) => {
  loader
    .importLibrary("maps")
    .then(({ Map }) => {
      const markerSrc = new URL("marker.svg", import.meta.url).href;
      const customMarker = createCustomMarker(markerSrc, 40, 40); // Set your desired size

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
      const markerSrc = new URL("marker.svg", import.meta.url).href;
      const customMarker = createCustomMarker(markerSrc, 40, 40); // Set your desired size

      // const customMarker = document.createElement("img");
      // customMarker.src = new URL("marker.svg", import.meta.url).href;
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
