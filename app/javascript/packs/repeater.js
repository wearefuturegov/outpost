// import { initialise } from "./google"
import tippy from "tippy.js"
import Tagify from "@yaireo/tagify"

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

        // activate any tagifies
        let tagifyInput = newResult.querySelector("[data-labels]")
        if(tagifyInput){
            new Tagify(tagifyInput, {
                originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
            })
        }

        // activate options business
        let type = newResult.querySelector("[data-type]")
        let options = newResult.querySelector("[data-options]")
        if(type && options){
            options.setAttribute("hidden", "true")
            type.addEventListener("change", e => {
                if(type.value === "select"){
                    options.removeAttribute("hidden")
                } else {
                    options.setAttribute("hidden", "true")
                }
            })
        }
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