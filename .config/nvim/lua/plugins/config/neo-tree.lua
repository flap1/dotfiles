require("neo-tree").setup {
  close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "ﰊ",
      -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
      -- then these will never be used.
      default = "*",
      highlight = "NeoTreeFileIcon"
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },
    git_status = {
      symbols = {
        -- Change type
        added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted   = "✖",-- this can only be used in the git_status source
        renamed   = "",-- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored   = "",
        unstaged  = "",
        staged    = "",
        conflict  = "",
      },
      highlight = "NeoTreeDimText", -- if you remove this the status will be colorful
    },
  },
  event_handlers = {
    {
      event = "file_opened",
      handler = function(file_path)
        --auto close
        require("neo-tree").close_all()
      end,
    },
    {
      event = "file_added",
      handler = function(file_path)
        require("neo-tree.utils").open_file({}, file_path)
      end,
    },
  },
  filesystem = {
    find_by_full_path_words = true,
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = {
        "node_modules"
      },
      never_show = { -- remains hidden even if visible is toggled to true
        ".DS_Store",
        "thumbs.db"
      },
    },
    follow_current_file = false, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    use_libuv_file_watcher = false, -- This will use the OS level file watchers
    -- to detect changes instead of relying on nvim autocmd events.
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_split",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    window = {
      position = "left",
      width = 40,
      mappings = {
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["I"] = "toggle_gitignore",
        ["R"] = "refresh",
        ["/"] = "fuzzy_finder",
        ["D"] = "fuzzy_finder_directory",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["d"] = "delete",
        ["y"] = "copy_to_clipboard",
        ["a"] = {"add", config = {show_path = "absolute"}},
        ["A"] = {"add_directory", config = {show_path = "absolute"}},
        ["r"] = "rename",
        ["c"] = {"copy", config = {show_path = "absolute"}},
        ["m"] = {"move", config = {show_path = "absolute"}},
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["q"] = "close_window",
      },
    },
  },
  buffers = {
    show_unloaded = true,
    window = {
      position = "left",
      mappings = {
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["a"] = {"add", config = {show_path = "absolute"}},
        ["A"] = {"add_directory", config = {show_path = "absolute"}},
        ["c"] = {"copy", config = {show_path = "absolute"}},
        ["m"] = {"move", config = {show_path = "absolute"}},
        ["r"] = "rename",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["o"] = "system_open",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["R"] = "refresh",
        ["d"] = "delete",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["bd"] = "buffer_delete",
      },
    },
  },
  git_status = {
    window = {
      position = "float",
      mappings = {
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["o"] = "system_open",
        ["C"] = "close_node",
        ["R"] = "refresh",
        ["d"] = "delete",
        ["r"] = "rename",
        ["c"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["A"] = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      },
    },
  },
  renderers = {
    directory = {
      { "indent" },
      { "icon" },
      { "current_filter" },
      { "name" },
      { "clipboard" },
      { "diagnostics", errors_only = true },
    },
    file = {
      { "indent" },
      { "icon" },
      {
        "name",
        use_git_status_colors = true,
        zindex = 10,
      },
      { "clipboard" },
      { "bufnr" },
      { "modified" },
      { "diagnostics" },
      { "git_status" },
    },
  },
}

vim.keymap.set("n", "<C-n>", ":NeoTreeRevealToggle<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "G,", ":NeoTreeFloatToggle git_status<CR>", { noremap = true, silent = true })


