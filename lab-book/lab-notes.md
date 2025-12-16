# Twin Quasi-Paradox Lab Book (Using Codex with WolframKernel)

## Overview
This notebook documents the Codex-driven exploration of the Twin (Quasi) Paradox using WolframKernel. It captures the physics setup, numerical and visualization methods, execution workflow (including Codex CLI constraints), and the evolution of figures. All referenced code and figures are self-contained in this `lab-book` directory.

## Physical Model
- **Scenario**: Piecewise-constant proper accelerations: `{ {0,5, +0.3}, {5,15, -0.3}, {15,20, +0.3} }` in ly/yr^2.
- **Equations**: Proper-time ODEs for position `x(τ)`, coordinate time `t(τ)`, and rapidity `η(τ)`:
  - `x' = Sinh[η]`, `t' = Cosh[η]`, `η' = a(τ)` with `a(τ)` piecewise.
  - Initial conditions: `x(0)=0`, `t(0)=0`, `η(0)=0`.
- **Numerics**: `NDSolveValue` with residual simplification and no discontinuity processing; solutions stored as pure functions for `{x,t,eta}`.

## The Physics of Time Dilation (Signature − + + +)
- Minkowski line element (1+1 for our plots, `c=1` in ly/yr units):
  $$
  ds^2 = -\,dt^2 + dx^2 = -\,d\tau^2
  $$
  Proper time is the negative norm of the spacetime interval; the spatial part enters with a minus sign in this signature.
- For a timelike worldline with velocity $v = dx/dt$:
  $$
  d\tau = dt\,\sqrt{1 - v^2} \quad\Rightarrow\quad \gamma = \frac{dt}{d\tau} = \frac{1}{\sqrt{1 - v^2}}
  $$
- Rapidity $\eta$ linearizes velocity addition and encodes boosts:
  $$
  v = \tanh \eta,\quad \gamma = \cosh \eta,\quad \gamma v = \sinh \eta
  $$
  so the cosh–sinh pair automatically satisfies $\cosh^2 \eta - \sinh^2 \eta = 1$. In proper-time form,
  $$
  \frac{dt}{d\tau} = \cosh \eta,\quad \frac{dx}{d\tau} = \sinh \eta,\quad \eta'(\tau) = a(\tau)
  $$
  which are exactly the ODEs integrated in the scripts.

## Simultaneity vs. Light Signals
- **No frame-independent “now”**: In SR, simultaneity at a distance is convention-dependent (e.g., Einstein sync). It’s a useful foliation for bookkeeping but not an observable.
- **Einstein sync in one sentence**: Send a light pulse from A at time $t_A$, it reflects at B, and returns to A at time $t'_A$; assign B’s event the time $(t_A + t'_A)/2$. Do that everywhere and you get the usual flat hyperplanes of constant time in an inertial frame. “According to this frame, that distant event is happening now” means “according to this chosen sync convention and its foliation.”
- **Light-signal view (operational)**: What the traveler can actually know is what arrives on their worldline via light; that’s what the light-ray figures show—causal observations of home’s aging.
- **Simultaneity view (inferred)**: Lines of simultaneity assign a “now” to distant events from a chosen frame. The simultaneity figures show inferred home/traveler times, not measured ones.
- **Causal grid vs. foliation**: The “correct” causal structure is light cones and spacelike elsewhere; there’s no canonical grid outside the cone. Use light signals for physical observables; use simultaneity slices for frame-based inference, keeping in mind they’re a choice, not physics.

### Lorentz Boosts (Matrix Form)
- Standard boost in $(t, x)$ with velocity $v$ (here $c=1$):
  $$
  \begin{pmatrix}
  t' \\\\ x'
  \end{pmatrix}
  =
  \begin{pmatrix}
  \gamma & -\gamma v \\\\
  -\gamma v & \gamma
  \end{pmatrix}
  \begin{pmatrix}
  t \\\\ x
  \end{pmatrix},
  \quad \gamma = \frac{1}{\sqrt{1 - v^2}}.
  $$
- Rapidity form (same boost) with $\gamma = \cosh \eta$, $\gamma v = \sinh \eta$:
  $$
  \begin{pmatrix}
  t' \\\\ x'
  \end{pmatrix}
  =
  \begin{pmatrix}
  \cosh \eta & -\,\sinh \eta \\\\
  -\,\sinh \eta & \cosh \eta
  \end{pmatrix}
  \begin{pmatrix}
  t \\\\ x
  \end{pmatrix},
  \quad \eta = \operatorname{arctanh}(v).
  $$
  The rapidity parameterizes boosts additively: composing boosts amounts to adding rapidities, which is why the ODEs track $\eta(\tau)$ directly.

## Visualization Themes
- **Light-ray grids** (`figure-four-light-rays.wl`): Uses actual light signals between traveler and home; overlays home worldline; plots observed ages vs proper times.
- **Light-ray grids (2-yr markers)** (`figure-four-light-rays-2yr.wl`): Same as above but traveler markers every 2 years to reduce clutter.
- **Simultaneity grids** (`figure-four-simultaneity.wl`): Uses simultaneity lines instead of light signals; plots inferred (not observed) times from each frame.
- **Shared styling**: Dark background, squared axes, diagonal references on age plots, higher DPI export (1200), consistent padding and typography.

## Execution Notes (Codex + WolframKernel)
- **Kernel invocation**: `WolframKernel -noprompt -run 'PacletManager`$AllowInternet=True; Get["<file>.wl"]; Exit[]'`
- **Paclets/Network**: Plot themes and imports can trigger paclet downloads; when sandboxed, enable network or prefetch. We set `PacletManager`$AllowInternet=True` when needed.
- **Configuration**: When using `wolframscript`, set `WOLFRAMSCRIPT_CONFIGURATIONPATH` and `WOLFRAMSCRIPT_KERNELPATH` explicitly; direct `WolframKernel -run` is simpler for headless exports.
- **Process lifecycle**: Always terminate with `Exit[]` to avoid stray kernels; `-noprompt` prevents interactive waits.
- **Watcher workaround**: Commands were queued to a user-run watcher file for GUI `mimeopen`; not required for batch runs.

## Watcher Mechanism (Insecure Convenience)
- During this session a user-run “watcher” tailed a file (e.g., `/tmp/codex-commands`) and executed each line via `sh -c` to open PNGs with `mimeopen` in a GUI context.
- This is **not secure**: anything written to that file executes as the user. Use only in a disposable, trusted environment; disable when not needed.
- A minimal watcher example (do **not** use in untrusted settings):
  ```bash
  watchfile=/tmp/codex-commands
  tail -f "$watchfile" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    printf '[cmd] %s\n' "$line"
    sh -c "$line"
  done
  ```
- For normal batch workflows, run `WolframKernel -run` directly and inspect outputs without any watcher.

## Continuation Notes (Prompt to Self)
```
You are Codex as a calm, concise, careful coding partner. Stick to short, factual status; prefer commands over chatter; warn clearly about unsafe steps.

Workflow recap:
- Code lives in lab-book: figure-four-light-rays.wl, figure-four-light-rays-2yr.wl, figure-four-simultaneity.wl, plus PNGs at 1200 DPI.
- Run figures with WolframKernel: WolframKernel -noprompt -run 'PacletManager`$AllowInternet=True; Get["<script>.wl"]; Exit[]'. Always include Exit[] and -noprompt to avoid hanging kernels.
- If using wolframscript, set WOLFRAMSCRIPT_CONFIGURATIONPATH to the file and WOLFRAMSCRIPT_KERNELPATH=/usr/local/bin/WolframKernel. Direct WolframKernel is simpler here.
- Network/paclets: Styled plots may fetch paclets; allow network when exporting. If offline, set PacletManager`$AllowInternet=False and avoid theme-dependent styles.
- Processes: After runs, check for stray WolframKernel PIDs; keep commands non-interactive.

Permissions and confirmations:
- Normal exports: default sandbox. Request network only when paclets/themes needed. Prompt user before any risky action (deletes, watcher setup, process kills beyond strays).
- Avoid watcher unless necessary; prefer direct local viewing.

Watcher (insecure; use only if user insists):
  watchfile=/tmp/codex-commands
  tail -f "$watchfile" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    printf '[cmd] %s\n' "$line"
    sh -c "$line"
  done
Warn that anything written executes as the user.

Better: open figures directly with GNOME image viewer (e.g., xdg-open <png> or gnome-open <png>); it auto-refreshes on overwrite, no watcher needed.

Where to look: main branch (latest commits), lab-book/ for self-contained assets.
Next ideas: new accel scenarios, PDF/markdown figure bundle, richer annotations, simple make/script to regen all PNGs.
```

## How to Reproduce Figures
From `lab-book`:
```bash
# Light-ray grid (1-yr markers)
WolframKernel -noprompt -run 'PacletManager`$AllowInternet=True; Get["figure-four-light-rays.wl"]; Exit[]'

# Light-ray grid (2-yr markers)
WolframKernel -noprompt -run 'PacletManager`$AllowInternet=True; Get["figure-four-light-rays-2yr.wl"]; Exit[]'

# Simultaneity grid
WolframKernel -noprompt -run 'PacletManager`$AllowInternet=True; Get["figure-four-simultaneity.wl"]; Exit[]'
```
Exports:
- `twin-quasi-paradox-light-ray-grid.png`
- `twin-quasi-paradox-light-ray-grid-2yr.png`
- `twin-quasi-paradox-simultaneity-grid.png`

## Figures
- **Light rays (1 yr)**:
  - File: `twin-quasi-paradox-light-ray-grid.png`
  - Preview:
    ![Light rays 1 yr](twin-quasi-paradox-light-ray-grid.png)

- **Light rays (2 yr)**:
  - File: `twin-quasi-paradox-light-ray-grid-2yr.png`
  - Preview:
    ![Light rays 2 yr](twin-quasi-paradox-light-ray-grid-2yr.png)

- **Simultaneity**:
  - File: `twin-quasi-paradox-simultaneity-grid.png`
  - Preview:
    ![Simultaneity](twin-quasi-paradox-simultaneity-grid.png)

## Full Code Listings

### figure-four-light-rays.wl
```wolfram
(* Four-panel view: light rays in both directions and observed ages *)

(* constants *)
g = 9.80665;
c = 299792458;
yearSec = 365.25*24*3600;
travColor = RGBColor[0.35, 0.6, 1];
homeColor = Orange;
plotPad = {{55, 15}, {70, 40}};

(* scenario: {tauStart, tauEnd, accelLyPerYear2} *)
scenario = {{0, 5, 0.3}, {5, 15, -0.3}, {15, 20, 0.3}};

(* numeric acceleration *)
Clear[aFun];
aFun[t_?NumericQ] := N@Piecewise[({#3, #1 <= t < #2} &) @@@ scenario, 0];

(* solver *)
solve[tauMax_] := Module[{sol},
  sol = NDSolveValue[
    {
      x'[\[Tau]] == Sinh[\[Eta][\[Tau]]],
      t'[\[Tau]] == Cosh[\[Eta][\[Tau]]],
      \[Eta]'[\[Tau]] == aFun[\[Tau]],
      x[0.] == 0., t[0.] == 0., \[Eta][0.] == 0.
    },
    {x, t, \[Eta]}, {\[Tau], 0., tauMax},
    Method -> {"EquationSimplification" -> "Residual", "DiscontinuityProcessing" -> False}
  ];
  <|"x" -> sol[[1]], "t" -> sol[[2]], "eta" -> sol[[3]], "tauMax" -> tauMax|>
];

lightRaysHomeToTraveler[tauMax_: 20, n_: 20] := Module[
  {sol = solve[tauMax], tauMarks, pts, lightRays, labels, homeLine},
  tauMarks = Subdivide[0., tauMax, n];
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  homeLine = {homeColor, Thick, Line[{{0, 0}, {0, sol["t"][tauMax]}}]};
  lightRays =
    Table[
      With[{pt = {sol["x"][t], sol["t"][t]},
            emit = sol["t"][t] - Abs[sol["x"][t]]},
        {
          {homeColor, Dashed}, Line[{{0, emit}, pt}],
          {homeColor, PointSize[0.01]}, Point[{0, emit}],
          Text[Style[NumberForm[emit, {4, 1}], homeColor, 7.5], {0, emit}, {-1.1, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 7.5], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, travColor},
    Frame -> True,
    FrameLabel -> {"x (ly)", "t (yr)"},
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Axes -> False,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Traveler → home signals", White, 14, Bold],
    Prolog -> Join[{homeLine}, lightRays],
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

lightRaysTravelerToHome[tauMax_: 20, n_: 20] := Module[
  {sol = solve[tauMax], tauMarks, pts, lightRays, labels, homeLine},
  tauMarks = Subdivide[0., tauMax, n];
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  homeLine = {homeColor, Thick, Line[{{0, 0}, {0, sol["t"][tauMax]}}]};
  lightRays =
    Table[
      With[{pt = {sol["x"][t], sol["t"][t]},
            arr = sol["t"][t] + Abs[sol["x"][t]]},
        {
          {travColor, Dashed}, Line[{pt, {0, arr}}],
          {travColor, PointSize[0.01]}, Point[{0, arr}],
          Text[Style[NumberForm[arr, {4, 1}], travColor, 7.5], {0, arr}, {-1.1, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 7.5], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, travColor},
    Frame -> True,
    FrameLabel -> {"x (ly)", "t (yr)"},
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Axes -> False,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Home → traveler signals", White, 14, Bold],
    Prolog -> Join[{homeLine}, lightRays],
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

observedTravelerAge[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, arrivalsAtHome, data, diagMax, prMax},
  tauGrid = Subdivide[0., tauMax, 400];
  arrivalsAtHome = sol["t"] /@ tauGrid + Abs[sol["x"] /@ tauGrid];
  data = SortBy[Transpose[{arrivalsAtHome, tauGrid}], First];
  diagMax = Max[First /@ data];
  prMax = diagMax;
  ListLinePlot[
    data,
    Frame -> True,
    FrameLabel -> {"Home proper time (yr)", "Observed traveler age (yr)"},
    PlotStyle -> {travColor},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    PlotLabel -> Style["Traveler age observed at home", White, 14, Bold],
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

observedHomeAge[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, emitsToTraveler, data, diagMax, prMax},
  tauGrid = Subdivide[0., tauMax, 400];
  emitsToTraveler = sol["t"] /@ tauGrid - Abs[sol["x"] /@ tauGrid];
  data = Transpose[{tauGrid, emitsToTraveler}];
  diagMax = Max[tauMax, Max[Last /@ data]];
  prMax = diagMax;
  ListLinePlot[
    data,
    Frame -> True,
    FrameLabel -> {"Traveler proper time (yr)", "Observed home age (yr)"},
    PlotStyle -> {homeColor},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    PlotLabel -> Style["Home age observed by traveler", White, 14, Bold],
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

figure[tauMax_: 20] := GraphicsGrid[
  {
    {
      lightRaysHomeToTraveler[tauMax, 20],
      observedHomeAge[tauMax]
    },
    {
      lightRaysTravelerToHome[tauMax, 20],
      observedTravelerAge[tauMax]
    }
  },
  Spacings -> {1.0, 1.0},
  Background -> Black
];

(* run *)
Export["twin-quasi-paradox-light-ray-grid.png", figure[], ImageResolution -> 1200];
```

### figure-four-light-rays-2yr.wl
```wolfram
(* Four-panel view with 2-year traveler markers: light rays in both directions and observed ages *)

(* constants *)
g = 9.80665;
c = 299792458;
yearSec = 365.25*24*3600;
travColor = RGBColor[0.35, 0.6, 1];
homeColor = Orange;
plotPad = {{55, 15}, {70, 40}};

(* scenario: {tauStart, tauEnd, accelLyPerYear2} *)
scenario = {{0, 5, 0.3}, {5, 15, -0.3}, {15, 20, 0.3}};

(* numeric acceleration *)
Clear[aFun];
aFun[t_?NumericQ] := N@Piecewise[({#3, #1 <= t < #2} &) @@@ scenario, 0];

(* solver *)
solve[tauMax_] := Module[{sol},
  sol = NDSolveValue[
    {
      x'[\[Tau]] == Sinh[\[Eta][\[Tau]]],
      t'[\[Tau]] == Cosh[\[Eta][\[Tau]]],
      \[Eta]'[\[Tau]] == aFun[\[Tau]],
      x[0.] == 0., t[0.] == 0., \[Eta][0.] == 0.
    },
    {x, t, \[Eta]}, {\[Tau], 0., tauMax},
    Method -> {"EquationSimplification" -> "Residual", "DiscontinuityProcessing" -> False}
  ];
  <|"x" -> sol[[1]], "t" -> sol[[2]], "eta" -> sol[[3]], "tauMax" -> tauMax|>
];

lightRaysHomeToTraveler[tauMax_: 20, n_: 10] := Module[
  {sol = solve[tauMax], tauMarks, pts, lightRays, labels, homeLine},
  tauMarks = Subdivide[0., tauMax, n]; (* 2-year steps when tauMax=20 and n=10 *)
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  homeLine = {homeColor, Thick, Line[{{0, 0}, {0, sol["t"][tauMax]}}]};
  lightRays =
    Table[
      With[{pt = {sol["x"][t], sol["t"][t]},
            emit = sol["t"][t] - Abs[sol["x"][t]]},
        {
          {homeColor, Dashed}, Line[{{0, emit}, pt}],
          {homeColor, PointSize[0.01]}, Point[{0, emit}],
          Text[Style[NumberForm[emit, {4, 1}], homeColor, 7.5], {0, emit}, {-1.1, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 7.5], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, travColor},
    Frame -> True,
    FrameLabel -> {"x (ly)", "t (yr)"},
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Axes -> False,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Traveler → home signals", White, 14, Bold],
    Prolog -> Join[{homeLine}, lightRays],
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

lightRaysTravelerToHome[tauMax_: 20, n_: 10] := Module[
  {sol = solve[tauMax], tauMarks, pts, lightRays, labels, homeLine},
  tauMarks = Subdivide[0., tauMax, n]; (* 2-year steps *)
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  homeLine = {homeColor, Thick, Line[{{0, 0}, {0, sol["t"][tauMax]}}]};
  lightRays =
    Table[
      With[{pt = {sol["x"][t], sol["t"][t]},
            arr = sol["t"][t] + Abs[sol["x"][t]]},
        {
          {travColor, Dashed}, Line[{pt, {0, arr}}],
          {travColor, PointSize[0.01]}, Point[{0, arr}],
          Text[Style[NumberForm[arr, {4, 1}], travColor, 7.5], {0, arr}, {-1.1, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 7.5], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, travColor},
    Frame -> True,
    FrameLabel -> {"x (ly)", "t (yr)"},
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Axes -> False,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Home → traveler signals", White, 14, Bold],
    Prolog -> Join[{homeLine}, lightRays],
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

observedTravelerAge[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, arrivalsAtHome, data, diagMax, prMax},
  tauGrid = Subdivide[0., tauMax, 400];
  arrivalsAtHome = sol["t"] /@ tauGrid + Abs[sol["x"] /@ tauGrid];
  data = SortBy[Transpose[{arrivalsAtHome, tauGrid}], First];
  diagMax = Max[First /@ data];
  prMax = diagMax;
  ListLinePlot[
    data,
    Frame -> True,
    FrameLabel -> {"Home proper time (yr)", "Observed traveler age (yr)"},
    PlotStyle -> {travColor},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    PlotLabel -> Style["Traveler age observed at home", White, 14, Bold],
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

observedHomeAge[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, emitsToTraveler, data, diagMax, prMax},
  tauGrid = Subdivide[0., tauMax, 400];
  emitsToTraveler = sol["t"] /@ tauGrid - Abs[sol["x"] /@ tauGrid];
  data = Transpose[{tauGrid, emitsToTraveler}];
  diagMax = Max[tauMax, Max[Last /@ data]];
  prMax = diagMax;
  ListLinePlot[
    data,
    Frame -> True,
    FrameLabel -> {"Traveler proper time (yr)", "Observed home age (yr)"},
    PlotStyle -> {homeColor},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    PlotLabel -> Style["Home age observed by traveler", White, 14, Bold],
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

figure[tauMax_: 20] := GraphicsGrid[
  {
    {
      lightRaysHomeToTraveler[tauMax, 10],
      observedHomeAge[tauMax]
    },
    {
      lightRaysTravelerToHome[tauMax, 10],
      observedTravelerAge[tauMax]
    }
  },
  Spacings -> {1.0, 1.0},
  Background -> Black
];

(* run *)
Export["twin-quasi-paradox-light-ray-grid-2yr.png", figure[], ImageResolution -> 1200];
```

### figure-four-simultaneity.wl
```wolfram
(* Four-panel view using simultaneity lines instead of light signals *)

(* constants *)
g = 9.80665;
c = 299792458;
yearSec = 365.25*24*3600;
travColor = RGBColor[0.35, 0.6, 1];
homeColor = Orange;
plotPad = {{55, 15}, {70, 40}};

(* scenario: {tauStart, tauEnd, accelLyPerYear2} *)
scenario = {{0, 5, 0.3}, {5, 15, -0.3}, {15, 20, 0.3}};

(* numeric acceleration *)
Clear[aFun];
aFun[t_?NumericQ] := N@Piecewise[({#3, #1 <= t < #2} &) @@@ scenario, 0];

(* solver *)
solve[tauMax_] := Module[{sol},
  sol = NDSolveValue[
    {
      x'[\[Tau]] == Sinh[\[Eta][\[Tau]]],
      t'[\[Tau]] == Cosh[\[Eta][\[Tau]]],
      \[Eta]'[\[Tau]] == aFun[\[Tau]],
      x[0.] == 0., t[0.] == 0., \[Eta][0.] == 0.
    },
    {x, t, \[Eta]}, {\[Tau], 0., tauMax},
    Method -> {"EquationSimplification" -> "Residual", "DiscontinuityProcessing" -> False}
  ];
  <|"x" -> sol[[1]], "t" -> sol[[2]], "eta" -> sol[[3]], "tauMax" -> tauMax|>
];

(* traveler simultaneity: lines defined by t - v x = const *)
travelerSimultaneity[tauMax_: 20, n_: 20] := Module[
  {sol = solve[tauMax], tauMarks, pts, v, b, lines, labels, homeLine},
  tauMarks = Subdivide[0., tauMax, n];
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  v[t_] := Tanh[sol["eta"][t]];
  b[t_] := sol["t"][t] - v[t] * sol["x"][t];
  homeLine = {homeColor, Thick, Line[{{0, 0}, {0, sol["t"][tauMax]}}]};
  lines =
    Table[
      With[{vv = v[t], bb = b[t]},
        {
          {homeColor, Dashed}, Line[{{-1, vv*(-1) + bb}, {10, vv*10 + bb}}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 7.5], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, travColor},
    Frame -> True,
    FrameLabel -> {"x (ly)", "t (yr)"},
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Axes -> False,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Traveler → home simultaneity", White, 14, Bold],
    Prolog -> Join[{homeLine}, lines],
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

(* home simultaneity: horizontal lines (t = const) in home frame *)
homeSimultaneity[tauMax_: 20, n_: 20] := Module[
  {sol = solve[tauMax], tauMarks, pts, lines, labels, homeLine},
  tauMarks = Subdivide[0., tauMax, n];
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  homeLine = {homeColor, Thick, Line[{{0, 0}, {0, sol["t"][tauMax]}}]};
  lines =
    Table[
      {homeColor, Dashed, Line[{{-1, sol["t"][t]}, {10, sol["t"][t]}}]},
      {t, tauMarks}
    ];
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 7.5], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, travColor},
    Frame -> True,
    FrameLabel -> {"x (ly)", "t (yr)"},
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Axes -> False,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Home → traveler simultaneity", White, 14, Bold],
    Prolog -> Join[{homeLine}, lines],
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

(* inferred ages via simultaneity *)
inferredHomeAgeFromTraveler[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, bVals, data, diagMax, prMax},
  tauGrid = Subdivide[0., tauMax, 400];
  bVals = sol["t"] /@ tauGrid - Tanh[sol["eta"] /@ tauGrid] * (sol["x"] /@ tauGrid);
  data = Transpose[{tauGrid, bVals}];
  diagMax = Max[tauMax, Max[bVals]];
  prMax = diagMax;
  ListLinePlot[
    data,
    Frame -> True,
    FrameLabel -> {"Traveler proper time (yr)", "Inferred home time (yr)"},
    PlotStyle -> {homeColor},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    PlotLabel -> Style["Home time inferred by traveler", White, 14, Bold],
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

inferredTravelerAgeFromHome[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, tGrid, tauOfT, data, diagMax, prMax},
  tauGrid = Subdivide[0., tauMax, 400];
  tGrid = sol["t"] /@ tauGrid;
  tauOfT = Interpolation[Transpose[{tGrid, tauGrid}], InterpolationOrder -> 1];
  data = Transpose[{tGrid, tauGrid}];
  diagMax = Max[Max[tGrid], Max[tauGrid]];
  prMax = diagMax;
  ListLinePlot[
    data,
    Frame -> True,
    FrameLabel -> {"Home proper time (yr)", "Inferred traveler time (yr)"},
    PlotStyle -> {travColor},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 840,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    PlotLabel -> Style["Traveler time inferred by home", White, 14, Bold],
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

figure[tauMax_: 20] := GraphicsGrid[
  {
    {
      travelerSimultaneity[tauMax, 20],
      inferredHomeAgeFromTraveler[tauMax]
    },
    {
      homeSimultaneity[tauMax, 20],
      inferredTravelerAgeFromHome[tauMax]
    }
  },
  Spacings -> {1.0, 1.0},
  Background -> Black
];

(* run *)
Export["twin-quasi-paradox-simultaneity-grid.png", figure[], ImageResolution -> 1200];
```
