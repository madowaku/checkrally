# Checkrally v0.8 Core Puzzle Rebuild

## Design thesis

Checkrally is not a tennis simulator. It is a spatial logic puzzle built from the tactical idea underneath a rally:

> **Move the defender, change what they can reach, then place the ball where the court becomes impossible to defend.**

The player should spend their time reading future space, not executing timing or reflex actions.

## Why rebuild from v0.7

The earlier prototype proved that tennis can work as a board game, but it accumulated simulation concepts at the same time: player anticipation movement, incoming-ball markers, opponent prediction AI, stance, and rally flow. Interesting individually, these created too much explanation before the puzzle could sing.

v0.8 strips the loop back to one visible question:

**What can the defender reach right now, and how can I change that?**

## Core loop

1. See the opponent and their current **Reach**.
2. Choose a shot type.
3. See that shot's legal landing squares.
4. Choose a landing square.
5. If the square is outside Reach, score and solve the puzzle.
6. If it is inside Reach, the opponent moves there and their stance changes.
7. Read the new Reach and construct the next shot.

## Four shots

### Drop
Short target. If reached, the opponent becomes **Forward**.

Purpose: create weakness behind the opponent.

### Lob
Deep target. If reached, the opponent becomes **Back**.

Purpose: create weakness in front of the opponent.

### Cross
Sideways target. If reached, the opponent becomes **Stretched Left/Right**.

Purpose: create a reversal weakness across the court.

### Drive
A direct heavy ball. If reached, the opponent becomes **Pressured** for the next shot.

Purpose: temporarily shrink Reach and create diagonal Weak Zones.

## Reach is the rule, not hidden probability

The puzzle must remain deterministic and inspectable. No accuracy rolls, reaction checks, stamina dice, or hidden AI choices are needed in the grant demo.

The player can always see which cells are currently defendable.

- **Teal:** current Reach
- **Pale gold:** legal target, but still reachable
- **Gold:** legal target outside Reach, a winning Weak Zone

## Opponent states

- **Neutral:** balanced local coverage.
- **Forward:** covers the front and middle, leaves the back exposed.
- **Back:** covers the back and middle, leaves the front exposed.
- **Stretched Left / Right:** locally strong but poor at reversing across the court.
- **Pressured:** temporary modifier; diagonal coverage is removed for the next shot.

## Grant-demo teaching arc

1. Drop -> Lob
2. Lob -> Drop
3. Cross -> Cross
4. Drive -> angled Drop
5. Read Forward immediately
6. Read Back immediately
7. Read a stretched stance immediately
8. Drive -> angled Lob
9. Start from Pressured and find a Weak Zone
10. Open exam with all four shots

The first ten puzzles are not intended to represent the final difficulty ceiling. Their job is to make the core idea legible in roughly ten minutes.

## What to test next

The most important questions for v0.8 playtests are:

1. Does highlighting Reach make the puzzle understandable without explanation?
2. Does a reached shot still feel productive because it changes the next state?
3. Do players naturally discover Drop/Lob and Cross reversals?
4. Is Drive's Pressure modifier worth its added rule complexity?
5. Can later puzzles create surprising multi-step deductions without adding new mechanics?

## Deferred on purpose

The following ideas remain valuable, but are deliberately outside the v0.8 core loop:

- player anticipation movement
- hidden opponent prediction / bluffing
- stamina
- serve rules
- timing and reaction mechanics
- full match scoring
- character abilities

They can return only if the pure Reach puzzle proves fun first.
