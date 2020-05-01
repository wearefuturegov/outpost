import { initialise } from "./google"

const createMap = async mapHolder => {
    await initialise()
    let {lat, long} = mapHolder.dataset
    let location = new window.google.maps.LatLng(parseFloat(lat), parseFloat(long))
    let map = new window.google.maps.Map(mapHolder, {
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17,
        center: location
    })
    let marker = new window.google.maps.Marker({
        position: location,
        map: map,
    })
}

document.querySelectorAll(".map-holder").forEach(m => {
    createMap(m)
})