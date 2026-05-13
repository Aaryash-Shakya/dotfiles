-- Custom window/layer rules
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
  name = "slack-in-workspace-4",
  match = { class = "Slack" },
  workspace = "4 silent",
})

hl.window_rule({
  name = "discord-in-workspace-6",
  match = { class = "vesktop" },
  workspace = "6 silent",
})
