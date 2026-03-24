# Copilot Instructions for Gun Shit Game
These are the instruction for /gun game, a framework base for all shooter games
## Architecture Overview
This is a Roblox combat game using Luau, structured as:
- `src/client/`: Client-side logic (UI with Roact, input handling) and another service replicated to every player such as StarterCharacterScript
- `src/server/`: Server-side logic (combat mediation, player management)
- `src/shared/`: Shared utilities (animations, effects, Roact library)
- `src/myNeverMoreS/`: Core game systems (abilities, weapons, NPCs)
- `node_modules/@quenty` and `node_modules/@quentystudios`: Useful utilities of NeverMore engine for game

The folders `src/client` and `src/server` got a main entry point called ServiceRoot, it uses Nevermore for initializes the game. Implement `node_modules/@quenty` modules like `Maid`, `Promise`, `Rx`
Key frameworks:
- **Nevermore (Quenty)**: ServiceBag for DI, Binders for object behaviors, Cooldowns, and other Luau packages
- **Roact**: React-like UI library for Roblox
- **RemoteEvents**: Client-server communication via `RS.RemoteEvents/`

## Core Patterns
Services initialized in ServiceRoot are stored as a variable in `_G` once they are initialized
- **Service Access**: Use `_G.ServiceBag:GetService()` and `_G.BinderProvider:Get(tag):Get(object)` for global services/binders
- **Binders**: Tag objects with CollectionService tags like "Armed", "AnimationHandler"; bind behaviors via BinderProvider
- **Combat Flow**: "Armed" tag is used for weapon binder which strongly uses inheritance behaviour and allowing weapon strategies and abilities to be data-driven from `/src/myNeverMoreS/weapon/src/Shared/CombatConfig.luau`
- **Armed binder**: Weapon binder is a context strategy for weapons, every weapon it's a different strategy which inherits from src/MyNevermore/Binder/Weapon/WeaponBase and they can create they own abilities via `createAbilitiesFromKey()` using `skills` and `attacks` key from the ability
- **Armed name**: Every weapon uses a key string to lower case which indentify it for behaviour (`CombatConfig.luau`) and animations (`src/shared/Animations/WeaponsAnims.luau`) handled by the animation handler binder


## Development Workflow
- **Setup**: `npm install` for Quenty deps, `rojo init` if needed, `rojo serve` to sync with Roblox Studio
- **Testing**: Playtest in Studio; no automated tests - use prints for debugging
- **Building**: `rojo build` to generate rbxlx/rbxm files
- **Debugging**: Add `print()` statements; check attributes/events in Studio explorer

## Conventions
- **Modules**: Require via `local module = require(path)`; use `export type` for Luau types and create a different file for types often called as `serviceTypes`
- **Events**: Define in `RS.RemoteEvents/` as model.json; Listen to this events in `serviceMediator` or main entry point (`ServiceRoot`)
- **UI**: Use Roact components in `client/UI/`; mount to PlayerGui
- **File Naming**: `.luau` for module scripts, `.rbxmx` for models

## Key Files
- `src/server/ServiceRoot.server.luau`: Service initialization, player setup
- `src/client/UI/ServiceRoot.client.luau`: Client initialization
- `src/server/Combat/CombatMediator.luau`: Combat event handling
- `src/client/UI/App.luau`: Main UI mounting
- `src/myNeverMoreS/weapon/src/Shared/CombatConfig.luau`: Data used to call ability:Execute, important for creating new weapons
- `src/myNeverMoreS/abilities/src/Server/Abilities/RangeAttack.luau` and `/src/myNeverMoreS/abilities/src/Client/Abilities/RangeAttackClient.luau`: All attack abilities are used through this classes
