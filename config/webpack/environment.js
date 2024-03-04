const { environment } = require("@rails/webpacker");
const webpack = require("webpack");

environment.plugins.prepend(
  "Environment",
  new webpack.EnvironmentPlugin(["GOOGLE_CLIENT_KEY"])
);

module.exports = environment;
