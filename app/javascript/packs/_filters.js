let allFilters = document.querySelectorAll("[data-autosubmit]")

allFilters.forEach(filter => {
    filter.addEventListener("change", () => {
        console.log(filter)
        filter.form.submit()
    })
})