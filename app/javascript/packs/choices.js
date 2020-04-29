import Choices from "choices.js"

let inputs = document.querySelectorAll("[data-choices]")


inputs.forEach(input => {
    let choices = new Choices(input)
})