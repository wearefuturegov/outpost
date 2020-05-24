const closeAll = document.querySelector("[data-close-all]")
let collapsibles = document.querySelectorAll(".collapsible")

if(closeAll){
    closeAll.addEventListener("click", () => {
        collapsibles.forEach(collapsible => {
            let controls = collapsible.querySelector(".collapsible__header")
            let content = collapsible.querySelector(".collapsible__content")
        
            let key = `collapsible_${collapsible.id}`
        
            controls.setAttribute("aria-expanded", "false")
            content.setAttribute("hidden", "true")
            window.localStorage.setItem(key, false)
        })
    })
}

