vim.cmd([[
    let g:minimap_auto_start = 0 " show at startup
    let g:minimap_auto_start_win_enter = 0 " show on WinEnter (requires minimap_auto_start)
    let g:minimap_width = 10 " width of minimap in characters
    let g:minimap_window_width_override_for_scaling = 2147483647 " the width cap for scaling the minimap (see minimap.txt help file)
    let g:minimap_base_highlight = 'Normal' " the base color group for minimap
    let g:minimap_block_filetypes = ['fugitive', 'nerdtree', 'tagbar', 'fzf' ] " disable minimap for specific file types
    let g:minimap_block_buftypes = ['nofile', 'nowrite', 'quickfix', 'terminal', 'prompt'] " disable minimap for specific buffer types
    let g:minimap_close_filetypes = ['startify', 'netrw', 'vim-plug'] " close minimap for specific file types
    let g:minimap_close_buftypes = [] " close minimap for specific buffer types
    let g:minimap_left = 0 " if set, minimap window will append left
    let g:minimap_highlight_range = 0 " if set, minimap will highlight range of visible lines
    let g:minimap_highlight_search = 1 " if set, minimap will highlight searched patterns
    let g:minimap_git_colors = 1 " if set, minimap will highlight range of changes as reported by git
    let g:minimap_enable_highlight_colorgroup = 1 " if set, minimap will create an autocommand to set highlights on color scheme changeslet = . "

   let g:minimap_search_color_priority = 120 " the priority for the search highlight colors
   let g:minimap_cursor_color_priority = 110 " the priority for the cursor highlight colors
   let g:minimap_cursor_color = 'minimapCursor' " the color group for current position
   let g:minimap_range_color = 'minimapRange' " the color group for window range (if highlight_range is enabled)
   let g:minimap_search_color = 'Search' " the color group for highlighted search patterns in the minimap
   let g:minimap_diffadd_color = 'minimapDiffAdded' " the color group for added lines (if git_colors is enabled)
   let g:minimap_diffremove_color = 'minimapDiffRemoved' " the color group for removed lines (if git_colors is enabled)
   let g:minimap_diff_color = 'minimapDiffLine' " the color group for modified lines (if git_colors is enabled)
   let g:minimap_cursor_diffadd_color = 'minimapCursorDiffAdded' " the color group for the cursor over added lines
   let g:minimap_cursor_diffremove_color = 'minimapCursorDiffRemoved' " the color group for the cursor over removed lines
   let g:minimap_cursor_diff_color ='minimapCursorDiffLine' " the color group for the cursor over modified lines
   let g:minimap_range_diffadd_color ='minimapRangeDiffAdded' " the color group for the window range encompassing added lines
   let g:minimap_range_diffremove_color = 'minimapRangeDiffRemoved' " the color group for the window range encompassing removed lines
   let g:minimap_range_diff_color = 'minimapRangeDiffLine' " the color group for the window range encompassing modified lines
]])
