const trigger = document.querySelector("[data-show-if-checked-trigger]")
const deTrigger = document.querySelector("[data-hide-if-checked-trigger]")
const result = document.querySelector("[data-show-if-checked-result]")

if(trigger && deTrigger && result){
    if(!trigger.checked) result.setAttribute("hidden", "true")

    trigger.addEventListener("change", e => {
        if(e.target.checked) result.removeAttribute("hidden")
    })

    deTrigger.addEventListener("change", e => {
        if(e.target.checked) result.setAttribute("hidden", "true")
    })

}