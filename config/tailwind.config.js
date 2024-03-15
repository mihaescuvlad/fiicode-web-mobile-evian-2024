const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/views/**/*.html.erb",
    "./app/views/**/*.html.haml",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        primary: {
          50: "rgb(209, 250, 229)",
          100: "rgb(167, 243, 208)",
          200: "rgb(110, 231, 183)",
          300: "rgb(52, 211, 153)",
          400: "rgb(16, 185, 129)",
          500: "rgb(5, 150, 105)",
          600: "rgb(4, 120, 87)",
          700: "rgb(6, 95, 70)",
          800: "rgb(6, 78, 59)",
          900: "rgb(2, 44, 34)",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
