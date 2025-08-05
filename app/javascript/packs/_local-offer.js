const editor = document.querySelector(".local-offer-editor")

if(editor){
    const checkbox = editor.querySelector("[data-local-offer]")
    checkbox.addEventListener("change", e => {
        if(e.target.checked){
            let time = new Date().getTime()
            let regexp = new RegExp(checkbox.dataset.id, 'g')
            let newFields = document.createElement("div")
            newFields.dataset.localOfferFields = true
            newFields.innerHTML = checkbox.dataset.fields.replace(regexp, time)
            editor.appendChild(newFields)
        } else {
            editor.querySelector("[data-local-offer-fields]").remove()
            editor.querySelector("input[data-destroy-field]").value = "true"
        }
    })
}

// if(editor){
//     const radios = editor.querySelectorAll("[data-local-offer-radio]")
//     radios.forEach(radio => radio.addEventListener("change", e => {
//         if(e.target.value === "yes"){
//             console.log(true)
//             // add fresh fields
//             let time = new Date().getTime()
//             let regexp = new RegExp(checkbox.dataset.id, 'g')
//             let newFields = document.createElement("div")
//             newFields.dataset.localOfferFields = true
//             newFields.innerHTML = checkbox.dataset.fields.replace(regexp, time)
//             editor.appendChild(newFields)
//         } else {
//             // remove fields and delete object
//             editor.querySelector("[data-local-offer-fields]").remove()
//             editor.querySelector("input[data-destroy-field]").value = "true"
//         }
//     }))
// }