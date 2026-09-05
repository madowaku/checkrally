# Checkrally

**Think ahead. Break their reach. Checkmate the rally.**

Checkrally is a turn-based tennis puzzle game about creating a court position your opponent can no longer defend.

This repository contains the Godot 4.7 prototype. The current branch target is **v0.8 Core Puzzle Rebuild**, designed as a compact grant-demo slice for the Draknek New Voices Puzzle Grant 2026.

## Core idea

- No reflexes, timing, or aiming.
- Read the opponent's visible **Reach**.
- Choose Drop, Lob, Cross, or Drive.
- Choose a legal landing square.
- If the opponent reaches it, their position and stance change.
- Use that new state to create a **Weak Zone**.
- Land outside Reach to win the rally.

The puzzle is not about hitting harder. It is about making the next ball impossible to reach.

## v0.8 rebuild

The earlier prototype experimented with player anticipation movement and opponent prediction AI. v0.8 deliberately removes those systems from the core demo and makes one idea fully legible first: **reshape visible Reach, then attack the hole you created**.

The first ten puzzles teach:

1. Drop -> Lob
2. Lob -> Drop
3. Cross reversal
4. Drive pressure
5. Forward weakness
6. Back weakness
7. Stretched weakness
8. Pressure + deep angle
9. Reading a pre-existing Weak Zone
10. Open Checkrally exam

See `docs/CORE_DESIGN_V0.8.md` for the design thesis and deferred systems.

## Run

1. Install Godot 4.7.
2. Import this repository using `project.godot`.
3. Run the project. `scenes/Main.tscn` is the main scene.

The current prototype targets a 1100 x 720 desktop window.

## Controls

- Mouse: choose a shot, then click a highlighted landing square.
- `1`: Drop
- `2`: Lob
- `3`: Cross
- `4`: Drive
- `R`: retry puzzle
- Left / Right arrow: previous / next puzzle

## Court colors

- **Teal**: opponent Reach
- **Pale gold**: legal landing square that is still reachable
- **Gold**: legal landing square outside Reach, a winning Weak Zone
