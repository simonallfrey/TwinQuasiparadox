(* Four-panel view: light rays in both directions and observed ages *)

(* constants *)
g = 9.80665;
c = 299792458;
yearSec = 365.25*24*3600;
travColor = RGBColor[0.35, 0.6, 1];
homeColor = Orange;
plotPad = {{55, 15}, {70, 50}};

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
  {sol = solve[tauMax], tauMarks, pts, lightRays, labels},
  tauMarks = Subdivide[0., tauMax, n];
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  lightRays =
    Table[
      With[{pt = {sol["x"][t], sol["t"][t]},
            emit = sol["t"][t] - Abs[sol["x"][t]]},
        {
          {homeColor, Dashed}, Line[{{0, emit}, pt}],
          {homeColor, PointSize[0.012]}, Point[{0, emit}],
          Text[Style[NumberForm[emit, {4, 1}], homeColor, 8], {0, emit}, {-1.2, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 8], #2] &,
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
    ImageSize -> 780,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Home \[Rule] traveler signals", White, 14, Bold],
    Prolog -> lightRays,
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ]
];

lightRaysTravelerToHome[tauMax_: 20, n_: 20] := Module[
  {sol = solve[tauMax], tauMarks, pts, lightRays, labels},
  tauMarks = Subdivide[0., tauMax, n];
  pts = {sol["x"][#], sol["t"][#]} & /@ tauMarks;
  lightRays =
    Table[
      With[{pt = {sol["x"][t], sol["t"][t]},
            arr = sol["t"][t] + Abs[sol["x"][t]]},
        {
          {travColor, Dashed}, Line[{pt, {0, arr}}],
          {travColor, PointSize[0.012]}, Point[{0, arr}],
          Text[Style[NumberForm[arr, {4, 1}], travColor, 8], {0, arr}, {-1.2, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 8], #2] &,
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
    ImageSize -> 780,
    PlotRangePadding -> Scaled[0.05],
    ImagePadding -> plotPad,
    FrameTicksStyle -> White,
    GridLines -> Automatic,
    PlotLabel -> Style["Traveler \[Rule] home signals", White, 14, Bold],
    Prolog -> lightRays,
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
    ImageSize -> 780,
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
    ImageSize -> 780,
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
      observedTravelerAge[tauMax]
    },
    {
      lightRaysTravelerToHome[tauMax, 20],
      observedHomeAge[tauMax]
    }
  },
  Spacings -> {1.0, 1.0},
  Background -> Black
];

(* run *)
Export["twin-quasi-paradox-light-ray-grid.png", figure[], ImageResolution -> 600];
