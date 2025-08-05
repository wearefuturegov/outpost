let allTabs = document.querySelectorAll(".tabs")

allTabs.forEach(tabs => {
    let controls = tabs.querySelectorAll(".tabs__nav-link")
    let panels = tabs.querySelectorAll(".tabs__panel")

    controls.forEach((control, i) => {

        if(i === 0){
            controls[i].setAttribute("aria-selected", "true")
        } else {
            controls[i].setAttribute("aria-selected", "false")
            panels[i].setAttribute("hidden", "true")
        }

        control.addEventListener("click", e => {
            e.preventDefault()
    
            controls.forEach(c => c.removeAttribute("aria-selected"))
            panels.forEach(p => p.setAttribute("hidden", "true"))
    
            control.setAttribute("aria-selected", "true")
            panels[i].removeAttribute("hidden")
        })

    })
})