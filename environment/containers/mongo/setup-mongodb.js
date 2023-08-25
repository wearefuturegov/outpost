db = db.getSiblingDB("outpost_api")

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
