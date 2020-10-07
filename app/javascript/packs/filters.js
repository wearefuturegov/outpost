let allFilters = document.querySelectorAll(".filters")

allFilters.forEach(filters => {

    let form = filters.querySelector(".filters__form")

    form.addEventListener("change", () => {
        form.submit()
    })

})