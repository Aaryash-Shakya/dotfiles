-- Custom window/layer rules
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
  name = "slack-in-workspace-4",
  match = { class = "^([Ss]lack)$" },
  workspace = "4 silent",
})

for _, ws in ipairs({ "4", "5" }) do
  hl.workspace_rule({ workspace = ws, layout = "scrolling" })
end

hl.window_rule({
  name = "discord-in-workspace-6",
  match = { class = "vesktop" },
  workspace = "6 silent",
})
