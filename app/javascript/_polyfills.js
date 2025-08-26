import "nodelist-foreach-polyfill";
import "polyfill-array-includes";
import "time-input-polyfill/auto";
import datasetPolyfill from "conglomerate-element-dataset";

datasetPolyfill();

// polyfill .remove()
if (!("remove" in Element.prototype)) {
  Element.prototype.remove = function () {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}

// to test these polyfills, you can use the following code snippets

// // nodelist-foreach-polyfill
// // Should not throw an error
// console.log(document.querySelectorAll("div").forEach(() => {}));

// // polyfill-array-includes
// // Should return true
// console.log([1, 2, 3].includes(2));

// // time-input-polyfill/auto
// // Add <input type="time"> to your HTML and check if it works in browsers that don't support it natively.

// // conglomerate-element-dataset
// // Should return the dataset object
// var el = document.createElement("div");
// el.setAttribute("data-test", "value");
// console.log(el.dataset.test); // Should log "value"

// // Element.prototype.remove
// var el = document.createElement("div");
// document.body.appendChild(el);
// el.remove(); // Should remove the element from the DOM without error
