Game.Messages = {}

Game.parseMessage = (message, args) ->
  if args
    message = vsprintf(message, args)
  message

# Depreciated. Use events.
Game.sendMessage = (recipient, message, args) ->
  console.warn("Depreciated. Use events.")
  if recipient.hasMixin("MessageRecipient")
    if args
      message = vsprintf(message, args)
    recipient.recieveMessage(message)

# Attacker, Target, Damage
Game.Messages.attackMessage = "%s attacks %s for %d damage!"

# Taking Damage
Game.Messages.damageMessage = "%s deals %d damage to you!"

# Killing otherEntities
Game.Messages.killMessage = "%s kills %s!"

# Dying
Game.Messages.dieMessage = "You die."

# Full inventory
Game.Messages.FullInventory = "Your inventory is full."
