db = db.getSiblingDB("outpost_api_development")

db.createCollection("indexed_services")

db.indexed_services.createIndex(
  {
    name: "text",
    description: "text",
  },
  {
    weights: {
      name: 5,
      description: 1,
    },
  }
)
db.indexed_services.createIndex({
  "locations.geometry": "2dsphere",
})
db.indexed_services.createIndex({
  "taxonomies.slug": 1,
})

db.indexed_services.insertMany([
  {
    id: 1,
    updated_at: {
      $date: "2022-07-01T20:14:55.847Z",
    },
    name: "Ligula Mattis Dolor",
    description:
      "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.",
    url: "http://outpost-platform.wearefuturegov.com/",
    min_age: 0,
    max_age: 100,
    age_band_under_2: null,
    age_band_2: null,
    age_band_3_4: null,
    age_band_5_7: null,
    age_band_8_plus: null,
    age_band_all: null,
    needs_referral: true,
    free: null,
    created_at: {
      $date: "2022-07-01T20:14:54.546Z",
    },
    status: "published",
    target_directories: [],
    locations: [
      {
        id: 1,
        name: "Location 1",
        address_1: null,
        city: "London",
        state_province: "",
        postal_code: "EC1",
        country: "GB",
        geometry: {
          type: "Point",
          coordinates: [-0.2664017, 51.5285262],
        },
        mask_exact_address: true,
        accessibilities: [],
      },
    ],
    contacts: [],
    meta: [],
    organisation: {
      id: 1,
      name: "Organisation 1",
      description: null,
      email: null,
      url: null,
    },
    taxonomies: [
      {
        id: 1,
        name: "Taxonomy 1",
        slug: "taxonomy-1",
        parent_id: null,
      },
    ],
    regular_schedules: [],
    cost_options: [],
    links: [
      {
        label: "Facebook",
        url: "https://www.facebook.com",
      },
    ],
    send_needs: [],
    suitabilities: [],
    local_offer: null,
  },
])
