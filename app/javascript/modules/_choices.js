import Choices from "choices.js";

document.addEventListener("turbolinks:load", () => {
  let inputs = document.querySelectorAll("[data-choices]");

  inputs.forEach((input) => {
    let choices = new Choices(input);
  });
});
