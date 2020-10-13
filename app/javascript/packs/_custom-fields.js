let panels = document.querySelectorAll("[data-custom-fields]")

panels.forEach(panel => {


    let type = panel.querySelector("[data-type]")
    let options = panel.querySelector("[data-options]")


    if(type.value === "select"){
        options.removeAttribute("hidden")
    } else {
        options.setAttribute("hidden", "true")
    }

    type.addEventListener("change", e => {
        if(type.value === "select"){
            options.removeAttribute("hidden")
        } else {
            options.setAttribute("hidden", "true")
        }
    })

})