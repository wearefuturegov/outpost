// when service providers make services they save locations then open schedules but admins dont
// so we need to sync the schedules with the locations for admins

const adminLocationScheduleSync = () => {
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
      if (!location.hasOwnProperty("id")) {
        locationNames.push({
          key: key,
          value:
            location.name ||
            location.address_1 ||
            location.postal_code ||
            "No location name provided",
        });
      }
    }

    console.log(locationNames);

    return locationNames;
  };

  const addLocationToScheduleDropdown = () => {
    let locationNames = getAllLocationNames();
    const scheduleLocationDropdowns = document.querySelectorAll(
      '[name^="service[regular_schedules_attributes]"][name$="[service_at_location_id]"]'
    );

    scheduleLocationDropdowns.forEach((dropdown) => {
      const existingOptions = [];
      for (let i = 0; i < dropdown.options.length; i++) {
        existingOptions.push(parseInt(dropdown.options[i].value));
      }

      console.log(existingOptions);
      locationNames.forEach((location) => {
        console.log(location.key);
        console.log(existingOptions.includes(location.key));
        if (!existingOptions.includes(location.key)) {
          const option = document.createElement("option");
          option.value = location.key;
          option.textContent = location.value;
          dropdown.appendChild(option);
        }
      });
    });
  };

  document.addEventListener("itemAdded", (e) => {
    console.log(
      e.detail.association,
      "repeater created for",
      e.detail.object_id
    );

    const object_id = e.detail.object_id;
    const association = e.detail.association;

    if (association === "locations") {
      // setup event listeners for the location name
      // const field_name = document.getElementById(`${field_prefix}_name`);
      // const field_address_1 = document.getElementById(
      //   `${field_prefix}_address_1`
      // );
      // const field_postal_code = document.getElementById(
      //   `${field_prefix}_postal_code`
      // );
      // field_name.addEventListener("keyup", () => {
      //   name = field_name.value;
      //   locationName = setLocationName(name, address_1, postal_code);
      // });
      // field_address_1.addEventListener("keyup", () => {
      //   address_1 = field_address_1.value;
      //   locationName = setLocationName(name, address_1, postal_code);
      // });
      // field_postal_code.addEventListener("keyup", () => {
      //   postal_code = field_postal_code.value;
      //   locationName = setLocationName(name, address_1, postal_code);
      // });
      // add entry to the schedule location dropdown
      addLocationToScheduleDropdown();
    }

    if (association === "regular_schedules") {
      // make sure schedule locagtion dropdown includes the new locations
    }

    // const field_prefix = `service_locations_attributes_${object_id}`;

    // const field_name = document.getElementById(`${field_prefix}_name`);
    // const field_address_1 = document.getElementById(
    //   `${field_prefix}_address_1`
    // );
    // const field_postal_code = document.getElementById(
    //   `${field_prefix}_postal_code`
    // );

    // let locationName, name, address_1, postal_code;
    // field_name.addEventListener("keyup", () => {
    //   name = field_name.value;
    //   locationName = setLocationName(name, address_1, postal_code);
    // });
    // field_address_1.addEventListener("keyup", () => {
    //   address_1 = field_address_1.value;
    //   locationName = setLocationName(name, address_1, postal_code);
    // });
    // field_postal_code.addEventListener("keyup", () => {
    //   postal_code = field_postal_code.value;
    //   locationName = setLocationName(name, address_1, postal_code);
    // });

    // console.log(locationName);

    // console.log(document.getElementById(`${field_prefix}_name`).value);
    // console.log(document.getElementById(`${field_prefix}_address_1`).value);
    // console.log(document.getElementById(`${field_prefix}_postal_code`).value);
    // Add any other reactions to the item being added here

    //name service_locations_attributes_1718976864886_name
    //street address service_locations_attributes_1718976864886_address_1
    // town or area service_locations_attributes_1718976864886_city
    // postcode service_locations_attributes_1718976864886_postal_code
  });

  // const setLocationName = (name, address_1, postal_code) => {
  //   return name || address_1 || postal_code;
  // };
};

adminLocationScheduleSync();
