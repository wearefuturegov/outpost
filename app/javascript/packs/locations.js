import { initialise } from "./google"

let locationSearch = document.querySelector(".location-search")

if(locationSearch){

    let addButton = locationSearch.querySelector("[data-add]")
    let results = locationSearch.querySelector(".location-search__results")

    // Add custom
    addButton.addEventListener("click", e => {
        e.preventDefault()
        let time = new Date().getTime()
        let regexp = new RegExp(addButton.dataset.id, 'g')

        let newResult = document.createElement("li")
        newResult.classList.add("location-search__result")
        newResult.innerHTML = addButton.dataset.fields.replace(regexp, time)
        results.appendChild(newResult)
    })

    // Remove this location
    locationSearch.addEventListener("click", e => {
        if(e.target.dataset.close){
            e.preventDefault()
            if(window.confirm("Are you sure you want to remove this location?")){
                let result = e.target.parentNode
                result.setAttribute("hidden", "true")
                result.querySelector("input[data-destroy-field]").value = "true"
            }
        }
    })

    let searchInput = locationSearch.querySelector("input[data-google-places-autocomplete]")
    let autocomplete
    
    // Autocomplete
    const initAutocomplete = async () => {
        await initialise()
        if(searchInput){
            autocomplete = new window.google.maps.places.Autocomplete(searchInput)
            autocomplete.setComponentRestrictions({"country": ["gb"]})
            autocomplete.addListener("place_changed", handlePlaceChanged)
        }
    }
    
    initAutocomplete()
    
    const handlePlaceChanged = () => {
        const place = autocomplete.getPlace()
        searchInput.value = ""

        let time = new Date().getTime()
        let regexp = new RegExp(addButton.dataset.id, 'g')

        let newResult = document.createElement("li")
        newResult.classList.add("location-search__result")
        newResult.innerHTML = addButton.dataset.fields.replace(regexp, time)

        let address = []

        place.address_components.forEach(component => {
            component.types.includes("premise") && (newResult.querySelector("[data-field='premise']").value = component.long_name)

            component.types.includes("street_number") && address.push(component.long_name)
            component.types.includes("route") && address.push(component.long_name)

            component.types.includes("postal_town") && (newResult.querySelector("[data-field='postal_town']").value = component.long_name)
            component.types.includes("locality") && (newResult.querySelector("[data-field='postal_town']").value = component.long_name)

            component.types.includes("postal_code") && (newResult.querySelector("[data-field='postal_code']").value = component.long_name)
        })

        newResult.querySelector("[data-field='street_number_route']").value = address.join(" ")

        if(place.name) newResult.querySelector("[data-field='premise']").value = place.name

        newResult.querySelector("[data-field='latitude']").value = place.geometry.location.lat()
        newResult.querySelector("[data-field='longitude']").value = place.geometry.location.lng()
        newResult.querySelector("[data-field='google_place_id']").value = place.place_id

        results.appendChild(newResult)
    }

}