-- Per-directory nvim sessions. tmux-resurrect relaunches a bare `nvim` in each
-- pane's directory; auto-session then restores that directory's buffers and
-- splits (nvim started with no file args auto-restores, and saves on exit).
return {
  "rmagatti/auto-session",
  lazy = false,
  init = function()
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
  end,
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { "~/", "~/Downloads", "/" },
  },
}
