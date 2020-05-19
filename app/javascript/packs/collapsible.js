
let collapsibles = document.querySelectorAll(".collapsible")

collapsibles.forEach(collapsible => {
    let controls = collapsible.querySelector(".collapsible__header")
    let content = collapsible.querySelector(".collapsible__content")

    let key = `collapsible_${collapsible.id}`

    const close = () => {
        controls.setAttribute("aria-expanded", "false")
        content.setAttribute("hidden", "true")
        window.localStorage.setItem(key, false)
    }
    console.log("fuck")

    const open = () => {
        controls.setAttribute("aria-expanded", "true")
        content.removeAttribute("hidden")
        window.localStorage.setItem(key, true)
    }

    window.localStorage.getItem(key) === "true" && open()
    window.localStorage.getItem(key) === "false" && close()

    controls.addEventListener("click", e => {
        e.preventDefault()
        controls.getAttribute("aria-expanded") === "false" ? open() : close()
    })
})