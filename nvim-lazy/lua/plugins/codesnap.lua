return {
  "mistricky/codesnap.nvim",
  build = "make build_generator",
  opts = {
    mac_window_bar = true,
    -- title = "CodeSnap.nvim",
    code_font_family = "ComicShannsMono Nerd Font Mono",
    save_path = "~/Desktop",
    has_breadcrumbs = true,
    -- bg_theme = "bamboo",
    bg_theme = "dusk",
    -- bg_color = "#001419",
    show_workspace = true,
    -- breadcrumbs_separator = "👉"
    has_line_number = true,
    -- bg_x_padding = 122,
    -- bg_y_padding = 82,
    -- bg_padding = nil
    watermark = "teerapat.was@techflow.asia",
    -- watermark_font_family = "Pacifico",
    watermark_font_family = "ComicShannsMono Nerd Font Mono",
  },
}
