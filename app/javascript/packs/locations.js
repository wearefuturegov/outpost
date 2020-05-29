// import { initialise } from "./google"

let editors = document.querySelectorAll(".nested-editor")

editors.forEach(editor => {

    let addButton = editor.querySelector("[data-add]")
    let results = editor.querySelector(".nested-editor__results")

    // Add custom
    addButton.addEventListener("click", e => {
        e.preventDefault()
        let time = new Date().getTime()
        let regexp = new RegExp(addButton.dataset.id, 'g')
        let newResult = document.createElement("li")
        newResult.classList.add("nested-editor__result")
        newResult.innerHTML = addButton.dataset.fields.replace(regexp, time)
        results.appendChild(newResult)
    })

    // Remove this location
    editor.addEventListener("click", e => {
        if(e.target.dataset.close){
            e.preventDefault()
            if(window.confirm("Are you sure you want to remove this item?")){
                let result = e.target.parentNode
                result.setAttribute("hidden", "true")
                result.querySelectorAll(".field").forEach(field => field.remove())
                result.querySelector("input[data-destroy-field]").value = "true"
            }
        }
    })


})