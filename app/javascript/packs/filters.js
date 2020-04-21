let allFilters = document.querySelectorAll(".filters")

allFilters.forEach(filters => {

    let control = filters.querySelector(".filters__control")
    let body = filters.querySelector(".filters__body")
    let form = filters.querySelector(".filters__form")

    control.addEventListener("click", () => {
        if(control.getAttribute("aria-expanded") === "true"){
            body.setAttribute("hidden", "true")
            control.setAttribute("aria-expanded", "false")
            control.innerHTML = "Filters"
        } else {
            body.removeAttribute("hidden")
            control.setAttribute("aria-expanded", "true")
            control.innerHTML = "Close filters"
        }
    })

    form.addEventListener("change", () => {
        form.submit()
    })

})