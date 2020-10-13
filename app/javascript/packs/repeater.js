// import { initialise } from "./google"
import tippy from "tippy.js"

let editors = document.querySelectorAll(".repeater")

editors.forEach(editor => {

    let addButton = editor.querySelector("[data-add]")
    let results = editor.querySelector(".repeater__panels")

    // Add item
    addButton.addEventListener("click", e => {
        e.preventDefault()
        let time = new Date().getTime()
        let regexp = new RegExp(addButton.dataset.id, 'g')
        let newResult = document.createElement("li")
        newResult.classList.add("repeater__panel")
        newResult.innerHTML = addButton.dataset.fields.replace(regexp, time)
        results.appendChild(newResult)

        // activate any tippies
        tippy("[data-tippy-content]") 
    })

    // Remove item
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