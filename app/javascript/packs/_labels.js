import "@yaireo/tagify/dist/tagify.polyfills.min.js"
import Tagify from "@yaireo/tagify"

let inputs = document.querySelectorAll("[data-labels=true]")

if(inputs){
    inputs.forEach(input => {
        if(window.__LABELS__){
            new Tagify(input , {
                whitelist: window.__LABELS__.map(label => label.name),
                originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
            })
        } else {
            new Tagify(input , {
                originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(',')
            })
        }
    })
}