let allTabs = document.querySelectorAll(".tabs")

allTabs.forEach(tabs => {
    let controls = tabs.querySelectorAll(".tabs__nav-link")
    let panels = tabs.querySelectorAll(".tabs__panel")

    controls.forEach((control, i) => control.addEventListener("click", e => {
        e.preventDefault()

        controls.forEach(c => c.removeAttribute("aria-selected"))
        panels.forEach(p => p.setAttribute("hidden", "true"))

        control.setAttribute("aria-selected", "true")
        panels[i].removeAttribute("hidden")
    }))
})