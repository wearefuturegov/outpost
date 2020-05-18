import { initialise } from "./google"

const createSingleMap = async mapHolder => {
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

const createListMap = async mapHolder => {
    await initialise()
    let bounds = new window.google.maps.LatLngBounds()
    let map = new window.google.maps.Map(mapHolder, {
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17
    })
    __LOCATIONS__.forEach(location => {
        let position = new window.google.maps.LatLng(
            location.latitude,
            location.longitude
        )
        let marker = new window.google.maps.Marker({
            position: position,
            map: map,
        })
        bounds.extend(position)
        marker.addListener("click", () => {
            window.location.href = `/admin/locations/${location.id}`
        })
    })
    map.fitBounds(bounds)
}

document.querySelectorAll(".map-holder").forEach(m => {
    if(m.dataset.listMap && __LOCATIONS__){
        createListMap(m)
    } else {
        createSingleMap(m)
    }
})