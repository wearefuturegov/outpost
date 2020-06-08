const field = document.querySelector("[data-word-count]")

if(field){
    const input = field.querySelector(".field__input")
    const counter = field.querySelector(".field__word-counter")

    const updateCounter = value => {
        let count = value.split(" ").filter(String).length
        count > 30 ? counter.classList.add("field__word-counter--warn") : counter.classList.remove("field__word-counter--warn")
        counter.innerText = count === 1 ? `${count} word` : `${count} words`
    }

    updateCounter(input.value)

    input.addEventListener("keydown", e => {
        updateCounter(e.target.value)
    }) 
    input.addEventListener("change", e => {
        updateCounter(e.target.value)
    }) 
}