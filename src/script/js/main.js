(function() {
  var Entity, Game, Glyph, ItemListScreen, Map, Repository, Tile,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Game = {
    _display: null,
    _currentScreen: null,
    _screenHeight: 31,
    _screenWidth: 80,
    _messageHeight: 6,
    _statusHeight: 1,
    init: function() {
      var bindEventToScreen, game;
      this._display = new ROT.Display({
        width: this._screenWidth,
        height: this._screenHeight
      });
      game = this;
      bindEventToScreen = function(event) {
        return window.addEventListener(event, function(e) {
          if (game._currentScreen !== null) {
            return game._currentScreen.handleInput(event, e);
          }
        });
      };
      return bindEventToScreen("keydown");
    },
    getDisplay: function() {
      return this._display;
    },
    getWidth: function() {
      return this._screenWidth;
    },
    getHeight: function() {
      return this._screenHeight - this._messageHeight - this._statusHeight;
    },
    getMessageHeight: function() {
      return this._messageHeight;
    },
    getStatusHeight: function() {
      return this._statusHeight;
    },
    refresh: function() {
      if (this._display !== null && this._currentScreen !== null) {
        this._display.clear();
        return this._currentScreen.render(this._display);
      }
    },
    switchScreen: function(screen) {
      if (this._currentScreen !== null) {
        this._currentScreen.exit();
      }
      this._currentScreen = screen;
      if (this._currentScreen !== null) {
        this._currentScreen.enter();
        return this.refresh();
      }
    }
  };

  window.onload = function(event) {
    if (!ROT.isSupported()) {
      return alert("Rot is not Supported");
    } else {
      Game.init();
      document.body.appendChild(Game.getDisplay().getContainer());
      return Game.switchScreen(Game.Screen.startScreen);
    }
  };

  Glyph = (function() {
    function Glyph(options) {
      options = options || {};
      this._char = options.symbol || ' ';
      this._foreground = options.foreground || 'white';
      this._background - options.background || 'black';
    }

    Glyph.prototype.getChar = function() {
      return this._char;
    };

    Glyph.prototype.getForeground = function() {
      return this._foreground;
    };

    Glyph.prototype.getBackground = function() {
      return this._background;
    };

    return Glyph;

  })();

  Game.Glyph = Glyph;

  Map = (function() {
    function Map(tiles, player) {
      var j, k, t;
      this._entities = [];
      this._scheduler = new ROT.Scheduler.Simple();
      this._engine = new ROT.Engine(this._scheduler);
      this._tiles = tiles;
      this._width = tiles.length;
      this._height = tiles[0].length;
      if (typeof player !== void 0) {
        this.addEntityAtRandomPosition(player);
      }
      for (t = j = 0; j <= 15; t = ++j) {
        this.addEntityAtRandomPosition(Game.EntityRepository.createRandom());
      }
      for (t = k = 0; k <= 10; t = ++k) {
        this.addEntityAtRandomPosition(Game.ItemRepository.createRandom());
      }
    }

    Map.prototype.getWidth = function() {
      return this._width;
    };

    Map.prototype.getHeight = function() {
      return this._height;
    };

    Map.prototype.getTile = function(x, y) {
      if (x >= 0 && x < this._width && y >= 0 && y < this._height) {
        return this._tiles[x][y] || Game.Tile.nullTile;
      } else {
        return Game.Tile.nullTile;
      }
    };

    Map.prototype.getRandomFloorTile = function() {
      var rX, rY;
      while (true) {
        rX = Math.floor(ROT.RNG.getUniform() * this._width);
        rY = Math.floor(ROT.RNG.getUniform() * this._height);
        if (this.isEmptyFloor(rX, rY)) {
          break;
        }
      }
      return {
        x: rX,
        y: rY
      };
    };

    Map.prototype.getEngine = function() {
      return this._engine;
    };

    Map.prototype.getEntities = function() {
      return this._entities;
    };

    Map.prototype.getEntityAt = function(x, y) {
      var entity, j, len, position, ref;
      ref = this._entities;
      for (j = 0, len = ref.length; j < len; j++) {
        entity = ref[j];
        position = entity.getXY();
        if (position.x === x && position.y === y) {
          return entity;
        }
      }
      return false;
    };

    Map.prototype.getEntitiesWithinRadius = function(centerX, centerY, radius) {
      var bottomY, entity, j, leftX, len, ref, ref1, results, rightX, topY, x, y;
      results = [];
      leftX = centerX - radius;
      rightX = centerX + radius;
      topY = centerY - radius;
      bottomY = centerY + radius;
      ref = this._entities;
      for (j = 0, len = ref.length; j < len; j++) {
        entity = ref[j];
        ref1 = entity.getXY(), x = ref1[0], y = ref1[1];
        if (x <= rightX && x >= leftX && y >= topY(y <= bottomY)) {
          results.push(entity);
        }
      }
      return results;
    };

    Map.prototype.isEmptyFloor = function(x, y) {
      return this.getTile(x, y) === Game.Tile.floorTile && !this.getEntityAt(x, y);
    };

    Map.prototype.addEntity = function(entity) {
      var pos;
      pos = entity.getXY();
      if (pos.x < 0 || pos.y < 0 || pos.x >= this._width || pos.y >= this._height) {
        throw new Error('Adding entity out of bounds');
      }
      entity.setMap(this);
      this._entities.push(entity);
      if (entity.hasMixin("Actor")) {
        return this._scheduler.add(entity, true);
      }
    };

    Map.prototype.addEntityAtRandomPosition = function(entity) {
      var pos;
      pos = this.getRandomFloorTile();
      entity.setX(pos.x);
      entity.setY(pos.y);
      return this.addEntity(entity);
    };

    Map.prototype.removeEntity = function(entity) {
      var i, j, ref;
      for (i = j = 0, ref = this._entities.length - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        if (this._entities[i] === entity) {
          this._entities.splice(i, 1);
          break;
        }
      }
      if (entity.hasMixin("Actor")) {
        return this._scheduler.remove(entity);
      }
    };

    Map.prototype.dig = function(x, y) {
      var tile;
      tile = this.getTile(x, y);
      if (tile.isDiggable()) {
        return this._tiles[x][y] = Game.Tile.floorTile;
      }
    };

    return Map;

  })();

  Game.Map = Map;

  Game.Messages = {};

  Game.parseMessage = function(message, args) {
    if (args) {
      message = vsprintf(message, args);
    }
    return message;
  };

  Game.sendMessage = function(recipient, message, args) {
    console.warn("Depreciated. Use events.");
    if (recipient.hasMixin("MessageRecipient")) {
      if (args) {
        message = vsprintf(message, args);
      }
      return recipient.recieveMessage(message);
    }
  };

  Game.Messages.attackMessage = "%s attacks %s for %d damage!";

  Game.Messages.damageMessage = "%s deals %d damage to you!";

  Game.Messages.killMessage = "%s kills %s!";

  Game.Messages.dieMessage = "You die.";

  Game.Messages.FullInventory = "Your inventory is full.";

  Game.Mixins = {};

  Game.Mixins.MessageRecipient = {
    name: "MessageRecipient",
    listeners: {
      onAttacking: {
        priority: 15,
        func: function(type, dict) {
          var damage, target;
          target = dict.target;
          damage = dict.damage.amount;
          return this.recieveMessage(Game.parseMessage(Game.Messages.attackMessage, [this.describeA(true), target.describeA(false), damage]));
        }
      },
      takeDamage: {
        priority: 15,
        func: function(type, dict) {
          var damage;
          damage = dict.damage.amount;
          return this.recieveMessage(Game.parseMessage(Game.Messages.damageMessage, [this.describeA(true), damage]));
        }
      },
      onDeath: {
        priority: 15,
        func: function(type, dict) {
          var source;
          source = dict.source;
          if (this.hasMixin("PlayerActor")) {
            return this.recieveMessage(Game.parseMessage(Game.Messages.dieMessage));
          } else {
            return this.recieveMessage(Game.parseMessage(Game.Messages.killMessage, [source.describeA(True), this.describeA()]));
          }
        }
      }
    },
    init: function(template) {
      return this._messages = [];
    },
    getMessages: function() {
      return this._messages;
    },
    recieveMessage: function(message) {
      return this._messages.push(message);
    },
    clearMessage: function() {
      return this._messages = [];
    }
  };

  Game.Mixins.BlocksMovement = {
    name: "BlocksMovement",
    init: function() {
      return this._blocksMovement = true;
    }
  };

  Game.Mixins.PlayerActor = {
    name: "PlayerActor",
    groupName: "Actor",
    act: function() {
      Game.refresh();
      this.getMap().getEngine().lock();
      return this.clearMessage();
    }
  };

  Game.Mixins.FungusActor = {
    name: "FungusActor",
    groupName: "Actor",
    init: function() {
      return this._growthsRemaining = 5;
    },
    act: function() {
      var entity, growChance, xCoord, xOffset, yCoord, yOffset;
      growChance = Math.random();
      if (this._growthsRemaining > 0 && growChance < 0.02) {
        xOffset = Math.floor(Math.random() * 3) - 1;
        yOffset = Math.floor(Math.random() * 3) - 1;
        xCoord = this.getX() + xOffset;
        yCoord = this.getY() + yOffset;
        if (this.getMap().isEmptyFloor(xCoord, yCoord)) {
          entity = Game.EntityRepository.create('fungus');
          entity.setXY(xCoord, yCoord);
          entity._growthsRemaining = this._growthsRemaining -= 1;
          return this.getMap().addEntity(entity);
        }
      }
    }
  };

  Game.Mixins.Wander = {
    name: "WanderActor",
    groupName: "Actor",
    act: function() {
      var xCoord, xOffset, yCoord, yOffset;
      xOffset = Math.floor(Math.random() * 3) - 1;
      yOffset = Math.floor(Math.random() * 3) - 1;
      xCoord = this.getX() + xOffset;
      yCoord = this.getY() + yOffset;
      if (this.getMap().isEmptyFloor(xCoord, yCoord)) {
        return this.setXY(xCoord, yCoord);
      }
    }
  };

  Game.Mixins.SimpleAttacker = {
    name: "SimpleAttacker",
    groupName: "Attacker",
    init: function(template) {
      return this._atkValue = template['atkValue'] || 1;
    },
    getAttack: function() {
      return this._atkValue;
    },
    attack: function(target) {
      var damage, rDmg;
      if (target.hasMixin("Destructible")) {
        rDmg = Math.max(1, Math.floor((Math.random() + .5) * this._atkValue));
        damage = {
          amount: rDmg,
          type: "normal"
        };
        this.raiseEvent('onAttacking', {
          damage: damage,
          target: target
        });
        target.raiseEvent('onAttack', {
          damage: damage,
          source: this
        });
        target.raiseEvent('takeDamage', {
          damage: damage,
          source: this
        });
        return true;
      } else {
        return false;
      }
    }
  };

  Game.Mixins.FireAttacker = {
    name: "FireAttacker",
    groupName: "Attacker",
    listeners: {
      onAttacking: {
        priority: 75,
        func: function(type, dict) {
          dict.damage.amount += 5;
          return dict.damage.type += ',fire';
        }
      }
    }
  };

  Game.Mixins.FragileDestructible = {
    name: "FragileDestructible",
    groupName: "Destructible",
    listeners: {
      takeDamage: {
        priority: 25,
        func: function(type, dict) {
          var damage, source;
          damage = dict.damage.amount;
          source = dict.source;
          this._hp -= damage;
          if (this._hp < 0) {
            source.raiseEvent('onKill');
            return this.raiseEvent('onDeath');
          }
        }
      },
      onDeath: {
        priority: 25,
        func: function(type, dict) {
          return this.getMap().removeEntity(this);
        }
      }
    },
    init: function() {
      return this._hp = 0;
    }
  };

  Game.Mixins.SimpleDestructible = {
    name: "SimpleDestructible",
    groupName: "Destructible",
    listeners: {
      takeDamage: {
        priority: 25,
        func: function(type, dict) {
          var damage, realDamage, source;
          damage = dict.damage.amount;
          source = dict.source;
          realDamage = Math.max(1, damage - this._defValue);
          this._hp -= realDamage;
          if (this._hp < 0) {
            source.raiseEvent('onKill', {
              damage: damage,
              target: this
            });
            return this.raiseEvent('onDeath', {
              source: source
            });
          }
        }
      },
      onDeath: {
        priority: 25,
        func: function(type, dict) {
          if (!this.hasMixin("PlayerActor")) {
            return this.getMap().removeEntity(this);
          }
        }
      }
    },
    init: function(template) {
      this._maxHp = template['maxHp'] || 10;
      this._hp = template['Hp'] || this._maxHp;
      return this._defValue = template['defValue'] || 0;
    },
    getHp: function() {
      return this._hp;
    },
    getMaxHp: function() {
      return this._maxHp;
    },
    getDef: function() {
      return this._defValue;
    }
  };

  Game.Mixins.isStackable = {
    name: "isStackable",
    init: function() {
      return this._isStackable = true;
    }
  };

  Game.Mixins.Inventory = {
    name: "Inventory",
    groupName: "Inventory",
    init: function(template) {
      var j, ref, results1, x;
      this._itemSlots = Math.max(Math.min(template.itemSlots || 10, 26), 1);
      this._inventory = {};
      results1 = [];
      for (x = j = 65, ref = 64 + this._itemSlots; 65 <= ref ? j <= ref : j >= ref; x = 65 <= ref ? ++j : --j) {
        results1.push(this._inventory[String.fromCharCode(x)] = void 0);
      }
      return results1;
    },
    getItems: function() {
      return this._inventory;
    },
    getItem: function(letter) {
      return this._inventory[letter];
    },
    inventorySlotsOpen: function() {
      var count, key, ref, value;
      count = 0;
      ref = this._inventory;
      for (key in ref) {
        value = ref[key];
        if (!(value != null)) {
          count += 1;
        }
      }
      return count;
    },
    addToInventory: function(item) {
      var key, ref, value;
      if (this.inventorySlotsOpen() === 0) {
        if (this.hasMixin("MessageRecipient")) {
          Game.sendMessage(this, Game.Messages.FullInventory);
        }
        return false;
      }
      ref = this._inventory;
      for (key in ref) {
        value = ref[key];
        if (!(value != null)) {
          this._inventory[key] = item;
          return true;
        }
      }
    },
    removeFromInventory: function(letter) {
      if (letter in this._inventory) {
        this._inventory[letter] = void 0;
        return true;
      }
      return false;
    },
    dropFromInventory: function(letter) {
      if (letter in this._inventory) {
        if (this._map) {
          this._inventory[letter].setXY(this.getXY());
          this._map.addEntity(this._inventory[letter]);
          return this.removeFromInventory(letter);
        }
      }
    }
  };

  Game.Mixins.PlayerPickup = {
    name: "PlayerPickup",
    groupName: "Pickup",
    listeners: {
      pickup: {
        priority: 15,
        func: function(type, dict) {
          var item;
          item = dict.item;
          if (this.addToInventory(item)) {
            this.getMap().removeEntity(item);
          }
          return console.log(this.inventorySlotsOpen());
        }
      }
    }
  };

  Game.Mixins.WalkoverEffectItem = {
    name: "WalkoverEffectItem",
    groupName: "Item",
    listeners: {
      onWalkedOn: {
        priority: 50,
        func: function(type, dict) {
          var actor;
          actor = dict.source;
          return this._useEffect(actor, this);
        }
      }
    },
    init: function(template) {
      return this._useEffect = template.useEffect || function(actor) {};
    }
  };

  Game.Mixins.WalkoverPickupItem = {
    name: "WalkoverPickupItem",
    groupName: "Item",
    listeners: {
      onWalkedOn: {
        priority: 50,
        func: function(type, dict) {
          var actor;
          actor = dict.source;
          return actor.raiseEvent('pickup', {
            item: this
          });
        }
      }
    },
    init: function(template) {
      return this._useEffect = template.useEffect || function(actor) {};
    }
  };

  Game.Mixins.Movable = {
    name: "Movable",
    groupName: "Movable",
    tryMove: function(x, y, map) {
      var target, tile;
      tile = map.getTile(x, y);
      target = map.getEntityAt(x, y);
      if (target && this.hasMixin("Attacker") && target.hasMixin("Destructible")) {
        return this.attack(target);
      } else if (target._blocksMovement) {
        return false;
      } else if (tile.isWalkable()) {
        if (target) {
          target.raiseEvent("onWalkedOn", {
            source: this
          });
        }
        this._x = x;
        this._y = y;
        return true;
      } else if (tile.isDiggable()) {
        map.dig(x, y);
        return true;
      } else {
        return false;
      }
    }
  };

  Repository = (function() {
    function Repository(name, ctor) {
      this._ctor = ctor;
      this._name = name;
      this._templates = {};
    }

    Repository.prototype.define = function(name, template) {
      if (typeof name === "object") {
        template = name;
        name = template.name.toLowerCase();
      }
      return this._templates[name] = template;
    };

    Repository.prototype.create = function(name) {
      if (name in this._templates) {
        return new this._ctor(this._templates[name]);
      }
      throw new Error("No template named '" + name + "' in repository '" + this._name + "'.");
    };

    Repository.prototype.createRandom = function() {
      return this.create(Object.keys(this._templates).random());
    };

    return Repository;

  })();

  Game.Screen = {};

  Game.Screen.startScreen = {
    enter: function() {
      return console.log("we in dere");
    },
    exit: function() {
      return console.log("we out of dere");
    },
    render: function(display) {
      display.drawText(1, 1, "%c{yellow}Terminal");
      return display.drawText(1, 2, "%c{gray}Press [Enter] to Start");
    },
    handleInput: function(eventType, event) {
      if (eventType === "keydown" && event.keyCode === ROT.VK_RETURN) {
        return Game.switchScreen(Game.Screen.playScreen);
      }
    }
  };

  Game.Screen.playScreen = {
    _map: null,
    _mapWidth: 240,
    _mapHeight: 72,
    _player: null,
    _subscreen: null,
    setSubScreen: function(screen) {
      this._subscreen = screen;
      return Game.refresh();
    },
    enter: function() {
      var generator, j, k, map, num, ref, ref1, totalIterations, y;
      console.log("Entered Play Screen");
      map = [];
      for (num = j = 0, ref = this._mapWidth - 1; 0 <= ref ? j <= ref : j >= ref; num = 0 <= ref ? ++j : --j) {
        map.push((function() {
          var k, ref1, results1;
          results1 = [];
          for (y = k = 0, ref1 = this._mapHeight - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; y = 0 <= ref1 ? ++k : --k) {
            results1.push(Game.Tile.nullTile);
          }
          return results1;
        }).call(this));
      }
      generator = new ROT.Map.Cellular(this._mapWidth, this._mapHeight);
      generator.randomize(0.5);
      totalIterations = 3;
      for (num = k = 1, ref1 = totalIterations; 1 <= ref1 ? k <= ref1 : k >= ref1; num = 1 <= ref1 ? ++k : --k) {
        generator.create();
      }
      generator.create(function(x, y, value) {
        if (value === 1) {
          return map[x][y] = Game.Tile.wallTile;
        } else {
          return map[x][y] = Game.Tile.floorTile;
        }
      });
      this._player = new Entity(Game.playerTemplate);
      this._map = new Game.Map(map, this._player);
      return this._map.getEngine().start();
    },
    exit: function() {
      return console.log("Exited Play Screen");
    },
    render: function(display) {
      var entity, glyph, j, k, l, len, len1, m, message, messageY, player, pos, ref, ref1, ref2, ref3, ref4, ref5, results1, screenHeight, screenWidth, stats, topLeftX, topLeftY, x, y;
      if (this._subscreen) {
        this._subscreen.render(display);
        return;
      }
      screenWidth = Game.getWidth();
      screenHeight = Game.getHeight();
      topLeftX = Math.max(0, this._player.getX() - (screenWidth / 2));
      topLeftX = Math.min(topLeftX, this._map.getWidth() - screenWidth);
      topLeftY = Math.max(0, this._player.getY() - (screenHeight / 2));
      topLeftY = Math.min(topLeftY, this._map.getHeight() - screenHeight);
      for (x = j = ref = topLeftX, ref1 = topLeftX + screenWidth; ref <= ref1 ? j <= ref1 : j >= ref1; x = ref <= ref1 ? ++j : --j) {
        for (y = k = ref2 = topLeftY, ref3 = topLeftY + screenHeight; ref2 <= ref3 ? k <= ref3 : k >= ref3; y = ref2 <= ref3 ? ++k : --k) {
          glyph = this._map.getTile(x, y);
          display.draw(x - topLeftX, y - topLeftY, glyph.getChar(), glyph.getForeground(), glyph.getBackground());
        }
      }
      player = null;
      ref4 = this._map.getEntities();
      for (l = 0, len = ref4.length; l < len; l++) {
        entity = ref4[l];
        pos = entity.getXY();
        if (pos.x >= topLeftX && pos.x < (topLeftX + screenWidth) && pos.y >= topLeftY && pos.y < (topLeftY + screenHeight)) {
          if (entity.hasMixin("PlayerActor")) {
            player = entity;
          } else {
            display.draw(pos.x - topLeftX, pos.y - topLeftY, entity.getChar(), entity.getForeground(), entity.getBackground());
          }
        }
      }
      pos = player.getXY();
      display.draw(pos.x - topLeftX, pos.y - topLeftY, player.getChar(), player.getForeground(), player.getBackground());
      stats = '%c{white}%b{black}';
      stats += vsprintf('HP: %d/%d', [this._player.getHp(), this._player.getMaxHp()]);
      stats += vsprintf(' Atk: %d Def: %d', [this._player.getAttack(), this._player.getDef()]);
      display.drawText(0, screenHeight + 1, stats);
      messageY = screenHeight + 2;
      ref5 = this._player.getMessages();
      results1 = [];
      for (m = 0, len1 = ref5.length; m < len1; m++) {
        message = ref5[m];
        results1.push(messageY += display.drawText(0, messageY, '%c{white}%b{black}' + message));
      }
      return results1;
    },
    move: function(cx, cy) {
      var dX, dY;
      dX = this._player.getX() + cx;
      dY = this._player.getY() + cy;
      this._player.raiseEvent("onMove");
      return this._player.tryMove(dX, dY, this._map);
    },
    handleInput: function(eventType, event) {
      var item, letter;
      if (this._subscreen !== null) {
        this._subscreen.handleInput(eventType, event);
        return;
      }
      if (eventType === "keydown") {
        switch (event.keyCode) {
          case ROT.VK_RETURN:
            Game.switchScreen(Game.Screen.winScreen);
            break;
          case ROT.VK_ESCAPE:
            Game.switchScreen(Game.Screen.loseScreen);
            break;
          case ROT.VK_R:
            Game.switchScreen(Game.Screen.playScreen);
            break;
          case ROT.VK_LEFT:
            this.move(-1, 0);
            break;
          case ROT.VK_RIGHT:
            this.move(1, 0);
            break;
          case ROT.VK_UP:
            this.move(0, -1);
            break;
          case ROT.VK_DOWN:
            this.move(0, 1);
            break;
          case ROT.VK_I:
            if (((function() {
              var ref, results1;
              ref = this._player.getItems();
              results1 = [];
              for (letter in ref) {
                item = ref[letter];
                results1.push(item);
              }
              return results1;
            }).call(this)).filter(function(x) {
              return x;
            }).length === 0) {
              Game.sendMessage(this._player, "You are not carrying anything!");
              Game.refresh();
            } else {
              Game.Screen.InventoryScreen.setup(this._player, this._player.getItems());
              this.setSubScreen(Game.Screen.InventoryScreen);
            }
            return;
        }
        return this._map.getEngine().unlock();
      }
    }
  };

  Game.Screen.winScreen = {
    enter: function() {
      return console.log("Entered winScreen");
    },
    exit: function() {
      return console.log("Exiting winScreen");
    },
    render: function(display) {
      display.drawText(1, 1, "%c{green}Yay, you won.");
      return display.drawText(1, 2, "%c{gray}Press [Enter] to try again");
    },
    handleInput: function(eventType, event) {
      if (eventType === "keydown" && event.keyCode === ROT.VK_RETURN) {
        return Game.switchScreen(Game.Screen.startScreen);
      }
    }
  };

  Game.Screen.loseScreen = {
    enter: function() {
      return console.log("Entered loseScreen");
    },
    exit: function() {
      return console.log("Exited loseScreen");
    },
    render: function(display) {
      display.drawText(1, 1, "%c{red}Buu, you lost.");
      return display.drawText(1, 2, "%c{gray}Press [Enter] to try again");
    },
    handleInput: function(eventType, event) {
      if (eventType === "keydown" && event.keyCode === ROT.VK_RETURN) {
        return Game.switchScreen(Game.Screen.startScreen);
      }
    }
  };

  ItemListScreen = (function() {
    function ItemListScreen(template) {
      this._caption = template.caption;
      this._okFunction = template.ok;
      this._canSelectInput = template.canSelect;
      this._canSelectMultipleItems = template.canSelectMultipleItems;
    }

    ItemListScreen.prototype.setup = function(player, items) {
      this._player = player;
      this._items = items;
      return this._selectedIndices = {};
    };

    ItemListScreen.prototype.render = function(display) {
      var item, letter, letters, ref, results1, row;
      letters = 'abcdefghijklmnopqrstuvwxyz';
      display.drawText(0, 0, this._caption);
      row = 0;
      ref = this._items;
      results1 = [];
      for (letter in ref) {
        item = ref[letter];
        if (item) {
          display.drawText(0, row + 2, letter + ' - ' + item.describeA(true));
        }
        results1.push(row += 1);
      }
      return results1;
    };

    ItemListScreen.prototype.executeOkFunction = function() {
      var _, key, ref, selectedItems;
      selectedItems = {};
      ref = this._selectedIndices;
      for (key in ref) {
        _ = ref[key];
        selectedItems[key] = this._items[key];
      }
      Game.Screen.playScreen.setSubscreen(null);
      if (this.executeOkFunction(selectedItems)) {
        return this._player.getMap().getEngine().unlock();
      }
    };

    ItemListScreen.prototype.handleInput = function(eventType, event) {
      var index;
      if (eventType === 'keydown') {
        if (event.keyCode === ROT.VK_ESCAPE || (event.keyCode === ROT.VK_RETURN && (!this._canSelectItem || Object.keys(this._selectedIndices).length === 0))) {
          return Game.Screen.playScreen.setSubScreen(null);
        } else if (event.keyCode === ROT.VK_RETURN) {
          return this.executeOkFunction();
        } else if (this._canSelectItem && event.keyCode >= ROT.VK_A && event.keyCode <= ROT.VK_Z) {
          index = event.keyCode - ROT.VK_A;
          if (this._items[index]) {
            if (this._canSelectMultipleItems) {
              if (this._selectedIndices[index]) {
                delete this._selectedIndices[index];
              } else {
                this._selectedIndices[index] = true;
              }
              return Game.refresh();
            } else {
              this._selectedIndices[index] = true;
              return this.executeOkFunction();
            }
          }
        }
      }
    };

    return ItemListScreen;

  })();

  Game.Screen.InventoryScreen = new ItemListScreen({
    caption: "Inventory",
    canSelect: false
  });

  Tile = (function(superClass) {
    extend(Tile, superClass);

    function Tile(options) {
      options = options || {};
      Tile.__super__.constructor.call(this, options);
      this._isWalkable = options.isWalkable || false;
      this._isDiggable = options.isDiggable || false;
    }

    Tile.prototype.isWalkable = function() {
      return this._isWalkable;
    };

    Tile.prototype.isDiggable = function() {
      return this._isDiggable;
    };

    return Tile;

  })(Glyph);

  Game.Tile = Tile;

  Game.Tile.nullTile = new Game.Tile({});

  Game.Tile.wallTile = new Game.Tile({
    symbol: '#',
    foreground: 'goldenrod',
    isDiggable: true
  });

  Game.Tile.floorTile = new Game.Tile({
    symbol: '.',
    isWalkable: true
  });

  Entity = (function(superClass) {
    extend(Entity, superClass);

    function Entity(options) {
      var j, key, len, listener, listeners, mixin, mixins, ref, ref1, value;
      options = options || {};
      Entity.__super__.constructor.call(this, options);
      this.name = options.name || "";
      this._x = options.x || 0;
      this._y = options.y || 0;
      this._map = options.map || null;
      this._attachedMixins = {};
      this._attachedMixinGroups = {};
      this._attachedListeners = {};
      mixins = options.mixins || [];
      for (j = 0, len = mixins.length; j < len; j++) {
        mixin = mixins[j];
        this._attachedMixins[mixin.name] = true;
        if ("groupName" in mixin) {
          this._attachedMixinGroups[mixin.groupName] = true;
        }
        for (key in mixin) {
          value = mixin[key];
          if (key !== "name" && key !== "init" && key !== "listeners" && !this.hasOwnProperty(key)) {
            this[key] = value;
          }
        }
        if (mixin.listeners) {
          ref = mixin.listeners;
          for (key in ref) {
            listener = ref[key];
            if (!(key in this._attachedListeners)) {
              this._attachedListeners[key] = [];
            }
            this._attachedListeners[key].push(listener);
          }
        }
        ref1 = this._attachedListeners;
        for (key in ref1) {
          listeners = ref1[key];
          listeners.sort(function(a, b) {
            return b.priority - a.priority;
          });
        }
        if ("init" in mixin) {
          mixin.init.call(this, options);
        }
      }
    }

    Entity.prototype.describe = function() {
      return this.name;
    };

    Entity.prototype.describeA = function(isCapitalized) {
      var name, prefix, prefixes, ref;
      prefixes = isCapitalized ? ['A', 'An'] : ['a', 'an'];
      name = this.describe();
      prefix = prefixes[(ref = name[0].toLowerCase(), indexOf.call('aeiou', ref) >= 0) ? 1 : 0];
      return prefix + ' ' + name;
    };

    Entity.prototype.setName = function(name) {
      return this._name = name || '';
    };

    Entity.prototype.setX = function(x) {
      return this._x = x || 0;
    };

    Entity.prototype.setY = function(y) {
      return this._y = y || 0;
    };

    Entity.prototype.setXY = function(x, y) {
      if (typeof x === "object") {
        this.setX(x.x);
        return this.setY(x.y);
      } else {
        this.setX(x);
        return this.setY(y);
      }
    };

    Entity.prototype.setMap = function(map) {
      return this._map = map;
    };

    Entity.prototype.getName = function() {
      return this._name;
    };

    Entity.prototype.getX = function() {
      return this._x;
    };

    Entity.prototype.getY = function() {
      return this._y;
    };

    Entity.prototype.getXY = function() {
      return {
        x: this._x,
        y: this._y
      };
    };

    Entity.prototype.getMap = function() {
      return this._map;
    };

    Entity.prototype.hasMixin = function(obj) {
      if (typeof obj === "object") {
        return this._attachedMixins[obj.name] || false;
      } else if (typeof obj === "string") {
        return this._attachedMixins[obj] || this._attachedMixinGroups[obj] || false;
      } else {
        return false;
      }
    };

    Entity.prototype.raiseEvent = function(event) {
      var j, len, listener, ref, results1;
      if (!this._attachedListeners[event]) {
        return;
      }
      ref = this._attachedListeners[event];
      results1 = [];
      for (j = 0, len = ref.length; j < len; j++) {
        listener = ref[j];
        results1.push(listener.func.apply(this, arguments));
      }
      return results1;
    };

    return Entity;

  })(Glyph);

  Game.playerTemplate = {
    name: "Player",
    symbol: "@",
    foreground: "white",
    background: "black",
    atkValue: 10,
    maxHp: 40,
    itemSlots: 26,
    mixins: [Game.Mixins.Movable, Game.Mixins.PlayerActor, Game.Mixins.SimpleAttacker, Game.Mixins.MessageRecipient, Game.Mixins.SimpleDestructible, Game.Mixins.Inventory, Game.Mixins.PlayerPickup]
  };

  Game.EntityRepository = new Repository('entities', Entity);

  Game.EntityRepository.define({
    name: "Fungus",
    symbol: "F",
    foreground: "chartreuse",
    mixins: [Game.Mixins.FungusActor, Game.Mixins.FragileDestructible]
  });

  Game.EntityRepository.define({
    name: "Goblin",
    symbol: "G",
    foreground: "MediumSeaGreen",
    mixins: [Game.Mixins.Wander, Game.Mixins.FragileDestructible]
  });

  Game.ItemRepository = new Repository('items', Entity);

  Game.ItemRepository.define({
    name: "Data",
    symbol: '=',
    foreground: "white",
    background: "black",
    useEffect: function(target) {
      return target.raiseEvent("takeDamage", {
        source: this,
        damage: {
          type: "focused",
          amount: 41
        }
      });
    },
    mixins: [Game.Mixins.WalkoverEffectItem]
  });

  Game.ItemRepository.define({
    name: "Offensive Data",
    symbol: '=',
    foreground: "red",
    background: "black",
    mixins: [Game.Mixins.WalkoverPickupItem]
  });

  Game.ItemRepository.define({
    name: "Defensive Data",
    symbol: '=',
    foreground: "cyan",
    background: "black",
    mixins: [Game.Mixins.WalkoverPickupItem]
  });

  Game.ItemRepository.define({
    name: "Utility Data",
    symbol: '=',
    foreground: "green",
    background: "black",
    mixins: [Game.Mixins.WalkoverPickupItem]
  });

}).call(this);
