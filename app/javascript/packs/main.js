import tabs from "./tabs"
import collapsible from "./collapsible"
import maps from "./maps"
import filters from "./filters"
import Choices from "choices.js"
import "choices.js/public/assets/styles/choices.min.css"

// enhanced select
if(document.querySelector(".enhanced-select")){
    const choices = new Choices(document.querySelector(".enhanced-select"))
}