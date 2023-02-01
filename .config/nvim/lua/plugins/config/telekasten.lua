local home = vim.fn.stdpath("data") .. "/zettelkasten"
local templ_dir = vim.fn.stdpath("config") .. "/zettelkasten/templates"
require("telekasten").setup({
  home = home,
  dailies = home .. "/" .. "daily",
  weeklies = home .. "/" .. "weekly",
  templates = templ_dir,
  extension = ".md",

  -- following a link to a non-existing note will create it
  follow_creates_nonexisting = true,
  dailies_create_nonexisting = true,
  weeklies_create_nonexisting = true,

  -- template for new notes (newNote, follow_link)
  template_new_note = templ_dir .. "/new_note.md",

  -- template for newly created daily notes (goto_today)
  template_new_daily = templ_dir .. "/daily.md",

  -- template for newly created weekly notes (goto_thisweek)
  template_new_weekly = templ_dir .. "/weekly.md",

  image_link_style = "markdown",

  -- image (sub)dir for pasting
  -- dir name (absolute path or subdir name)
  -- or nil if pasted images shouldn't go into a special subdir
  image_subdir = "img",

  -- Generate note filenames. One of:
  -- "title" (default) - Use title if supplied, uuid otherwise
  -- "uuid" - Use uuid
  -- "uuid-title" - Prefix title by uuid
  -- "title-uuid" - Suffix title with uuid
  new_note_filename = "uuid-title",
  -- file uuid type ("rand" or input for os.date()")
  uuid_type = "%Y-%m-%d", -- "%Y%m%d%H%M",
  -- UUID separator
  uuid_sep = "-", -- "-"

  -- default sort option: 'filename', 'modified'
  sort = "modified",

  -- integrate with calendar-vim
  plug_into_calendar = true,
  calendar_opts = {
    -- calendar week display mode: 1 .. 'WK01', 2 .. 'WK 1', 3 .. 'KW01', 4 .. 'KW 1', 5 .. '1'
    weeknm = 4,
    -- use monday as first day of week: 1 .. true, 0 .. false
    calendar_monday = 1,
    -- calendar mark: where to put mark for marked days: 'left', 'right', 'left-fit'
    calendar_mark = "left-fit",
  },

  -- telescope actions behavior
  close_after_yanking = true,
  insert_after_inserting = true,

  -- tag notation: '#tag', ':tag:', 'yaml-bare'
  tag_notation = "#tag",

  -- command palette theme: dropdown (window) or ivy (bottom panel)
  command_palette_theme = "dropdown",

  -- tag list theme:
  -- get_cursor: small tag list at cursor; ivy and dropdown like above
  show_tags_theme = "dropdown",

  -- when linking to a note in subdir/, create a [[subdir/title]] link
  -- instead of a [[title only]] link
  subdirs_in_links = true,

  -- template_handling
  -- What to do when creating a new note via `new_note()` or `follow_link()`
  -- to a non-existing note
  -- - prefer_new_note: use `new_note` template
  -- - smart: if day or week is detected in title, use daily / weekly templates (default)
  -- - always_ask: always ask before creating a note
  template_handling = "smart",

  -- path handling:
  --   this applies to:
  --     - new_note()
  --     - new_templated_note()
  --     - follow_link() to non-existing note
  --
  --   it does NOT apply to:
  --     - goto_today()
  --     - goto_thisweek()
  --
  --   Valid options:
  --     - smart: put daily-looking notes in daily, weekly-looking ones in weekly,
  --              all other ones in home, except for notes/with/subdirs/in/title.
  --              (default)
  --
  --     - prefer_home: put all notes in home except for goto_today(), goto_thisweek()
  --                    except for notes with subdirs/in/title.
  --
  --     - same_as_current: put all new notes in the dir of the current note if
  --                        present or else in home
  --                        except for notes/with/subdirs/in/title.
  new_note_location = "smart",

  -- should all links be updated when a file is renamed
  rename_update_links = true,
})

local opts = { noremap = true, silent = true }

local function vim_keymap_set_list(keymaps)
  for key, cmd in pairs(keymaps) do
    vim.keymap.set("n", "<Leader>z" .. key, cmd, opts)
    vim.keymap.set("n", "<M-z>" .. key, cmd, opts)
    vim.keymap.set("t", "<M-z>" .. key, "<C-\\><C-n>" .. cmd, opts)
    vim.keymap.set("i", "<M-z>" .. key, "<Esc>" .. cmd, opts)
  end
end

local keymaps = {
 ["f"] = "<Cmd>lua require('telekasten').find_notes()<CR>",
 ["d"] = "<Cmd>lua require('telekasten').find_daily_notes()<CR>",
 ["j"] = "<Cmd>lua require('telekasten').search_notes()<CR>",
 ["z"] = "<Cmd>lua require('telekasten').follow_link()<CR>",
 ["T"] = "<Cmd>lua require('telekasten').goto_today()<CR>",
 ["W"] = "<Cmd>lua require('telekasten').goto_thisweek()<CR>",
 ["w"] = "<Cmd>lua require('telekasten').find_weekly_notes()<CR>",
 ["n"] = "<Cmd>lua require('telekasten').new_note()<CR>",
 ["N"] = "<Cmd>lua require('telekasten').new_templated_note()<CR>",
 ["y"] = "<Cmd>lua require('telekasten').yank_notelink()<CR>",
 ["c"] = "<Cmd>lua require('telekasten').show_calendar()<CR>",
 ["C"] = "<Cmd>CalendarT<CR>",
 ["i"] = "<Cmd>lua require('telekasten').paste_img_and_link()<CR>",
 ["t"] = "<Cmd>lua require('telekasten').toggle_todo()<CR>",
 ["b"] = "<Cmd>lua require('telekasten').show_backlinks()<CR>",
 ["F"] = "<Cmd>lua require('telekasten').find_friends()<CR>",
 ["I"] = "<Cmd>lua require('telekasten').insert_img_link({ i=true })<CR>",
 ["p"] = "<Cmd>lua require('telekasten').preview_img()<CR>",
 ["m"] = "<Cmd>lua require('telekasten').browse_media()<CR>",
 ["a"] = "<Cmd>lua require('telekasten').show_tags()<CR>",
 ["#"] = "<Cmd>lua require('telekasten').show_tags()<CR>",
 ["r"] = "<Cmd>lua require('telekasten').rename_note()<CR>",
 [""] = "<Cmd>lua require('telekasten').panel()<CR>",
}
vim_keymap_set_list(keymaps)

