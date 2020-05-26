const editor = document.querySelector(".schedule-editor")

const update = checkbox => {
    let inputs = checkbox.parentNode.parentNode.parentNode.querySelectorAll("input[type='time']")
    if(checkbox.checked){
        inputs.forEach(input => input.removeAttribute("disabled"))
    } else {
        inputs.forEach(input => input.setAttribute("disabled", "true"))
    }
}

if(editor){
    let checkboxes = editor.querySelectorAll("input[type='checkbox']")
    checkboxes.forEach(checkbox => {
        update(checkbox)
        checkbox.addEventListener("click", () => {
            update(checkbox)
        })
    })
}