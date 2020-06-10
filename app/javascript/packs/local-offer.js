const editor = document.querySelector(".local-offer-editor")

if(editor){
    const checkbox = editor.querySelector("[data-local-offer]")
    checkbox.addEventListener("change", e => {
        if(e.target.checked){
            // let existingFields = editor.querySelector("[data-local-offer-fields]")
            // if(existingFields){
            //     existingFields.removeAttribute("hidden")
            //     editor.querySelector("input[data-destroy-field]").value = "false"
            // } else {
                let time = new Date().getTime()
                let regexp = new RegExp(checkbox.dataset.id, 'g')
                let newFields = document.createElement("div")
                newFields.dataset.localOfferFields = true
                newFields.innerHTML = checkbox.dataset.fields.replace(regexp, time)
                editor.appendChild(newFields)
            // }
        } else {
            editor.querySelector("[data-local-offer-fields]").remove()
            editor.querySelector("input[data-destroy-field]").value = "true"
        }
    })
}