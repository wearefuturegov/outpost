let snapshots = document.querySelector(".snapshots")

if(snapshots){
    let controls = snapshots.querySelectorAll(".snapshots-tree__snapshot")
    let panels = snapshots.querySelectorAll(".snapshot-preview")
    
    // panels.forEach(panel => panel.setAttribute("hidden", "true"))
    // controls.forEach(control => control.setAttribute("aria-selected", "false"))
    
    controls.forEach((control, i) => control.addEventListener("click", e => {
        e.preventDefault()
    
        controls.forEach(c => c.removeAttribute("aria-selected"))
        panels.forEach(p => p.setAttribute("hidden", "true"))
    
        control.setAttribute("aria-selected", "true")
        panels[i].removeAttribute("hidden")
    }))
}

