-- Scrolling layout (used on workspaces 4 and 5, see rules.lua)
hl.config({
  scrolling = {
    direction = "down",
    column_width = 0.97, -- 1.0 = full screen, others scrolled off until focused
    focus_fit_method = 0, -- centre focused window so neighbours peek evenly
  },
})
