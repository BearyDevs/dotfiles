return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      prettier = {
        -- By default, prettier uses double quotes.
        -- To use single quotes, we can add the `--single-quote` argument.
        -- This will make prettier use single quotes for all new code,
        -- and it will change existing double quotes to single quotes.
        -- It will leave existing single quotes as they are.
        prepend_args = { 
          "--single-quote",
          "--bracket-spacing=false",  -- Removes spaces in empty braces
        },
      },
    },
  },
}

