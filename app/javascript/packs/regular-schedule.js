let editors = document.querySelectorAll(".schedule-editor")

editors.forEach(editor => {

    let addButton = editor.querySelector("[data-add]")
    let results = editor.querySelector(".schedule-editor__results")

    // Add custom
    addButton.addEventListener("click", e => {
        e.preventDefault()
        let time = new Date().getTime()
        let regexp = new RegExp(addButton.dataset.id, 'g')
        let newResult = document.createElement("tr")
        newResult.classList.add("schedule-editor__result")
        newResult.innerHTML = addButton.dataset.fields.replace(regexp, time)
        results.appendChild(newResult)
    })

    // Remove this location
    editor.addEventListener("click", e => {
        if(e.target.dataset.close){
            e.preventDefault()
            if(window.confirm("Are you sure you want to remove this item?")){
                let result = e.target.parentNode.parentNode
                console.log(result)
                result.setAttribute("hidden", "true")
                result.querySelector("input[data-destroy-field]").value = "true"
            }
        }
    })


})