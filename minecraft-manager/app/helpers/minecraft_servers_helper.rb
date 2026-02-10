module MinecraftServersHelper
  def status_badge(server)
    if server.running?
      content_tag(:span, "Running", class: "badge badge-running")
    else
      content_tag(:span, "Stopped", class: "badge badge-stopped")
    end
  end

  def toggle_field(form, field, label:, hint: nil)
    content_tag(:div, class: "form-group") do
      concat hidden_field_tag("minecraft_server[#{field}]", "0")
      concat(content_tag(:div, class: "toggle-wrapper") do
        concat(content_tag(:label, class: "toggle") do
          concat form.check_box(field, { class: "toggle-input", id: "minecraft_server_#{field}" }, "1", "0")
          concat content_tag(:span, nil, class: "toggle-slider")
        end)
        concat(content_tag(:label, label, class: "form-label", for: "minecraft_server_#{field}", style: "margin-bottom: 0; cursor: pointer;"))
      end)
      concat content_tag(:p, hint, class: "form-hint") if hint
    end
  end

  def select_field(form, field, choices, label:, hint: nil)
    content_tag(:div, class: "form-group") do
      concat form.label(field, label, class: "form-label")
      concat form.select(field, choices, {}, class: "form-select")
      concat content_tag(:p, hint, class: "form-hint") if hint
    end
  end

  def number_field_with_range(form, field, label:, min: nil, max: nil, step: nil, hint: nil)
    content_tag(:div, class: "form-group") do
      concat form.label(field, label, class: "form-label")
      opts = { class: "form-input" }
      opts[:min] = min if min
      opts[:max] = max if max
      opts[:step] = step if step
      concat form.number_field(field, opts)
      concat content_tag(:p, hint, class: "form-hint") if hint
    end
  end

  def text_input(form, field, label:, hint: nil, placeholder: nil)
    content_tag(:div, class: "form-group") do
      concat form.label(field, label, class: "form-label")
      opts = { class: "form-input" }
      opts[:placeholder] = placeholder if placeholder
      concat form.text_field(field, opts)
      concat content_tag(:p, hint, class: "form-hint") if hint
    end
  end

  def display_player_xuids(xuid_string)
    return content_tag(:span, "(none)", class: "text-gray-500") if xuid_string.blank?

    xuids = xuid_string.split(",").map(&:strip).reject(&:blank?)
    players_by_xuid = Player.where(xuid: xuids).index_by(&:xuid)

    tags = xuids.map do |xuid|
      if (player = players_by_xuid[xuid])
        content_tag(:span, player.gamertag, title: xuid, class: "badge badge-player")
      else
        content_tag(:span, xuid, class: "badge badge-player-unknown")
      end
    end

    safe_join(tags, " ")
  end

  def display_allow_list_users(value)
    return content_tag(:span, "(none)", class: "text-gray-500") if value.blank?

    entries = value.split(",").map(&:strip).reject(&:blank?)
    xuids = entries.map { |e| e.include?(":") ? e.split(":", 2).last : nil }.compact
    players_by_xuid = Player.where(xuid: xuids).index_by(&:xuid)

    tags = entries.map do |entry|
      if entry.include?(":")
        gamertag, xuid = entry.split(":", 2)
        player = players_by_xuid[xuid]
        display_name = player ? player.gamertag : gamertag
        content_tag(:span, display_name, title: xuid, class: "badge badge-player")
      else
        content_tag(:span, entry, class: "badge badge-player")
      end
    end

    safe_join(tags, " ")
  end

  def bool_display(value)
    value ? content_tag(:span, "Yes", class: "text-emerald-400") : content_tag(:span, "No", class: "text-gray-500")
  end

  def gamemode_icon(mode)
    case mode
    when "survival" then "&#x2694;"
    when "creative" then "&#x2728;"
    when "adventure" then "&#x1F5FA;"
    else "&#x2753;"
    end
  end

  def difficulty_color(diff)
    case diff
    when "peaceful" then "text-emerald-400"
    when "easy" then "text-blue-400"
    when "normal" then "text-yellow-400"
    when "hard" then "text-red-400"
    else "text-gray-400"
    end
  end

end
