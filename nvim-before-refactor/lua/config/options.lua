-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.g.mapleader = " "
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.scriptencoding = "utf-8"

vim.opt.number = true

vim.o.termguicolors = true

vim.opt.iskeyword:append("-") -- Append word when delete or select hello-Hello <- will select all these words
vim.opt.iskeyword:append("_") -- Append word when delete or select hello-Hello <- will select all these words

vim.opt.title = true
vim.opt.autoindent = true
vim.g.autoformat = false -- autoformat
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 0 -- change from 2
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.inccommand = "split"
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
-- vim.opt.wrap = false -- No Wrap lines
vim.opt.wrap = true -- Wrap lines
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"
-- vim.opt.mouse = "" -- Disable mouse

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

vim.cmd([[au BufNewFile,BufRead *.astro setf astro]])
vim.cmd([[au BufNewFile,BufRead Podfile setf ruby]])

-- if vim.fn.has("nvim-0.8") == 1 then
--   vim.opt.cmdheight = 0
-- end

-- ╭─────────────────────────────────────────────────────────╮
-- │ Todo Comment                                            │
-- ╰─────────────────────────────────────────────────────────╯
-- NOTE:
-- PERF:
-- HACK:
-- TODO:
-- WARN:
-- FIX:
-- BUG:
-- FIXIT:
-- ISSUE:
-- WARNING:
-- TEST:
--

-- if vim.g.neovide then
--   -- local alpha = function()
--   --   return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
--   -- end
--
--   -- vim.g.neovide_transparency = 0.0
--   vim.g.transparency = 0.75
--   -- vim.g.neovide_background_color = "#041319" .. alpha()
--   vim.g.neovide_floating_blur_amount_x = 25.0
--   vim.g.neovide_floating_blur_amount_y = 25.0
--   vim.g.neovide_window_blurred = true
--   vim.g.neovide_show_border = false
--
--   vim.g.neovide_floating_shadow = true
--   vim.g.neovide_floating_z_height = 10
--   vim.g.neovide_light_angle_degrees = 45
--   vim.g.neovide_light_radius = 5
--
--   vim.opt.guifont = "ComicShannsMono Nerd Font:h18"
--   vim.g.set_encoding = "utf-8"
--   vim.opt.linespace = 0
--   vim.g.neovide_scale_factor = 1.0
--
--   vim.g.neovide_padding_top = 0
--   vim.g.neovide_padding_bottom = 0
--   vim.g.neovide_padding_right = 0
--   vim.g.neovide_padding_left = 0
--
--   vim.g.neovide_scroll_animation_length = 0.3
--   vim.g.neovide_hide_mouse_when_typing = true
--   vim.g.neovide_underline_automatic_scaling = false
--
--   -- vim.g.neovide_theme = "wombat"
--   vim.g.neovide_theme = "auto"
--
--   vim.g.neovide_refresh_rate = 60 -- 60 or 120
--   vim.g.neovide_refresh_rate_idle = 5
--   vim.g.neovide_no_idle = true
--   vim.g.neovide_confirm_quit = true
--   -- vim.g.neovide_fullscreen = true
--   vim.g.neovide_remember_window_size = true
--   -- vim.g.neovide_cursor_animation_length = 0.13
--   vim.g.neovide_cursor_trail_size = 0.7 -- Default is 0.8
--   vim.g.neovide_cursor_antialiasing = true
--   vim.g.neovide_cursor_animate_in_insert_mode = true
--   vim.g.neovide_cursor_animate_command_line = true
--   vim.g.neovide_cursor_unfocused_outline_width = 0.125
--
--   vim.g.neovide_cursor_smooth_blink = true
--
--   -- g.neovide_cursor_vfx_mode = "railgun"
--   -- g.neovide_cursor_vfx_mode = "torpedo"
--   vim.g.neovide_cursor_vfx_mode = "pixiedust"
--   -- g.neovide_cursor_vfx_mode = "sonicboom"
--   -- g.neovide_cursor_vfx_mode = "ripple"
--   -- g.neovide_cursor_vfx_mode = "wireframe"
--   --
--   vim.g.neovide_cursor_vfx_opacity = 200.0
--   vim.g.neovide_cursor_vfx_particle_lifetime = 2.5 -- Default is 1.2
--   vim.g.neovide_cursor_vfx_particle_density = 25.0 -- Default is 7.0
--   vim.g.neovide_cursor_vfx_particle_speed = 10.0 -- Default is 10.0
--
--   -- g.neovide_cursor_vfx_particle_phase = 1.5 -- Only for the railgun vfx mode.
--   -- g.neovide_cursor_vfx_particle_curl = 1.0 -- Only for the railgun vfx mode.
-- end
