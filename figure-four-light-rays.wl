(* Four-panel view: light rays in both directions and observed ages *)

(* constants *)
g = 9.80665;
c = 299792458;
yearSec = 365.25*24*3600;

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
          {Yellow, Dashed}, Line[{{0, emit}, pt}],
          {Yellow, PointSize[0.02]}, Point[{0, emit}],
          Text[Style[NumberForm[emit, {4, 1}], Yellow, 10, Bold], {0, emit}, {-1.2, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 10, Bold], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, RGBColor[0.35, 0.6, 1]},
    AxesLabel -> {"x (ly)", "t (yr)"},
    BaseStyle -> 14,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 500,
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
          {Cyan, Dashed}, Line[{pt, {0, arr}}],
          {Cyan, PointSize[0.02]}, Point[{0, arr}],
          Text[Style[NumberForm[arr, {4, 1}], Cyan, 10, Bold], {0, arr}, {-1.2, 0}]
        }],
      {t, tauMarks}
    ] // Flatten;
  labels =
    MapThread[
      Text[Style[NumberForm[#1, {4, 1}], Orange, 10, Bold], #2] &,
      {tauMarks, pts}
    ];
  ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, RGBColor[0.35, 0.6, 1]},
    AxesLabel -> {"x (ly)", "t (yr)"},
    BaseStyle -> 14,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 500,
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
    PlotStyle -> {RGBColor[0.35, 0.6, 1]},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 500,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
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
    PlotStyle -> {Orange},
    PlotRange -> {{0, prMax}, {0, prMax}},
    AspectRatio -> 1,
    ImageSize -> 500,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12},
    Epilog -> {
      {Gray, Dashed, Line[{{0, 0}, {diagMax, diagMax}}]}
    }
  ]
];

figure[tauMax_: 20] := GraphicsGrid[
  {
    {
      Style["Home \[Rule] traveler signals", White, 14, Bold],
      Style["Traveler age observed at home", White, 14, Bold]
    },
    {
      lightRaysHomeToTraveler[tauMax, 20],
      observedTravelerAge[tauMax]
    },
    {
      Style["Traveler \[Rule] home signals", White, 14, Bold],
      Style["Home age observed by traveler", White, 14, Bold]
    },
    {
      lightRaysTravelerToHome[tauMax, 20],
      observedHomeAge[tauMax]
    }
  },
  Spacings -> {0.8, 0.8},
  ImageMargins -> 30,
  Background -> Black
];

(* run *)
Export["twin-quasi-paradox-light-ray-grid.png", figure[], ImageResolution -> 300];
