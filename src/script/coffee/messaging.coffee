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

# No damage delt
Game.Messages.noDamage = "%s attacks %s for no damage!"

# Healing message
Game.Messages.healDamage = "%s heals %d Structure!"

# Stepping on an onWalkItem
Game.Messages.walkoverItem = "%s steps on %s."

# Testing long messages
Game.Messages.longMessage = "Bacon ipsum dolor amet shoulder landjaeger pancetta chicken turkey ham hock, shankle short ribs corned beef rump ham jerky sirloin leberkas. Venison cupim short ribs sausage tri-tip pork. "
