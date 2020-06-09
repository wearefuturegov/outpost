document.querySelectorAll("[data-taxonomies-select-all")
    .forEach(button => button.addEventListener("click", () => {
        button.parentElement
            .querySelectorAll("input[type='checkbox']")
            .forEach(checkbox => checkbox.checked = true)
    }))

document.querySelectorAll("[data-taxonomies-deselect-all")
    .forEach(button => button.addEventListener("click", () => {
        button.parentElement
            .querySelectorAll("input[type='checkbox']")
            .forEach(checkbox => checkbox.checked = false)
    }))