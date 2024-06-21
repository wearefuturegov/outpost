db = db.getSiblingDB(
  process.env.MONGO_INITDB_DATABASE || "outpost_api_development"
);

db.createUser({
  user: process.env.MONGO_INITDB_USERNAME || "outpost",
  pwd: process.env.MONGO_INITDB_PASSWORD || "password",
  roles: [
    {
      role: "readWrite",
      db: process.env.MONGO_INITDB_DATABASE || "outpost_api_development",
    },
  ],
});

db.createCollection("indexed_services");

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
);
db.indexed_services.createIndex({
  "service_at_locations.location.geometry": "2dsphere",
});
db.indexed_services.createIndex({
  "taxonomies.slug": 1,
});
