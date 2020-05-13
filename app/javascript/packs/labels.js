import Tagify from '@yaireo/tagify'

let inputs = document.querySelectorAll("[data-labels]")

inputs.forEach(input => {
    let tagify = new Tagify(input , {
        whitelist: __LABELS__.map(label => label.name)
    })
})