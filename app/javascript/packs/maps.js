import {Loader, LoaderOptions} from "google-maps"

const loader = new Loader(process.env.GOOGLE_CLIENT_KEY)

let mapHolders = document.querySelectorAll(".map-holder")

const createMap = async mapHolder => {
    const google = await loader.load()
    let {lat, long} = mapHolder.dataset
    let location = new google.maps.LatLng(parseFloat(lat), parseFloat(long))

    let map = new google.maps.Map(mapHolder, {
        mapTypeControl: false,
        streetViewControl: false,
        zoom: 17,
        center: location
    })

    let marker = new google.maps.Marker({
        position: location,
        map: map,
    })
}

mapHolders.forEach(m => {
    createMap(m)
})