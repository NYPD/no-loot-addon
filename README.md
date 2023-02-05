# NoLoot Addon

Dumb addon to help distribute loot easier during raid based on "Loot Priority Levels".

## Features

- Automatic display of Priorities. Simply loot the item to the bag and a gui should appear
- Handles multiple loot (multiple loot on the distribution list) from a singular boss and creates a "queue" to hand out loot
- Ability to traverse the priority list in case of player absence
- Rough version of class reserved loot
  - For class reserved loot, it actually just a "Player". To enter a class reserved loot / player simply start the word with
   a square bracket ```[``` e.g. ```[Warriors]```
  - Items are able to be class reserved as a prio level "1" or whatever as well as reserved by players in lower prios (or the same, you do you)
- Ability to have multiple loot distribution lists
  - One for each boss, each phase, whatever

## Quirks

- If something is bugging out the best thing to do is just refresh the UI
  - You could also try a ```/noloot clear```
- Refreshing the UI **WILL** remove all the loot currently in the queue, one will have to manually trigger a fake "pick up" then
- Triggering a million fake "pick ups" will create a million items in the queue
  - Im not gonna babysit the user being dumb

## Commands

### ```/noloot```

- Brings up the options menu

### ```/noloot trigger```

### ```/noloot trig```

### ```/noloot t```

- Triggers a fake item "pick up", useful when you close the GUI menu and need to bring it back

### ```/noloot history```

### ```/noloot h```

- Print the history of what item was given to a player in the chat window

### ```/noloot clear```

- Clears the current queue of items to be "handed out", for debugging and or fixing issues

### ```/noloot purge```

- Delete all the history, temp command, will get re-worked in the future

### ```/noloot "item name"``` (e.g. /noLoot Wool Cloth)

### ```/noloot "item number"``` (e.g. /noloot 2592)

### ```/noloot ItemLink``` (e.g. shift click an item into chat  ```/noloot [Wool Cloth]```)

- Triggers a fake item "pick up" for the loot specified
- When searching for an item name, and it DOES NOT exist in your backup, no icon will show up
  - Might fix or remove this in the future

## Terminology

- loot distribution list
  - The entire priority list
- Active loot list
  - The loot list that the item tracker is currently tracking against, can be changed in the options
- Priority
  - A priority is a "priority level (0-9999999999)" and contains one or more players
  - Each item in the loot distribution list contains 1 or more priorities
- Player
  - The actual player in line for the loot. Consists of player name and if they have the item or not.

## What Next?

Right now it's a rough alpha state to enter priority lists based on JSON. Future plan is to make it more user friendly by an in-game GUI or helper website. Also quality of life features will be nice
