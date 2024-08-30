// @TODO for some reason when theres multiple location boxes the dropdowns aren't being added correctly - they all end up in te last boc and they shouldn't!

// when service providers make services they save locations then open schedules but admins dont
// so we need to sync the schedules with the locations for admins
document.addEventListener("DOMContentLoaded", () => {
  const adminLocationScheduleSync = () => {
    /**
     * Gets all the location names, uses the same formatting logic as elsewhere in the code base
     * @returns {Array} An array of objects containing the location service_at_location_id and name
     */
    const getAllLocationNames = () => {
      const location_fields = document.querySelectorAll(
        '[name^="service[locations_attributes]"]'
      );

      const locations = {};
      const locationNames = [];
      location_fields.forEach((element) => {
        const matches = element.name.match(
          /^service\[locations_attributes\]\[(\d+)\]\[(\w+)\]$/
        );
        if (matches) {
          const [, id, attribute] = matches;
          if (!locations[id]) {
            locations[id] = {};
          }
          locations[id][attribute] = element.value;
        }
      });

      for (const [key, location] of Object.entries(locations)) {
        if (location._destroy !== "true") {
          locationNames.push({
            service_at_location_id: location.service_at_location_id,
            location_object_id: location.location_object_id,
            value:
              location.name ||
              location.address_1 ||
              location.postal_code ||
              "No location name provided",
          });
        }
      }
      return locationNames;
    };

    /**
     * Updates the schedule location dropdowns with the new locations - leaves any with value="" alone (eg "All Locations")
     */
    const updateScheduleDropdownWithNewLocations = () => {
      let createOption = (key, value, location_object_id) => {
        const option = document.createElement("option");
        option.value = key;
        option.textContent = value;
        if (location_object_id !== undefined) {
          option.dataset.locationObjectId = location_object_id;
        }
        return option;
      };
      let locationNames = getAllLocationNames();
      const scheduleLocationDropdowns = document.querySelectorAll(
        '[name^="service[regular_schedules_attributes]"][name$="[service_at_location_id]"]'
      );

      console.log(scheduleLocationDropdowns);
      const newOptions = locationNames.map((location) => {
        return createOption(
          location.service_at_location_id ?? "",
          location.value,
          location.location_object_id
        );
      });

      const updateDropdown = (dropdown, i) => {
        console.log("Drowndown", dropdown);

        var titleOption = Array.from(dropdown.options).find(
          (o) => o.innerHTML === "All locations" && o.value === ""
        );

        console.log("title option", titleOption);

        const selectedOption = Array.from(dropdown.options).find(
          (option) => option.selected && option.innerHTML !== "All locations"
        );

        const selectedOptionValues = {
          service_at_location_id: selectedOption?.value,
          location_object_id: selectedOption?.dataset.locationObjectId,
        };

        console.log("selected option", selectedOption, selectedOptionValues);

        console.log("new options", newOptions);
        dropdown.innerHTML = "";
        [titleOption, ...newOptions].forEach((option) => {
          console.log(option);
          if (
            option.dataset.locationObjectId ===
              selectedOptionValues.location_object_id ||
            option.value === selectedOptionValues.service_at_location_id
          ) {
            option.selected = true;
          }
          dropdown.appendChild(option);
        });

        // const reSelectOption = Array.from(dropdown.options).findIndex(
        //   (option) => {
        //     console.log(option);

        //     return (
        //       (option.dataset.locationObjectId !== undefined &&
        //         option.dataset.locationObjectId ===
        //           selectedOptionValues.location_object_id &&
        //         option.value.length === 0) ||
        //       (option.value.length > 0 &&
        //         option.value === selectedOptionValues.service_at_location_id &&
        //         option.dataset.locationObjectId === undefined)
        //     );
        //   }
        // );

        // console.log("Reselect option", reSelectOption);
        // dropdown.selectedIndex = reSelectOption === -1 ? 0 : reSelectOption;

        // dropdown.selectedIndex = selectedOption ? dropdown.selectedIndex : 0;

        console.log("-----");

        // const selectedOption = Array.from(dropdown.options).some(
        //   (option) => {
        //       // option.value === selectedOption
        //       console.log(option.selected)
        //       option.selected
        //   }
        // )
        //   ? dropdown.value
        //   : "";

        //   console.log("selected option": selectedOption);
        // var optionsWithNoValue = Array.from(dropdown.options).filter(
        //   (o) => o.innerHTML === "All locations" && o.value === ""
        // );
        // dropdown.innerHTML = "";
        // [...optionsWithNoValue, ...newOptions].forEach((option) => {
        //   dropdown.appendChild(option);
        // });
        // dropdown.value = Array.from(dropdown.options).find((o) => o.selected)
        //   ? selectedOption
        //   : "";
      };

      [...scheduleLocationDropdowns].forEach(updateDropdown);

      // scheduleLocationDropdowns.forEach((dropdown) => {
      //   const selectedOption = Array.from(dropdown.options).some(
      //     (option) => option.value === selectedOption
      //   )
      //     ? dropdown.value
      //     : "";
      //   var optionsWithNoValue = Array.from(dropdown.options).filter(
      //     (o) => o.innerHTML === "All locations" && o.value === ""
      //   );
      //   dropdown.innerHTML = "";
      //   [...optionsWithNoValue, ...newOptions].forEach((option) => {
      //     dropdown.appendChild(option);
      //   });
      //   dropdown.value = Array.from(dropdown.options).find((o) => o.selected)
      //     ? selectedOption
      //     : "";
      // });
    };

    /**
     * Updates the schedule location object id when location is selected in dropdown
     */
    const updateScheduleLocationObjectId = (e) => {
      const value = e.target.value;
      const selectedIndex = e.target.selectedIndex;
      const location_object_id_field = e.target.parentNode.querySelector(
        '[name$="[location_object_id]"]'
      );
      if (!value && selectedIndex !== 0) {
        const locationObjectId =
          e.target[selectedIndex].dataset.locationObjectId;
        if (locationObjectId) {
          location_object_id_field.value = locationObjectId;
        }
      } else {
        location_object_id_field.value = "";
      }
    };

    /**
     * When a + new location button is clicked, update the schedule dropdowns with the new data
     */
    document.addEventListener("itemAdded", (e) => {
      const association = e.detail.association;

      if (association === "locations" || association === "regular_schedules") {
        updateScheduleDropdownWithNewLocations();
      }
    });

    /** When any location field is updated, update the schedule dropdowns with the new data */
    const locationsEditor = document.getElementById("locations-editor");

    locationsEditor.addEventListener("keyup", function (event) {
      const locationNameField = event.target.name.match(
        /^service\[locations_attributes\]\[(\d+)\]\[(name|address_1|city|postal_code)\]$/
      );
      if (locationNameField) {
        updateScheduleDropdownWithNewLocations();
      }
    });

    /** When a location is deleted */
    locationsEditor.addEventListener("click", function (event) {
      if (event.target.getAttribute("data-close")) {
        updateScheduleDropdownWithNewLocations();
      }
    });

    /** When regular schedule box chooses a location */
    const scheduleEditor = document.getElementById("schedule-editor");

    scheduleEditor.addEventListener("change", function (event) {
      const locationNameField = event.target.name.match(
        /^service\[regular_schedules_attributes\]\[(\d+)\]\[(service_at_location_id)\]$/
      );
      if (locationNameField) {
        updateScheduleLocationObjectId(event);
      }
    });

    /** on page load */
    updateScheduleDropdownWithNewLocations();
  };

  adminLocationScheduleSync();
});
