return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true, -- Displays dotfiles (e.g., .gitignore, .github)
            ignored = true, -- Displays git-ignored items (e.g., .env, node_modules)
          },
        },
      },
      dashboard = {
        preset = {
          header = [[  .,-:::::     ...    :::::::-.    :::.         .-:::::'   ...     .-:::::'   ...     
,;;;'````'  .;;;;;;;.  ;;,   `';,  ;;`;;        ;;;'''' .;;;;;;;.  ;;;'''' .;;;;;;;.  
[[[        ,[[     \[[,`[[     [[ ,[[ '[[,      [[[,,==,[[     \[[,[[[,,==,[[     \[[,
$$$        $$$,     $$$ $$,    $$c$$$cc$$$c     `$$$"``$$$,     $$$`$$$"``$$$,     $$$
`88bo,__,o,"888,_ _,88P 888_,o8P' 888   888,     888   "888,_ _,88P 888   "888,_ _,88P
 "YUMMMMMP" "YMMMMMP"  MMMMP"`   YMM   ""`      "MM,    "YMMMMMP"  "MM,    "YMMMMMP"]],
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
