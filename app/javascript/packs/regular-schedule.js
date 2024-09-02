document.addEventListener("DOMContentLoaded", () => {
  let regularSchedules = document.querySelector(
    "#regular_schedule_panels.repeater"
  );

  // listens for every change event inside the repeater
  regularSchedules.addEventListener("change", (e) => {
    // the panel object
    const panel = e.target.closest("[data-regular-schedule-panel]");

    // if the change event is on the time_type radio button
    const TimeTypeRadio = e.target.name.match(
      /^service\[regular_schedules_attributes\]\[(\d+)\]\[(time_type)\]$/
    );
    if (TimeTypeRadio) {
      const selectedRadio = document.querySelector(
        `input[name="${e.target.name}"]:checked`
      );
      ToggleTimeType(selectedRadio.value, panel);
    }
  });
});

/**
 * Toggles the visibility of the opening_time and event_time selections
 * @param {*} selected
 * @param {*} panel
 */
const ToggleTimeType = (selected, panel) => {
  const opening_time = panel.querySelector(".regular_schedule__opening_time");
  const event_time = panel.querySelector(".regular_schedule__event_time");

  if (selected === "opening_time") {
    opening_time.removeAttribute("hidden");
    event_time.setAttribute("hidden", true);
  } else if (selected === "event_time") {
    opening_time.setAttribute("hidden", true);
    event_time.removeAttribute("hidden");
  }
};
