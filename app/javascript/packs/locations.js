import { initialise } from "./google"

let locationSearch = document.querySelector(".location-search")

if(locationSearch){

    let addButton = locationSearch.querySelector("[data-add]")

    addButton.addEventListener("click", e => {
        e.preventDefault()
        let time = new Date().getTime()
        let regexp = new RegExp(addButton.dataset.id, 'g')
        let results = locationSearch.querySelector(".location-search__results")
        results.innerHTML += addButton.dataset.fields.replace(regexp, time)
        
        results.querySelector("[data-close]").addEventListener("click", e => {
            e.preventDefault()
            close(e)
        })
    })

    locationSearch.querySelectorAll("[data-close]").forEach(closer => closer.addEventListener("click", close))

    const close = e => {
        e.preventDefault()
        if(window.confirm("Are you sure you want to remove this location?")){
            let result = e.target.parentNode.parentNode
            result.setAttribute("hidden", "true")
            result.querySelector("input[data-destroy-field]").value = "true"
        }
    }
}






//     let searchInput = locationSearch.querySelector("input[data-google-places-autocomplete]")
//     let autocomplete
    
//     const initAutocomplete = async () => {
//         await initialise()
//         if(searchInput){
//             autocomplete = new window.google.maps.places.Autocomplete(searchInput)
//             autocomplete.setComponentRestrictions({"country": ["gb"]})
//             autocomplete.addListener("place_changed", handlePlaceChanged)
//         }
//     }
    
//     initAutocomplete()
    
//     const handlePlaceChanged = () => {
//         const place = autocomplete.getPlace()
//         searchInput.value = ""
//         console.log(place)
//     }