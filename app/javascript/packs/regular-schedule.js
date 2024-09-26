document.addEventListener("turbolinks:load", () => {
  // regular schedules
  setupTimeTypePanelListeners();
  const timeTypePanels = document.querySelectorAll(
    "[data-regular-schedule-panel]"
  );
  timeTypePanels.forEach((panel) => {
    setTimeTypePanelState(panel);
  });

  // regular schedules & locations (admin only)
  let locations = document.querySelector("#location_panels.repeater");
  if (locations) {
    setupRegularScheduleLocationListeners();

    runOnEachRegularSchedulePanel((panel) => {
      setRegularScheduleLocationState(panel);
    });
  }
});

/*************
 *
 *   REGULAR SCHEDULES
 *
 *************/

/**
 * Sets up event listeners inside the regular schedule panels
 */
const setupTimeTypePanelListeners = () => {
  let regularSchedules = document.querySelector(
    "#regular_schedule_panels.repeater"
  );

  // listens for every change event inside the regular schedules repeater
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
 *   REGULAR SCHEDULES & LOCATIONS
 *
 *************/

/**
 * Sets up event listeners inside the regular schedule panels
 */
const setupRegularScheduleLocationListeners = () => {
  let locations = document.querySelector("#location_panels.repeater");
  let regularSchedules = document.querySelector(
    "#regular_schedule_panels.repeater"
  );
  if (locations) {
    locations.addEventListener("click", (e) => {
      // add a location
      if (
        e.target.getAttribute("data-add") &&
        e.target.getAttribute("data-association") === "locations"
      ) {
        runOnEachRegularSchedulePanel((panel) => {
          setRegularScheduleLocationState(panel);
        });
      }

      // remove a location
      if (e.target.getAttribute("data-close")) {
        runOnEachRegularSchedulePanel((panel) => {
          setRegularScheduleLocationState(panel);
        });
      }
    });

    // update a location
    locations.addEventListener("change", (e) => {
      runOnEachRegularSchedulePanel((panel) => {
        setRegularScheduleLocationState(panel);
      });
    });
  }

  if (regularSchedules) {
    regularSchedules.addEventListener("click", (e) => {
      // add a regularSchedules
      if (
        e.target.getAttribute("data-add") &&
        e.target.getAttribute("data-association") === "regular_schedules"
      ) {
        runOnEachRegularSchedulePanel((panel) => {
          setRegularScheduleLocationState(panel);
        });
      }
    });

    // when regular schedule field changes
    regularSchedules.addEventListener("change", (e) => {
      // the panel object
      const panel = e.target.closest("[data-regular-schedule-panel]");
      const serviceAtLocationIdMatcher = e.target.name.match(
        /^service\[regular_schedules_attributes\]\[(\d+)\]\[(service_at_location_id)\]$/
      );

      if (serviceAtLocationIdMatcher) {
        updateScheduleLocationObjectId(e.target, panel);
      }
    });
  }
};

/**
 * Set location select visibility
 * @param {*} panel
 */
const setRegularScheduleLocationState = (panel) => {
  const locationNames = getAllLocationNames();

  // toggle visibility of location select
  if (locationNames.length <= 1) {
    toggleHidden(panel, true, "data-location");
  } else {
    toggleHidden(panel, false, "data-location");
  }

  // set dropdown state

  const dropdown = panel.querySelector('[name*="service_at_location_id"]');
  // get the 'title option' cant rely on it being the first option or it being the only blank option
  var titleOption = Array.from(dropdown.options).find(
    (o) => o.innerHTML === "All locations" && o.value === ""
  );
  // is there an option currently selected?
  const selectedOption = Array.from(dropdown.options).find(
    (option) => option.selected && option.innerHTML !== "All locations"
  );
  const selectedOptionValues = {
    service_at_location_id: selectedOption?.value,
    location_object_id: selectedOption?.dataset.locationObjectId,
  };
  // create new options based on the location names
  const newOptions = locationNames.map((location) => {
    return createOption(
      location.service_at_location_id ?? "",
      location.value,
      location.location_object_id
    );
  });
  // clear the dropdown options
  dropdown.innerHTML = "";
  // add them back in
  [titleOption, ...newOptions].forEach((option) => {
    dropdown.appendChild(option);
  });
  // and select the one that was already selected if it still exists
  const existingLocationOption = Array.from(
    dropdown.querySelectorAll(
      `option[value='${selectedOptionValues.service_at_location_id}']:not([data-location-object-id])`
    )
  ).find((option) => option.textContent.trim() !== "All locations");
  const newLocationOption = dropdown.querySelector(
    `option[value=''][data-location-object-id='${selectedOptionValues.location_object_id}']`
  );

  if (existingLocationOption) {
    existingLocationOption.selected = true;
  } else if (newLocationOption) {
    newLocationOption.selected = true;
  }
};

/**
 * Updates the schedule location object id when location is selected in dropdown
 * @param {*} panel
 */
const updateScheduleLocationObjectId = (locationSelector, panel) => {
  const value = locationSelector.value;
  const selectedIndex = locationSelector.selectedIndex;
  const selectedLocationObjectId =
    locationSelector[selectedIndex].dataset.locationObjectId;

  const location_object_id_field = panel.querySelector(
    '[name$="[location_object_id]"]'
  );

  // if we have selected a new location update the location_object_id_field
  if (!value && selectedLocationObjectId) {
    location_object_id_field.value = selectedLocationObjectId;
  } else {
    location_object_id_field.value = "";
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

/**
 * Gets all the location names, uses the same formatting logic as elsewhere in the code base
 * @returns {Array} An array of objects containing the location service_at_location_id and name
 */
const getAllLocationNames = () => {
  const location_data = [];
  runOnEachLocationPanel((panel) => {
    const destroy = panel.querySelector('[name*="_destroy"]').value;
    if (destroy !== "true") {
      const name = panel.querySelector('[name*="name"]').value;
      const address_1 = panel.querySelector('[name*="address_1"]').value;
      const city = panel.querySelector('[name*="city"]').value;
      const postal_code = panel.querySelector('[name*="postal_code"]').value;

      const panel_location_fields = {
        value: name || address_1 || postal_code || "No location name provided",
        location_object_id: panel.dataset.locationObjectId ?? null,
        service_at_location_id:
          panel.dataset.locationServiceAtLocationId ?? null,
      };
      location_data.push(panel_location_fields);
    }
  });

  return location_data;
};

/**
 * Callback method to run on each regular schedule panel
 * @param {*} callback
 */
const runOnEachRegularSchedulePanel = function (callback) {
  const regularSchedulePanels = document.querySelectorAll(
    "[data-regular-schedule-panel]"
  );
  regularSchedulePanels.forEach((panel) => {
    callback(panel);
  });
};

/**
 * Callback method to run on each location panel
 * @param {*} callback
 */
const runOnEachLocationPanel = function (callback) {
  const locationPanels = document.querySelectorAll("[data-location-panel]");
  locationPanels.forEach((panel) => {
    callback(panel);
  });
};

/**
 * Create an <option> element
 * @param {*} key
 * @param {*} value
 * @param {*} location_object_id
 * @returns
 */
const createOption = (key, value, location_object_id) => {
  const option = document.createElement("option");
  option.value = key;
  option.textContent = value;
  if (location_object_id !== null) {
    option.dataset.locationObjectId = location_object_id;
  }
  return option;
};
