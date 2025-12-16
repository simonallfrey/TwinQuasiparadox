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
    PlotLabel -> Style["Traveler \[Rule] home simultaneity", White, 14, Bold],
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
    PlotLabel -> Style["Home \[Rule] traveler simultaneity", White, 14, Bold],
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
