import Config

config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_presences,
    :guild_members,
    # :guild_moderation,
    :guild_invites,
    :guild_messages,
    :guild_message_reactions,
    :guild_message_typing,
    :direct_message_typing,
    :direct_message_reactions,
    :message_content,
    :direct_messages
  ],
  intents: 1_689_934_340_028_480,
  log_full_events: true
