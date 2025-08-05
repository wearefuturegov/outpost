document.addEventListener("trix-initialize", function (event) {
  if (wordCountEnabled(event.target)) {
    const [fieldset, field_id, editor, counter] = getUsefulElements(
      event.target
    );
    if (!counter) {
      const wordCounter = document.createElement("p");
      wordCounter.classList.add("field__word-counter");
      wordCounter.id = `${field_id}_trix_word-counter`;
      editor.after(wordCounter);
      updateCounter(event);
    }
  }
});

/**
 * Returns all the elements we're going to be working with for each instance of the editor
 * @param {*} target
 * @returns [fieldset, field_id, editor, counter]
 */
const getUsefulElements = (target) => {
  const fieldset = target.parentElement;
  const field_id = target.getAttribute("input");
  const editor = fieldset.querySelector(`trix-editor[input=${field_id}]`);
  const counter = fieldset.querySelector(`#${field_id}_trix_word-counter`);
  const wordLimit = fieldset.dataset.wordLimit ?? false;

  return [fieldset, field_id, editor, counter, wordLimit];
};

/**
 * Ensures actual true/false return if [data-word-count] set on surrounding field
 * @param {*} target
 * @returns Boolean
 */
const wordCountEnabled = (target) => {
  const [fieldset] = getUsefulElements(target);
  const hasWordCount = fieldset.dataset.wordCount;
  return hasWordCount == "true" ? true : false;
};

/**
 * Calculates the word number integer
 * @param {*} sentence
 * @returns Int
 */
const calculateWords = (sentence) => {
  return sentence.split(/\s+/).filter(String).length;
};

/**
 * Updates the inner text for the div to show the counter
 * @param {*} target
 * @param {*} count
 */
const updateCounterText = (target, count) => {
  target.innerText = count === 1 ? `${count} word` : `${count} words`;
};

/**
 * Responds to trix event listeners to pass information to the updateCounter method
 * @param {*} event
 */
const updateCounter = (event) => {
  if (event?.target) {
    if (wordCountEnabled(event.target)) {
      const [fieldset, field_id, editor, counter, wordLimit] =
        getUsefulElements(event.target);

      const wordCount = calculateWords(editor.editor.getDocument().toString());
      updateCounterText(counter, wordCount);

      if (wordLimit) {
        counter.classList.toggle(
          "field__word-counter--warn",
          wordCount > wordLimit
        );
      }
    }
  }
};

document.addEventListener("trix-change", updateCounter);
document.addEventListener("trix-focus", updateCounter);
document.addEventListener("trix-blur", updateCounter);
document.addEventListener("trix-paste", updateCounter);
