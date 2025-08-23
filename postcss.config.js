module.exports = {
  syntax: "postcss-scss",
  plugins: [
    require("@csstools/postcss-sass"),
    require("postcss-import"),
    require("postcss-nesting"),
    require("autoprefixer"),
    require("postcss-flexbugs-fixes"),
    require("postcss-preset-env")({
      autoprefixer: {
        flexbox: "no-2009",
      },
      stage: 3,
    }),
  ],
};
