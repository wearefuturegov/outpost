document.addEventListener("turbolinks:load", () => {
  setupTimeTypePanelListeners();
  const timeTypePanels = document.querySelectorAll(
    "[data-regular-schedule-panel]"
  );
  timeTypePanels.forEach((panel) => {
    setTimeTypePanelState(panel);
  });
});

/**
 * Sets up event listeners inside the regular schedule panels
 */
const setupTimeTypePanelListeners = () => {
  let regularSchedules = document.querySelector(
    "#regular_schedule_panels.repeater"
  );

  // listens for every change event inside the repeater
  if (regularSchedules) {
    regularSchedules.addEventListener("change", (e) => {
      // the panel object
      const panel = e.target.closest("[data-regular-schedule-panel]");
      const timeTypeMatcher = e.target.name.match(
        /^service\[regular_schedules_attributes\]\[(\d+)\]\[(time_type)\]$/
      );
      const repeatMatcher = e.target.name.match(
        /^service\[regular_schedules_attributes\]\[(\d+)\]\[(repeats)\]$/
      );
      const freqMatcher = e.target.name.match(
        /^service\[regular_schedules_attributes\]\[(\d+)\]\[(freq)\]$/
      );

      if (timeTypeMatcher) {
        setTimeTypePanelState(panel);
      }

      if (repeatMatcher) {
        const repeat = e.target.checked;
        toggleRequired(panel, repeat, "data-required-repeat");
        toggleHidden(panel, !repeat, "data-repeats");
      }

      if (freqMatcher) {
        setFreqVisibility(panel, e.target.value);
      }
    });
  }
};

/**
 * Sets the correct state depending on the time type and selected options
 * @param {} panel
 */
const setTimeTypePanelState = (panel) => {
  const timeType = getPanelTimeType(panel);
  console.log(`setTimeTypePanelState to: ${timeType}`);

  const opening_time = panel.querySelector(".regular_schedule__opening_time");
  const event_time = panel.querySelector(".regular_schedule__event_time");

  const repeat = getRepeatState(panel);
  const freq = getFreqState(panel);
  setFreqVisibility(panel, freq);
  toggleHidden(panel, !repeat, "data-repeats");

  if (timeType === "opening_time") {
    // set opening time required fields
    toggleRequired(opening_time, true);
    // undo event time required fields
    toggleRequired(event_time, false);
    // remove required from repeat
    toggleRequired(panel, false, "data-required-repeat");
    // show opening time panel
    toggleHidden(panel, false, "data-opening-time");
    // hide event time panel
    toggleHidden(panel, true, "data-event-time");
  } else if (timeType === "event_time") {
    // set opening time required fields
    toggleRequired(opening_time, false);
    // set event time required fields
    toggleRequired(event_time, true);
    // if repeat checked add back in required if checked
    toggleRequired(panel, repeat, "data-required-repeat");
    // hide opening time panel
    toggleHidden(panel, true, "data-opening-time");
    // show event time panel
    toggleHidden(panel, false, "data-event-time");
  } else {
    // set it to opening time and re run this?
  }
};

/**
 * Sets visibility of the frequency fields
 * @param {*} panel
 */
const setFreqVisibility = (panel, freq) => {
  // toggle weekly and monthly visibility
  if (freq === "week") {
    toggleHidden(panel, false, "data-repeats-weekly");
    toggleHidden(panel, true, "data-repeats-monthly");
  } else if (freq === "month") {
    toggleHidden(panel, true, "data-repeats-weekly");
    toggleHidden(panel, false, "data-repeats-monthly");
  }
};

/*************
 *
 *   UTILITIES
 *
 *************/

/**
 * Get the type that the panel is set to rn
 * @param {*} panel
 * @returns
 */
const getPanelTimeType = (panel) => {
  const type = panel.querySelector('[name*="time_type"]:checked');
  return type.value;
};

/**
 * Gets the repeat state for current panel
 * @param {*} panel
 * @returns
 */
const getRepeatState = (panel) => {
  const repeat = panel.querySelector('[name*="repeat"]');
  return repeat.checked;
};

/**
 * Gets the freq state for current panel
 * @param {*} panel
 */
const getFreqState = (panel) => {
  const repeat = panel.querySelector('[name*="freq"]');
  return repeat.value;
};

/**
 * Toggles the hidden attribute of the panels
 * @param {*} panel
 * @param {*} hidden
 * @param {*} dataField
 */
const toggleHidden = (panel, hidden, dataField) => {
  const element = panel.querySelectorAll(`[${dataField}]`);
  // console.log("toggleHidden", panel, hidden, dataField, `[${dataField}]`);
  // console.log(element);

  element.forEach((elm) => {
    // console.log(elm, hidden);
    if (hidden) {
      elm.setAttribute("hidden", true);
    } else {
      elm.removeAttribute("hidden");
    }
  });
};

/**
 * Toggles the required attribute of the fields, optionally takes a different datafield
 * @param {*} panel
 * @param {*} required
 * @param {*} dataField
 */
const toggleRequired = (panel, required, dataField = "data-required") => {
  // console.log("ToggleRequired", required, dataField);
  // console.log(panel.querySelectorAll(`[${dataField}]`));
  panel.querySelectorAll(`[${dataField}]`).forEach((input) => {
    const inputField = input.querySelector("input");
    const selectField = input.querySelector("select");

    if (required) {
      input.classList.add("field--required");
      if (inputField) {
        inputField.setAttribute("required", true);
      }

      if (selectField) {
        selectField.setAttribute("required", true);
      }
    } else {
      input.classList.remove("field--required");
      if (inputField) {
        inputField.removeAttribute("required");
      }

      if (selectField) {
        selectField.removeAttribute("required");
      }
    }
  });
};
