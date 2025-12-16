(* Observed ages: traveler seen from home, and home seen from traveler *)

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

figure[tauMax_: 20] := Module[
  {sol = solve[tauMax], tauGrid, worldline, arrivalsAtHome, topData, topPlot, emitsToTraveler, bottomData, bottomPlot},
  tauGrid = Subdivide[0., tauMax, 400];
  worldline = {sol["x"][#], sol["t"][#]} & /@ tauGrid;

  (* signals from traveler to home: arrival time at x=0 versus traveler proper time *)
  arrivalsAtHome = sol["t"] /@ tauGrid + Abs[sol["x"] /@ tauGrid];
  topData = SortBy[Transpose[{arrivalsAtHome, tauGrid}], First];
  topPlot = ListLinePlot[
    topData,
    Frame -> True,
    FrameLabel -> {"Home proper time (yr)", "Observed traveler age (yr)"},
    PlotStyle -> {RGBColor[0.35, 0.6, 1]},
    PlotRange -> {{0, All}, {0, All}},
    ImageSize -> 600,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12}
  ];

  (* signals from home to traveler: emission time from x=0 that reaches traveler at a given tau *)
  emitsToTraveler = sol["t"] /@ tauGrid - Abs[sol["x"] /@ tauGrid];
  bottomData = Transpose[{tauGrid, emitsToTraveler}];
  bottomPlot = ListLinePlot[
    bottomData,
    Frame -> True,
    FrameLabel -> {"Traveler proper time (yr)", "Observed home age (yr)"},
    PlotStyle -> {Orange},
    PlotRange -> {{0, All}, {0, All}},
    ImageSize -> 600,
    GridLines -> Automatic,
    Background -> Black,
    FrameStyle -> White,
    BaseStyle -> {White, 12}
  ];

  GraphicsGrid[
    {
      {Style["Observed traveler age vs home time", White, 14, Bold]},
      {topPlot},
      {Style["Observed home age vs traveler time", White, 14, Bold]},
      {bottomPlot}
    },
    Spacings -> {0.5, 0.3},
    Background -> Black
  ]
];

(* run *)
Export["twin-quasi-paradox-observed-ages.png", figure[]];
