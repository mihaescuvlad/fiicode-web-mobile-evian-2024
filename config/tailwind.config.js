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
          50: "#f2f8ff",
          100: "#d6e4ff",
          200: "#a6c8ff",
          300: "#79abff",
          400: "#4d8eff",
          500: "#266bff",
          600: "#1d53cc",
          700: "#163e99",
          800: "#102966",
          900: "#0a1533",
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
