document.addEventListener("turbolinks:load", () => {
  const clearVisibleFromToBtn = document.querySelector(
    "[data-clear-visible-from-to]"
  );

  if (clearVisibleFromToBtn) {
    clearVisibleFromToBtn.addEventListener("click", function () {
      document.querySelector('input[name="service[visible_from]"]').value = "";
      document.querySelector('input[name="service[visible_to]"]').value = "";
    });
  }
});
