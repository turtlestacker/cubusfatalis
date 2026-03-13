# CubusFatalis — Proposed Tech Stack

## 1. Purpose of this document

This document proposes a technical stack for **CubusFatalis** that supports:

1. a fast local prototype / vertical slice
2. a polished desktop-first game build
3. future migration toward an internet-accessible shared continuous world
4. persistent player identity across sessions
5. server-authoritative simulation in the online future

The stack is chosen to match the design constraints in `spec.md`:

- real-time 3D gameplay
- custom polycube / voxel-body simulation
- dynamic consume / merge legality checks
- camera and movement feel are critical
- procedural music/audio layering matters
- strong visual highlighting and post-processing are needed
- online evolution should be possible without a total rewrite

This recommendation favors **practical buildability** over novelty.

---

## 2. Executive recommendation

### Recommended primary stack

#### Client / local demo / future game runtime
- **Godot 4.x** as the game engine
- **GDScript + C#** hybrid codebase
- **C++ GDExtension** only for hot-path simulation code if profiling proves necessary

#### Future backend / online services
- **Go** for real-time simulation services and account services
- **PostgreSQL** for persistent account and progression data
- **Redis** for ephemeral coordination, caches, and session routing
- **Docker** for containerization
- **Kubernetes** only later if scale warrants it

#### Networking / transport (future)
- **WebSocket or ENet/UDP-style transport** depending deployment target
- authoritative game server simulation
- binary message serialization using **Protocol Buffers** or **FlatBuffers**

#### Build / CI / tooling
- **GitHub**
- **GitHub Actions**
- **just** or **Make** for developer task automation
- **pre-commit** hooks for formatting/linting

#### Art / content pipeline
- voxel/polycube geometry generated in-engine from data
- minimal DCC dependency at first
- optional **Blender** for promo assets and effects meshes

#### Audio
- Godot audio runtime + custom music-layer manager
- optional future integration with **FMOD** or **Wwise** only if the built-in pipeline proves insufficient

---

## 3. Why this stack

### 3.1 Why not optimize first for the shared online world?

Because the main unknowns are still gameplay unknowns:
- 3D control feel
n- readability of harmonic prey/threat logic
- whether real-time geometric swallowing feels good
- whether music accumulation is compelling

The first stack priority should therefore be:
- rapid iteration
- low ceremony
- easy gameplay scripting
- solid 3D tooling
- ability to extend into optimized/native code later

### 3.2 Why Godot 4

Godot 4 is a strong fit because it offers:
- modern 3D rendering
- controllable physics and scene graph access
- simple local iteration
- very fast scripting iteration in GDScript
- a workable C# path for stronger structure where needed
- native extension support for simulation hotspots
- easy export for desktop builds
- relatively low overhead for a small/medium independent project

It is especially suitable here because the game’s hard problems are not AAA photorealism; they are:
- custom body representation
- readability
- rules iteration
- audio/gameplay interplay

Godot is good at letting you build unusual gameplay systems quickly.

### 3.3 Why not Unreal as the primary recommendation?

Unreal is powerful, but for this project it is likely to increase friction early:
- more setup overhead
- slower iteration for core rule experimentation
- more complexity than is needed for the visual target
- C++ gameplay iteration burden for a small experimental prototype

Unreal becomes attractive only if the project later demands:
- very high-end rendering
- deep multiplayer tooling already aligned with your team expertise
- a larger engineering team comfortable in Unreal C++

### 3.4 Why not Unity as the primary recommendation?

Unity is also viable. If the team already has strong Unity experience, it could be a good fallback.

But absent that constraint, Godot has advantages for this concept:
- easier lightweight iteration
- less editor overhead
- strong control over custom data-driven gameplay
- clean extension path without adopting a large ECS/data-oriented architecture prematurely

### 3.5 Why Go for backend?

Future backend services will need:
- high concurrency
- clear deployment ergonomics
- low operational complexity
- strong network service performance
- simple binaries and containerization

Go is excellent for:
- account services
- matchmaking/session routing
- real-time simulation servers
- stateless API services
- operational simplicity

Rust is also viable, but Go is generally faster to build and maintain for service-heavy multiplayer infrastructure unless ultra-low-level optimization is a central requirement from day one.

---

## 4. Architectural philosophy

The game should be built as if it will eventually become a server-authoritative online game, even though the first deliverable is local.

That means separating:
- simulation rules
- rendering/presentation
- audio reactions
- persistence/account systems
- transport/network concerns

### 4.1 Key principle

**The simulation should be deterministic enough and isolated enough that a future server can run it headlessly.**

This does not require perfect lockstep determinism. It does require clear ownership of gameplay truth.

### 4.2 Recommended codebase split

Within the client/game project, structure code into modules such as:

- `core_sim/`
- `world/`
- `entities/`
- `harmonics/`
- `geometry/`
- `movement/`
- `audio/`
- `rendering/`
- `ui/`
- `tools/`
- `future_net/`

This helps avoid entangling engine scene code with game rules.

---

## 5. Client/runtime stack in detail

## 5.1 Engine: Godot 4.x

### Recommended version policy
- choose a current stable Godot 4 LTS-like stable branch if available
- avoid bleeding-edge experimental releases for production work
- lock engine version per milestone
- upgrade intentionally, not continuously

### Why Godot 4 specifically fits

- strong modern renderer
- usable compute/shader path if needed later
- good editor for rapid scene iteration
- scriptable tools for authoring starter shapes and NPMC definitions
- native access for custom voxel-body data structures

### Rendering mode

For desktop-first development:
- use **Forward+** renderer

Fallbacks later:
- Mobile renderer if lower-end devices matter
- compatibility renderer only if required

For the local prototype, optimize clarity over raw visual complexity.

---

## 5.2 Language strategy: GDScript + C# + optional C++

### Recommended split

#### GDScript
Use for:
- gameplay glue
- scene orchestration
- UI logic
- prototyping new interactions
- content scripts
- spawn tables and tuning data
- debug tools

GDScript is ideal while the systems are still changing rapidly.

#### C#
Use for:
- simulation subsystems that benefit from stronger typing and structure
- harmonic/key-resolution systems
- reusable data model code
- stat/account data model on the client
- more complex editor tooling if desired

C# provides better maintainability for medium-complexity systems.

#### C++ via GDExtension
Use only if profiling proves it necessary for:
- cavity checks
- merge legality checks
- voxel body surface recomputation
- broad-scale AI simulation later
- future headless simulation reuse

Do **not** start in C++. Profile first.

### Why a hybrid approach is best here

This project has both:
- fast-changing game feel logic
- potentially expensive geometry validation work

A hybrid stack lets you:
- move fast early
- optimize surgically later

---

## 5.3 Project structure in the Godot repo

Recommended top-level layout:

```text
cubusfatalis/
  game/
    scenes/
    scripts/
    assets/
    shaders/
    data/
    tools/
    tests/
  docs/
  prototypes/
  server/
  infra/
```

Within `game/`:

```text
game/
  scenes/
    world/
    entities/
    ui/
    fx/
  scripts/
    core_sim/
    geometry/
    harmonics/
    movement/
    rendering/
    audio/
    debug/
  data/
    starter_shapes/
    npmc_shapes/
    notes/
    rhythms/
    colors/
    tuning/
```

---

## 5.4 Data representation for bodies

This is one of the most important technical choices.

### Recommended body model

Represent each organism as:
- a set of occupied integer voxel coordinates in **local space**
- an origin/pivot
- orientation transform in world space
- cached metadata

Suggested core fields:

```text
BodyState
- voxels: set/list of Int3
- volume: int
- surface_voxels: set/list of Int3
- bounds_min: Int3
- bounds_max: Int3
- center_of_mass: Vector3
- active_note_window: list of pitch classes
- all_audio_layers: list of consumed musical layers
```

### Why local-space voxel coordinates

This makes it easier to:
- test union legality
- rotate shapes in 90° increments
- cache surface cubes
- serialize future network state
- support tool-authored starter shapes

### Recommended internal structure

For small and medium body sizes, a hash-set-like occupancy structure is fine.

Possible choices:
- hash set of packed integer coordinates
- sorted vector/array plus hash lookup cache
- bitset only for bounded local sub-problems, not the whole body generally

For MVP, use a packed integer hash set or dictionary-backed occupancy map.

---

## 5.5 Collision and physics strategy

Do **not** rely on generic rigid-body physics for core gameplay truth.

Use engine physics only as a support layer where helpful.

### Recommended model

- custom movement integration for organisms
- simple broad-phase collision volumes (AABB / sphere / capsule approximations)
- custom narrow-phase consume/merge checks using voxel-space tests

### Why custom simulation is preferable

The game’s important rules are not standard physics rules. They are:
- face contact
- volume comparison
- legal union
- cavity avoidance
- harmonic legality

Those should live in explicit game simulation code, not inside general-purpose rigid-body collision logic.

### Suggested approach

For each entity:
- maintain a broad-phase proxy (sphere or AABB)
- detect candidate contacts cheaply
- only run detailed voxel-face legality checks when candidate overlap is meaningful

---

## 5.6 Geometry algorithms

These algorithms are central.

### 5.6.1 Surface cube detection

Needed for:
- metabolism
- acceleration shedding
- visual previews
- attach opportunity hints

Algorithm:
- a voxel is surface if any of its 6 face-neighbors are empty

Cache and update after each consume/shedding event.

### 5.6.2 Connectivity check after cube removal

Needed for:
- legal attrition
- legal acceleration shedding

Algorithm:
- remove candidate cube virtually
- flood-fill from one remaining voxel
- valid if all remaining voxels reachable

Given expected MVP body sizes, this is affordable.

### 5.6.3 Cavity detection after merge

Needed for:
- full-union legality

Algorithm:
1. compute merged occupied set
2. build bounding box with 1-cell padding
3. flood-fill exterior empty space from outside the bounds
4. any unvisited empty cell inside bounds indicates a sealed cavity

This is robust and easy to reason about.

### 5.6.4 Face-contact detection

Needed for consume eligibility.

Algorithm:
- after candidate broad-phase overlap, compare transformed voxel faces between attacker and target
- require at least one face-to-face adjacency without overlap
- edge-only or corner-only contact is ignored

### 5.6.5 Rotation handling

Because precision mode uses 90° increments:
- precompute or efficiently apply axis-aligned rotation matrices in local voxel space
- avoid arbitrary voxel reprojection during precision docking logic

This is a major simplification and should be preserved.

---

## 5.7 Rendering stack in detail

### Visual goals
- strong readability
- clear silhouette
- attractive glow/pulse behavior
- good sense of depth in 3D
- low visual clutter

### Mesh strategy

Do not author separate hand-made meshes for each organism shape.

Recommended approach:
- generate body geometry procedurally from voxel occupancy
- start with simple visible cubes or greedy meshing

#### Option A: literal cubes per voxel
Pros:
- extremely easy
- great for prototype
- very readable

Cons:
- more draw calls/geometry if unoptimized

#### Option B: greedy meshing / merged faces
Pros:
- lower geometry cost
- cleaner look

Cons:
- more implementation work

Recommendation:
- start with **instanced cubes or simple generated visible faces**
- optimize later if required

### Material strategy

Need materials that support:
- washout/non-consumable state
- vivid result-key coloring
- predator highlight treatment
- rhythm pulse/emission
- player readability

Recommended shader features:
- base albedo/emissive controlled by gameplay state
- fresnel or rimlight for visibility
- pulse modulation on emissive
- alpha or dither fade for washed-out objects
- outline or shell effect for predators

### Post-processing

Use lightly. The game needs clarity more than spectacle.

Recommended early effects:
- mild bloom
- subtle depth fog for scale
- optional outline pass for important entities

Avoid heavy motion blur or aggressive chromatic effects.

---

## 5.8 Camera system implementation

The camera is a first-class system, not a side effect.

Recommended implementation:
- custom follow camera rig
- spring smoothing
- collision avoidance with environment bounds if needed
- target assist near relevant prey/predators
- optional precision-mode framing changes

Key camera features:
- preserve silhouette readability
- avoid disorienting spin under roll
- keep the forward intent legible
- allow fast reacquisition after bursts or collisions

### Additional aids
- axis gizmo in HUD or diegetic world UI
- candidate target markers
- projected docking face highlights

This is worth dedicated engineering time.

---

## 5.9 Audio stack in detail

### Recommended MVP audio runtime

Start with Godot’s built-in audio system plus a custom music-layer manager.

Why:
- enough for prototype and likely first production version
- no extra middleware complexity early
- direct control over dynamic layering rules

### What the audio system must do

- play the player’s base musical layer
- add note/rhythm layers on consume
- modulate tempo gradually
- spatialize nearby objects if useful
- keep output musically readable as layers accumulate

### Suggested internal music model

Represent layers as data:

```text
MusicLayer
- pitch_class
- rhythm_pattern_id
- instrument_id
- created_at
- weight
- active_foreground: bool
```

Then let a manager decide:
- what is audible now
- what is backgrounded
- how tempo evolves
- how result-key changes affect timbral or mix treatment

### Middleware question: FMOD/Wwise?

Use only if later needed.

Reasons not to start there:
- extra integration complexity
- extra toolchain burden
- prototype speed matters more right now

Reasons to adopt later if necessary:
- advanced adaptive mixing
- better authoring pipelines for larger teams
- sophisticated music state transitions

For now: built-in engine audio is the right first choice.

---

## 5.10 UI stack

Use Godot’s built-in UI system.

Needs:
- responsive HUD
- starter selection
- score screens
- result-key previews
- debugging overlays

Important debug UI for development:
- current resolved key
- active recent note window
- valid target count in range
- metabolism timer
- body volume
- candidate consume diagnostics

Strong debug tools will save a lot of time because the game’s rules are more complex than they initially appear.

---

## 6. Data-driven content design

A data-driven setup is important so balance and content can change without deep code edits.

### 6.1 Recommended data formats

Use human-readable source data during development:
- **JSON** or **TOML** or **YAML** for content definitions

Recommendation:
- use **JSON** for broad compatibility and simplicity
- use editor tools to validate it

### 6.2 Data that should be externalized

- starter shapes
- NPMC shapes
- key-color mappings
- rhythm pattern definitions
- note names and pitch-class mappings
- spawn rates
- metabolism tuning constants
- score multipliers
- camera tuning

### 6.3 Example shape definition

```json
{
  "id": "starter_hook_01",
  "display_name": "Hook",
  "voxels": [[0,0,0],[1,0,0],[2,0,0],[2,1,0],[2,1,1]],
  "start_notes": ["C"],
  "start_rhythm": "pulse_01"
}
```

### 6.4 Tooling recommendation

Build an in-engine authoring/debug tool for:
- previewing voxel shapes
- validating connectivity/cavity-free status
- tagging starter rosters
- previewing possible consume results

This will pay off quickly.

---

## 7. Testing strategy

This project needs more than manual playtesting.

### 7.1 Unit tests

Use unit tests for pure systems such as:
- key-resolution logic
- note-window legality rules
- cavity detection
- connectivity after cube removal
- score calculations
- metabolism interval calculations

These systems are ideal for automated testing because they are deterministic.

### 7.2 Property-based tests

Highly recommended for geometry algorithms.

Examples:
- removing a non-surface cube is never allowed
- cavity detector should reject known cavity examples
- valid starter shapes remain connected after legal transforms
- consume legality should be symmetric only where intended, not by accident

### 7.3 Golden test fixtures

Create a library of known body configurations:
- legal starter shapes
- illegal cavity examples
- expected merge results
- expected result-key transitions

These become your long-term safety net.

### 7.4 Playtest instrumentation

Collect debug telemetry during local prototype playtests:
- average time alive
- average final volume
- average number of consumes
- number of failed consume attempts
- number of confusion points if manually logged
- camera reset frequency if implemented

These metrics will help reveal whether players are understanding the systems.

---

## 8. Future online architecture

The local demo should not implement the full online stack, but the future architecture should be anticipated.

## 8.1 Recommended service decomposition

### Service 1: Account / Identity Service
Responsibilities:
- authentication
- player profile
- settings
- progression
- persistent identity

Recommended stack:
- Go
- PostgreSQL
- REST or gRPC API

### Service 2: Session / World Router
Responsibilities:
- route players to region/shard/world
- track active sessions
- coordinate reconnects
- directory of world instances

Recommended stack:
- Go
- Redis for ephemeral lookup and routing state

### Service 3: World Simulation Service
Responsibilities:
- authoritative simulation
- entity movement truth
- consume/merge legality
- harmonic legality
- score updates
- world spawning

Recommended stack:
- Go initially
- consider Rust only if profiling later justifies it

### Service 4: Analytics / Telemetry Pipeline
Responsibilities:
- gameplay metrics
- balance telemetry
- crash/session diagnostics

Recommended stack:
- simple event ingestion first
- PostgreSQL / ClickHouse / BigQuery later depending scale

---

## 8.2 Why not put the real-time simulation on the client later?

Because the game is highly cheat-sensitive.

The server must own:
- volume comparisons
- legal prey checks
- key state transitions
- score outcomes
- metabolism timing
- body geometry mutations

Otherwise cheating will be trivial and persistent identity will become meaningless.

---

## 8.3 Simulation-server language choice: Go vs Rust

### Go recommendation
Use Go first because:
- fast development
- excellent networking/concurrency
- simple operations
- easy deployment
- enough performance for many medium-scale real-time services

### Rust consideration
Adopt Rust only if:
- you require extremely high simulation density per machine
- deterministic performance under heavy world load becomes critical
- your team is already strong in Rust

In most real project timelines, Go is more likely to get the online world running sooner.

---

## 8.4 Network transport recommendation

### Local demo
No networking required.

### First online prototype
Use one of:
- reliable WebSockets for simplicity if targeting web + desktop quickly
- ENet/UDP-style transport for lower latency and more traditional action-game behavior

Recommendation:
- for desktop-first authoritative game, prefer **UDP-style real-time transport** if practical
- retain reliable side channels for important state and service messages

### Serialization
Use binary serialization.

Recommended options:
- **Protocol Buffers** for broad ecosystem support and schema evolution
- **FlatBuffers** only if you truly need zero-copy patterns

Recommendation:
- **Protocol Buffers** is the best default

---

## 8.5 Continuous world implications

A shared continuous world introduces hard future questions:
- body persistence on logout
- offline vulnerability
- shard design
- world population density
- long-lived simulation memory pressure

The tech stack above can support these questions, but they remain design questions as much as engineering questions.

The most important preparation now is to ensure the simulation code is not entangled with the local presentation layer.

---

## 9. Persistence and databases

## 9.1 PostgreSQL

Use PostgreSQL for:
- accounts
- profile/settings
- progression
- match/session summaries
- shape unlocks/cosmetics if they exist
- leaderboards metadata

Why PostgreSQL:
- mature
- reliable
- flexible enough for structured game service data
- strong ecosystem

### Suggested data domains
- `users`
- `profiles`
- `settings`
- `sessions`
- `run_summaries`
- `unlocks`
- `stats_lifetime`

## 9.2 Redis

Use Redis for:
- presence state
- session routing cache
- ephemeral matchmaking/router state
- hot world-directory lookups
- pub/sub only if useful, but avoid overusing it

Do not use Redis as the source of truth for durable account data.

## 9.3 Analytics store

Do not overbuild this initially.

Start with:
- append-only event logging to files or a relational table
- later graduate to a dedicated analytics database if scale warrants it

---

## 10. Deployment and infrastructure

## 10.1 Local development

Use:
- Godot locally for client
- Docker Compose for future backend local services
- PostgreSQL and Redis in containers

### Recommended local dev topology later

```text
client (Godot)
  -> account service (Go)
  -> router service (Go)
  -> world sim service (Go)
  -> postgres
  -> redis
```

For now, only the client/runtime matters.

## 10.2 Source control

Use Git with GitHub or GitLab.

Recommended repo strategy:
- monorepo until team/org scale proves otherwise

Why monorepo initially:
- easier coordination between client, tools, and future backend
- shared docs/specs live together
- simpler automation for a small team

## 10.3 CI/CD

Use GitHub Actions for:
- linting
- tests
- build validation
- packaging prototypes

Recommended CI jobs:
- unit tests for pure systems
- geometry algorithm tests
- content schema validation
- desktop build smoke test

## 10.4 Containers

Use Docker for all backend services.

Use Kubernetes only later if truly needed.

For early online tests:
- a few containerized services on managed VMs is likely enough
- do not prematurely build a large orchestration platform

---

## 11. Observability and diagnostics

This game will need good introspection because many systems interact.

## 11.1 Client diagnostics

Add debug overlays for:
- resolved key
- recent note window
- target legality status
- surface cube count
- metabolism countdown
- average frame time

## 11.2 Backend diagnostics later

Use structured logs from day one.

Recommended stack later:
- JSON logs
- OpenTelemetry for traces/metrics if online services mature
- Prometheus/Grafana only when the backend reaches a complexity that justifies them

## 11.3 Crash reporting

Add crash reporting once public testing begins.

For internal prototype stages, keep it simple with:
- local logs
- automatic repro data capture where possible

---

## 12. Security and identity

Since the future product includes persistent player identity, plan for a real authentication model.

## 12.1 Authentication recommendation

For the future online version, support:
- email/password or passwordless
- platform auth if applicable later
- short-lived access tokens + refresh tokens

Do not invent custom cryptography.

## 12.2 Account provider options

Use either:
- a managed identity provider if speed matters most
- or a small in-house auth service in Go if infrastructure control matters more

Recommendation:
- managed auth is reasonable unless there is a strong reason to self-host identity immediately

## 12.3 Anti-cheat philosophy

Do not depend on client trust.

Core rules that must be server-authoritative later:
- consume legality
- score assignment
- geometry mutation
- movement constraints
- volume changes

---

## 13. Team workflow and development process

## 13.1 Recommended development cadence

Use short iteration loops.

Suggested order:
1. movement/camera feel
2. edible vs non-edible readability
3. consume event quality
4. metabolism pacing
5. audio satisfaction
6. only then wider content and online prep

## 13.2 Branching model

Keep it simple:
- main branch always runnable
- short-lived feature branches
- PR reviews where possible

## 13.3 Content tuning workflow

Because balance will matter a lot, create a rapid tuning loop:
- editable JSON/TOML/Resource data
- in-editor reload where possible
- visible debug panels for live tuning

This will be more valuable than early optimization.

---

## 14. Risks of the proposed stack

## 14.1 Godot online scale concerns

The future massive continuous-world backend should not be implemented purely inside the Godot client project.

Mitigation:
- use Godot for the client/runtime
- use dedicated backend services for online simulation later

## 14.2 Hybrid-language complexity

Using GDScript + C# + optional C++ can become messy if boundaries are unclear.

Mitigation:
- define code ownership rules
- start with GDScript + C# only
- only introduce C++ after profiling

## 14.3 Custom geometry logic effort

The game requires custom geometry validation. There is no avoiding this.

Mitigation:
- isolate and test it thoroughly
- keep body sizes modest in MVP
- build fixture-based geometry tests early

## 14.4 Audio complexity creep

Adaptive music can consume a lot of production time.

Mitigation:
- keep layer types simple initially
- use built-in audio first
- solve for compelling, not maximal

---

## 15. Alternative stack options

If the team has strong prior expertise, these alternatives are valid.

### Option A — Unity stack
- Unity 6 / current LTS
- C# gameplay/client
- Go backend
- PostgreSQL + Redis

Choose this if:
- the team already ships efficiently in Unity
- you want a single strongly typed client language
- you have established Unity tooling/processes

### Option B — Unreal stack
- Unreal Engine 5
- C++ / Blueprints
- Go backend or Unreal dedicated server experiments

Choose this only if:
- the team already has real Unreal expertise
- visual fidelity and higher-end presentation are first-order goals
- iteration speed tradeoff is acceptable

### Option C — Web-first stack
- WebGPU/Three.js/Babylon.js client
- Go backend

Not recommended as the primary path because:
- 3D control/audio/performance iteration will likely be harder
- custom gameplay prototyping is slower than in a dedicated engine

---

## 16. Final recommendation

## Recommended local-demo stack

### Engine and languages
- **Godot 4.x**
- **GDScript** for rapid gameplay/UI/tool iteration
- **C#** for structured simulation subsystems and testable logic
- no C++ until profiling demands it

### Core implementation priorities
- custom body representation in local voxel coordinates
- custom consume/merge legality checks
- custom movement/camera system
- built-in audio runtime with dynamic layer manager
- data-driven starter/NPMC definitions
- strong debug tooling

### Tooling
- GitHub
- GitHub Actions
- JSON content definitions
- automated tests for harmonic and geometry logic

## Recommended future online stack

- **Go** services
- **PostgreSQL** for persistence
- **Redis** for ephemeral state/routing
- **Protocol Buffers** for schemas
- **Docker** for deployment
- region-hosted authoritative world/session servers

---

## 17. Bottom line

The best stack for CubusFatalis is one that lets you discover the game quickly, while preserving a clean path to an authoritative online future.

That means:

- **Godot 4 for the client and prototype/runtime**
- **GDScript + C# for iteration and structure**
- **custom geometry/harmonic simulation modules**
- **Go + PostgreSQL + Redis for future online services**

This stack is not the most fashionable or the most maximal. It is the one most likely to get a genuinely playable and extensible version of the game built without fighting the tools.
