return {
  "mistricky/codesnap.nvim",
  build = "make build_generator",
  event = "VeryLazy",
  enabled = false,
  opts = {
    mac_window_bar = true,
    -- title = "CodeSnap.nvim",
    title = "Teerapat Wassavanich (PAT)",
    code_font_family = "ComicShannsMono Nerd Font",
    save_path = "~/Desktop",
    has_breadcrumbs = true,
    -- bg_theme = "bamboo",
    -- bg_theme = "dusk",
    -- bg_color = "#001419",
    show_workspace = true,
    -- breadcrumbs_separator = "👉"
    has_line_number = true,
    -- bg_x_padding = 122,
    -- bg_y_padding = 82,
    -- bg_padding = nil
    watermark = "Teerapat Wassavanich (PAT) Email: teerapat@1moby.com",
    -- watermark_font_family = "Pacifico",
    -- watermark_font_family = "ComicShannsMono Nerd Font",
    watermark_font_family = "CaskaydiaCove Nerd Font",
  },
}
