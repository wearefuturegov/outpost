import Choices from "choices.js"

// enhanced select
if(document.querySelector(".enhanced-select")){
    const choices = new Choices(document.querySelector(".enhanced-select"))
}

const locationEditor = document.querySelector("#locations-editor")

const addNewButton = locationEditor.querySelector(".add-new-location")
const content = locationEditor.querySelector(".collapsible__content")

addNewButton.addEventListener("click", e => {
    e.preventDefault()
    e.target.setAttribute("aria-expanded", "true")
    e.target.disabled = true

    console.log(content)

    content.innerHTML += `
        <div class="field-section field-section--two-cols field-section--panel">
            <h3 class="field">New location</h3>
            <div class="field field--span-two-cols">
                <label class="field__label" for="service_locations_attributes_new_address_1">Street address</label>
                <input class="field__input" type="text" value="" name="service[locations_attributes][][address_1]" id="service_locations_attributes_0_address_1">
            </div>
            <div class="field">
                <label class="field__label" for="service_locations_attributes_new_city">Town or area</label>
                <input class="field__input" type="text" value="" name="service[locations_attributes][][city]" id="service_locations_attributes_0_city">
            </div>
            <div class="field">
                <label class="field__label" for="service_locations_attributes_new_postal_code">Postcode</label>
                <input class="field__input" type="text" value="" name="service[locations_attributes][][postal_code]" id="service_locations_attributes_0_postal_code">
            </div>
        </div>
    `
})


// import SearchApi from 'js-worker-search'

// const ui = document.querySelector(".location-search")

// const searchBox = ui.querySelector(".location-search__input")
// const resultsArea = ui.querySelector(".location-search__results")
// const results = ui.querySelectorAll(".location-search__result")

// const prompt = ui.querySelector(".location-search__prompt")
// const noResults = ui.querySelector(".location-search__no-results")

// const searchApi = new SearchApi()

// // 1. Populate index
// results.forEach(result => {
//     searchApi.indexDocument(result.dataset.id, JSON.parse(result.dataset.indexed).one_line_address)
// })

// // 2. Listen for queries
// searchBox.addEventListener("keyup", e => search(e.target.value))

// // 3. To begin with, hide every result apart from the checked ones
// results.forEach(result => {
//     if(!result.querySelector(".checkbox__input").checked){
//         result.setAttribute("hidden", "true")
//     }
// })

// // 4. Search index for query
// const search = async query => {
//     if(query.length > 2){
//         prompt.setAttribute("hidden", "true")
//         const matches = await searchApi.search(query)
//         if(matches.length > 0){
//             noResults.setAttribute("hidden", "true")
//             results.forEach(result => {
//                 if(matches.includes(result.dataset.id)){
//                     result.removeAttribute("hidden")
//                 } else {
//                     hideIfNotChecked(result)
//                 }
//             })
//         } else {
//             noResults.removeAttribute("hidden")
//         }
//     } else {
//         noResults.setAttribute("hidden", "true")
//         prompt.removeAttribute("hidden")
//         results.forEach(result => hideIfNotChecked(result))
//     }
// }

// const hideIfNotChecked = result => {
//     if(!result.querySelector(".checkbox__input").checked){
//         result.setAttribute("hidden", "true")
//     }
// }

// // TODO 5. When a box is unticked, kick it from the results if it's not part of the current query
// // ...