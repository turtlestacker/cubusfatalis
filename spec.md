# CubusFatalis — Spec

## 1. Overview

**CubusFatalis** is a real-time 3D online action game played in voxel space. Each player controls a drifting connected polycube organism composed of unit cubes. Organisms grow by consuming smaller compatible shapes, shrink through metabolic attrition and emergency acceleration, and evolve musically as they absorb notes and rhythms.

The core promise is a playable fusion of:

- 3D polycube navigation and assembly
- predator-prey scaling: bigger eats smaller
- musical evolution through note accumulation
- visual filtering that makes harmonic possibility readable at a glance

The long-term product direction is a **shared continuous online world with persistent player identity**, but the first milestone is a **local single-player demo** designed to validate controls, readability, merge feel, harmonic logic, and audio reward.

---

## 2. Design goals

The game should feel:

- **Readable**: the player can quickly tell what can be eaten, what is dangerous, and how their body is oriented.
- **Embodied**: the player is the shape, not a ship carrying cubes.
- **Musical**: note/key evolution materially changes the play space.
- **Pressured**: metabolism and predators force ongoing movement and decisions.
- **Expressive**: different shapes, harmonic paths, and risks create distinct runs.

The first playable should optimize for:

1. Clear 3D motion and camera understanding
2. Satisfying consume / merge events
3. Strong prey-vs-threat readability
4. A harmonic system that feels strategic, not arbitrary
5. Audio layering that becomes richer without becoming muddy

---

## 3. Product structure

### 3.1 Long-term product direction

- Shared continuous online world
- Players can join from anywhere on the internet
- Each player has a persistent identity tracked across sessions
- World simulation is server authoritative
- Account data persists; world/body persistence is a later design choice

### 3.2 First milestone

A local demo that proves the core loop.

**Local demo scope**:
- 1 player
- bounded arena
- curated starter shapes
- passive drifting NPMCs
- optionally 1 simple predator AI after base loop works
- no online transport yet
- code architecture should keep simulation state separable from future networking/state persistence

---

## 4. Core fantasy

You begin as a small drifting organism made of cubes. You hear yourself as a note and rhythm. Around you are other drifting forms: some edible, some dangerous, some irrelevant. You steer through 3D space, choosing prey not only for growth but for harmonic consequence. Each swallow changes your body and your soundtrack. The bigger you get, the hungrier you become. If you panic, you can burst away by sacrificing your own mass. Survival is an evolving geometric and musical negotiation.

---

## 5. World model

### 5.1 Space

The world is a 3D arena. Position and movement are continuous, but each organism’s body is represented on a **unit voxel grid** in local space.

For the local demo, use a **bounded cubic arena**.

Recommended behavior:
- soft visible boundaries
- no wraparound in MVP
- light return force or collision buffer at edges if needed

### 5.2 Entity representation

Each organism/NPMC stores:
- local-space occupied voxel coordinates
- world position
- orientation
- linear velocity
- angular velocity or simplified tumble state
- volume (cube count)
- cached surface cubes
- musical state
- visual state

### 5.3 Shape validity

A valid shape must be:
- face-connected
- non-overlapping
- free of sealed internal voids

This applies to:
- starter shapes
- NPMCs
- post-consume merged shapes

---

## 6. Entity classes

### 6.1 Player organism

The player controls a connected cavity-free polycube organism.

Properties:
- curated starter shape within a **3×3×3** bounding box
- starting volume limited to a curated range
- dynamic body geometry
- metabolism
- emergency acceleration by shedding cubes
- harmonic reinterpretation over time
- layered music
- scoring participation

### 6.2 NPMC — Non-Playable Music Cube

NPMCs are simple drifting musical resource entities.

Properties:
- connected cavity-free shape constrained to a **2×2×2** bounding box
- fixed size until consumed
- fixed note until consumed
- fixed rhythm until consumed
- passive drifting motion
- no AI hunting/fleeing
- no metabolism
- no key reinterpretation while independent

Role:
- low-risk harmonic resources
- early-game food supply
- sustain against metabolism
- readable environmental musical texture

### 6.3 Future AI organisms

Not required for the first prototype, but the architecture should support future autonomous organisms with the same core body and harmonic rules as players.

---

## 7. Starter shapes

### 7.1 Starter shape policy

Do **not** allow arbitrary 3×3×3 shapes. Use a curated roster.

Recommended local demo roster:
- 4–6 shapes initially
- expand to 12+ later

### 7.2 Starting volume

Recommended MVP starting volume:
- **5 or 6 cubes**

Rationale:
- enough shape identity to matter
- still readable and maneuverable
- fair starting baseline

### 7.3 Starter balancing goals

All starter shapes should be balanced around equivalent overall viability, with tradeoffs in:
- surface area
- turn feel
- docking ease
- vulnerability to degradation

### 7.4 Candidate starter archetypes

- **Line**: elongated, quick to align, easy to trap
- **Hook**: versatile contact geometry
- **Plate**: stable and readable, slower feeling
- **Corner**: compact with multiple attachable faces
- **Fork**: aggressive protrusions, less stable under shedding
- **Cluster**: compact and robust, less reach

---

## 8. Movement, camera, and control

This is the highest-risk system and should be optimized for clarity over simulation purity.

### 8.1 Movement model

Use a hybrid inertial drift model:
- the player drifts continuously in 3D
- thrust modifies velocity
- brake reduces velocity
- rotation changes orientation independently
- shape size reduces maneuverability

### 8.2 Control goals

The player must be able to:
- travel through 3D space comfortably
- intentionally approach prey
- evade predators
- understand current orientation
- make docking decisions without wrestling the camera

### 8.3 Recommended control scheme

Use a **hybrid control model**.

#### Travel mode
- smooth thrust
- smooth yaw/pitch control
- optional roll
- forgiving camera follow

#### Precision mode
Activated by holding a modifier button.

In precision mode:
- time may slightly slow in local demo if needed
- rotation snaps in **90° increments**
- candidate contact faces preview clearly
- a ghosted merge preview appears when near legal consume opportunities

This preserves the feeling of 3D motion while making voxel alignment practical.

### 8.4 Camera

Recommended local demo camera:
- third-person follow camera
- soft auto-leveling
- target assistance when near relevant prey/threats
- transparency/cutaway on occlusion
- always-visible axis indicator/gizmo

### 8.5 Four-view readability layout (local demo option)

For the first playable, a **4-view presentation** is recommended as a readability aid:
- one large perspective gameplay view (top)
- three smaller orthographic aligned views (bottom row):
  - X-aligned (shows Y/Z plane)
  - Y-aligned (shows X/Z plane)
  - Z-aligned (shows X/Y plane)

Each orthographic panel should:
- include a visible non-perspective grid
- display the movement keys for its controlled axis
- track the player center so nearby consume opportunities remain visible

### 8.6 Maneuverability scaling

As volume increases:
- acceleration decreases
- max turn rate decreases
- inertial feel increases

Compact shapes may receive a small hidden maneuver bonus compared with sprawling shapes of equal volume.

---

## 9. Musical system

### 9.1 Harmonic universe

Use only:
- **12 major keys**
- **12 minor keys**

No modes for MVP.

### 9.2 Notes

Each independent shape/NPMC carries a note represented as a chromatic pitch class.

### 9.3 Harmonic memory and legality

A player organism stores:
- all absorbed musical layers for audio history
- a **recent harmonic note window** for compatibility logic

Recommended rule:
- only the **last 4 unique pitch classes** count for key resolution and prey legality
- duplicates do not expand harmonic legality
- older notes remain in the soundtrack but no longer affect compatibility

This prevents harmonic lock-up and keeps the system readable.

### 9.4 Best-fit key reinterpretation

A shape does not keep one permanently fixed key.

Instead:
1. take the current active recent note window
2. test it against all 24 allowed keys
3. if at least one key contains all active notes, the state is valid
4. choose the current resolved key using deterministic tie-break rules

### 9.5 Key tie-break rules

If multiple keys are valid, resolve in this order:
1. keep the current resolved key if still valid
2. otherwise prefer keys supported by the highest number of recent notes
3. otherwise prefer a key whose tonic is present in the recent note window
4. otherwise prefer the closest key to the previous key on a fixed deterministic circle-of-fifths ordering
5. if still tied, choose by a fixed priority table

This prevents visible key flicker.

### 9.6 Rhythms

Every shape/NPMC has a rhythm pattern.

For MVP:
- NPMCs keep a fixed rhythm until swallowed
- the player starts with one rhythm pattern
- each consumed shape contributes a rhythm layer

### 9.7 Audio layering

On consume:
- full prey geometry is assimilated if legal
- the prey’s note/rhythm becomes part of the consumer’s musical stack
- tempo increases slightly based on consumed volume significance

Recommended audio management:
- only the most recent few layers are foregrounded
- older layers may be mixed down or reduced in prominence
- avoid unlimited equal-volume layering

### 9.8 Tempo escalation

Tempo rises gradually as successful consumes happen.

Recommended rule:
- tempo gain scales by prey significance relative to current size
- near-peer consumes produce stronger tempo increase than trivial food

---

## 10. Harmonic compatibility and prey logic

### 10.1 Legal consume — musical conditions

A target is musically consumable if, after adding its note to the attacker’s active recent note window, the resulting set still fits at least one of the 24 allowed keys.

### 10.2 Consequence of consume

A successful consume may:
- preserve the current resolved key
- clarify the current key
- shift the organism into a new key

This key shift changes future prey options.

### 10.3 Uniform note distribution

Ambient note-bearing entities are distributed **uniformly across the 12 chromatic notes**.

No spatial regional key bias in MVP.

This ensures:
- the world does not over-direct the player
- harmonic choice remains meaningful
- prey availability depends on the player’s state, not just location

---

## 11. Visual language and readability

The visual system should answer three questions quickly:
1. What can I eat right now?
2. What can eat me right now?
3. What would eating that do to my harmonic state?

### 11.1 Context-sensitive rendering

Objects are not primarily rendered by absolute intrinsic state. They are rendered by their current relevance to the player.

### 11.2 Consumable targets

A target that is currently legally consumable is rendered in **vivid color**.

That color indicates the **resulting resolved key** the player would enter after consuming that target.

### 11.3 Non-consumable targets

Targets that cannot currently be consumed are rendered:
- desaturated
- dimmed
- washed out
- semi-transparent as needed

### 11.4 Predatory threats

Targets that can consume the player should remain visually prominent even when not edible.

Recommended treatment:
- strong hostile outline
- pulsating danger shell
- high-contrast emissive rim

This avoids hiding important threats behind the washout system.

### 11.5 Player body rendering

The player’s own body should remain clear and readable at all times.

Recommended visual channels:
- body material readable from all angles
- subtle rhythm pulse over the whole body
- local indicators for highlighted contact faces during docking/consume proximity

### 11.6 HUD recommendations

Minimal but important HUD:
- current resolved key
- current recent note window (last 4 unique notes)
- current score
- current volume
- metabolism/attrition timer indicator
- boost availability / shedding warning
- result-key preview on highlighted consumable target

---

## 12. Geometry, collision, and merge rules

### 12.1 Collision basis

Use voxel-informed collision with simple broad-phase approximation for performance.

### 12.2 Face-contact rule

A consume attempt is only considered on **face-to-face** contact.

- edge contact does nothing
- corner contact does nothing

### 12.3 Size rule

**Bigger eats smaller.**

A consume is possible only if:
- attacker volume is strictly greater than defender volume

No extra combat stat is required for MVP.

### 12.4 Full-union rule

Use **Option 1** for geometry transfer:
- if a consume succeeds, the full prey volume is added to the consumer’s body

### 12.5 Merge legality

A consume only succeeds if the merged body would be:
- connected
- non-overlapping
- cavity-free

If the full union is illegal, the consume fails.

No partial assimilation in MVP.

### 12.6 Local demo interaction recommendation

For the first playable, use a forgiving consume interaction:
- when compatible targets make appropriate contact, a consume can trigger automatically if legal
- near-contact preview makes the result understandable
- exact manual docking skill can be deepened later

This is recommended for the first prototype because it tests the merge/consume fantasy without overloading players with precision burdens.

---

## 13. Metabolism and emergency acceleration

### 13.1 Metabolism

All player organisms lose mass over time.

Recommended MVP formula:

**Attrition interval = 24 / sqrt(volume) seconds**

At each interval:
- remove 1 legal surface cube

Examples:
- 4 cubes -> every 12s
- 9 cubes -> every 8s
- 16 cubes -> every 6s
- 25 cubes -> every 4.8s

### 13.2 Purpose of metabolism

Metabolism:
- prevents permanent dominance
- pressures larger organisms to keep feeding
- keeps the ecosystem active
- makes growth meaningful but costly

### 13.3 Legal removable cube

A removable cube must:
- be on the surface
- leave the body connected if removed
- not create illegal post-removal geometry

### 13.4 Cube removal selection

For the demo, avoid pure randomness if it frequently creates ugly, frustrating bodies.

Recommended approach:
- select from legal surface cubes
- add light weighting away from removing structurally critical cubes
- preserve readability and controllability where possible

### 13.5 Emergency acceleration

The player may activate a burst/accelerate action to evade danger.

Effect:
- grants temporary movement advantage
- consumes body volume as cost

Recommended MVP rule:
- while boosting, remove **1 legal surface cube** at fixed short intervals
- the organism gains a burst of speed and/or maneuver response

### 13.6 Failure state under shrinkage

If the player can no longer remove legal cubes or falls below the minimum viable volume, the organism dies.

Recommended minimum viable volume for MVP:
- test **3 cubes** first

---

## 14. Scoring

### 14.1 Consume scoring

If a shape of volume `V` is consumed:

- **consumer gains `0.5 × V` points**
- **consumed player gains `1.0 × V` points**

This intentionally reduces runaway snowballing and lets a doomed but well-grown player still have a meaningful run.

### 14.2 NPMC scoring

Recommended:
- score NPMCs lower than player/organism prey to preserve risk-reward hierarchy

Suggested local demo rule:
- consumer gains **0.25 × V** when consuming an NPMC

NPMCs should function mainly as sustain and harmonic steering, not as the dominant scoring path.

### 14.3 Additional future score inputs

Potential future additions:
- survival time bonus
- predator escape bonus
- peak volume bonus
- harmonic diversity bonus
- tempo/complexity bonus

For the first playable, keep score simple.

---

## 15. Core loop

The intended moment-to-moment loop is:

1. Spawn as a small readable shape with one starting note/rhythm
2. Drift and identify colored edible targets
3. Consume NPMCs and/or smaller shapes to grow
4. Body enlarges, soundtrack thickens, key may reinterpret
5. Metabolism accelerates as size increases
6. Manage prey choices, movement, and escape bursts
7. Avoid larger predators and avoid starving under attrition
8. Eventually die, cash out score, restart

The loop should create a feeling of mounting musical urgency and bodily instability.

---

## 16. Recommended local demo content

### 16.1 Must-have features

- bounded arena
- one controllable player organism
- 4–6 curated starter shapes
- NPMCs spawning randomly in the arena
- uniform 12-note distribution for NPMCs
- recent-note-window harmonic legality over 12 major + 12 minor
- vivid prey highlighting with result-key color
- washout for non-consumables
- metabolism using the selected formula
- emergency accelerate with cube shedding
- layered sound on consume
- score tracking
- polished camera/orientation readability

### 16.2 Nice-to-have after core is fun

- one simple predator AI organism
- one simple prey AI organism
- post-run summary screen
- starter shape selection screen
- basic replayability stats

### 16.3 Explicitly out of scope for first playable

- internet multiplayer
- shared persistent world simulation
- ranked matchmaking
- advanced AI ecology
- body persistence across sessions
- modes/scales beyond major/minor
- crafting or deliberate detachment systems

---

## 17. Technical architecture guidance for future online evolution

Even for the local demo, keep these boundaries clear.

### 17.1 Separate domains

Implement separate modules for:
- simulation state
- rendering state
- audio state
- account/progression state
- future network serialization

### 17.2 Simulation authority model

Design the simulation as if a future server will own:
- movement validation
- collisions
- consume legality
- harmonic legality
- score updates
- metabolism timers

This will reduce refactoring later.

### 17.3 Persistent identity (future)

The future shared-world service should support:
- global login/auth
- persistent player ID
- progression/stats/history
- regional hosting/shards
- continuous-world simulation rules

For MVP, do not persist the in-run body. Persisted identity is a future system.

---

## 18. Open risks and chosen mitigations

### 18.1 3D readability risk

**Risk**: players get lost in rotation/camera complexity.

**Mitigation**:
- third-person follow camera
- precision mode with snap rotation
- axis gizmo
- strong context-sensitive target rendering
- small arena and low speed early on

### 18.2 Real-time merge feel risk

**Risk**: merging feels arbitrary or too fiddly.

**Mitigation**:
- forgiving auto-consume on valid contact in first demo
- strong ghost preview
- simple starter/NPMC shapes first

### 18.3 Harmonic opacity risk

**Risk**: the player cannot understand why prey is or isn’t edible.

**Mitigation**:
- vivid color only for edible targets
- washed-out non-edibles
- result-key color preview
- small note-window HUD

### 18.4 Audio clutter risk

**Risk**: accumulated music becomes noisy.

**Mitigation**:
- limit foreground layers
- compress/soften older layers
- constrain timbre range in MVP

### 18.5 Shape ugliness under attrition risk

**Risk**: random shedding creates frustrating unreadable bodies.

**Mitigation**:
- weighted legal-cube removal rather than purely random removal
- curated starter/NPMC shapes

---

## 19. Implementation order

### Phase 1 — Body and world fundamentals
- voxel body representation
- shape validity and surface-cube caching
- bounded arena and simple drift
- player camera and movement

### Phase 2 — Harmonic and visual readability
- 12 major/minor key library
- recent-note-window legality system
- result-key prediction
- context-sensitive rendering

### Phase 3 — Consuming and shrinking
- valid contact detection
- full-union consume logic
- metabolism
- acceleration with shedding
- score rules

### Phase 4 — Audio and feel
- note/rhythm playback
- audio layering on consume
- tempo escalation
- feedback polish

### Phase 5 — Game loop and polish
- starter selection
- NPMC spawn tuning
- session/end-state handling
- optional simple AI predator

---

## 20. Success criteria for the local demo

The local demo is successful if playtests show that:

1. Players can control and orient their body without frequent confusion
2. Players quickly understand what is edible and what is dangerous
3. Consuming feels rewarding and understandable
4. Harmonic choices change player behavior in noticeable ways
5. Metabolism creates urgency without making growth feel pointless
6. The soundtrack becomes more compelling as the organism evolves
7. Players want “one more run” after death

---

## 21. Concise MVP rules reference

- Player starts as a curated 3×3×3 cavity-free sub-shape of 5–6 cubes
- NPMCs spawn as passive cavity-free 2×2×2 sub-shapes
- NPMC note distribution is uniform across the 12 pitch classes
- Only 12 major and 12 minor keys are valid harmonic states
- Only the last 4 unique pitch classes count for prey legality and key resolution
- A target is edible only if it is smaller and adding its note preserves at least one valid key
- If a consume succeeds, the full prey geometry is merged if the union is legal and cavity-free
- Consumer scores 0.5 × prey volume for full organisms; NPMCs score lower
- Consumed player scores 1.0 × their final volume
- Player loses 1 legal surface cube every `24 / sqrt(volume)` seconds
- Player may accelerate by shedding legal surface cubes for burst movement
- Edible targets are vividly colored by the resulting resolved key
- Irrelevant targets are washed out; dangerous predators remain strongly highlighted

---

## 22. One-sentence game statement

**CubusFatalis is a 3D online survival growth game where drifting voxel organisms consume harmonically compatible prey, mutate their musical identity, and fight metabolism and predators in a world where geometry and key determine what they can become.**
