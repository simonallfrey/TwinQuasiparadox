(* Signals from traveler back to stay-at-home: light rays from traveler markers to x = 0 *)

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

(* plot builder with traveler-to-home light rays *)
figure[tauMax_: 20, n_: 20] := Module[
  {sol = solve[tauMax], tauMarks, pts, arrivalAtHome, lightRays, labels, legend, plot},
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
  arrivalAtHome = sol["t"][tauMax] + Abs[sol["x"][tauMax]];

  legend = Placed[
    SwatchLegend[
      {
        Directive[Thick, RGBColor[0.35, 0.6, 1]],
        Directive[DarkBlue, PointSize[0.03]],
        Directive[Cyan, Dashed],
        Directive[Cyan, PointSize[0.02]]
      },
      {
        "Traveler worldline",
        "Equal \[CapitalDelta]\[Tau] markers (1 yr)",
        "Light ray to x = 0",
        "Arrival time at x = 0"
      },
      LegendMarkers -> {
        {Graphics[{Line[{{0, 0}, {1, 0}}]}], 20},
        {Graphics[{Disk[{0, 0}, 1]}], 12},
        {Graphics[{Line[{{0, 0}, {1, 0}}]}], 20},
        {Graphics[{Disk[{0, 0}, 1]}], 12}
      },
      LabelStyle -> Directive[White, 12],
      LegendFunction -> (Framed[#, Background -> Black, FrameStyle -> Gray, FrameMargins -> 8] &)
    ],
    {Right, 0.85}
  ];

  plot = ParametricPlot[
    {sol["x"][\[Tau]], sol["t"][\[Tau]]}, {\[Tau], 0, tauMax},
    PlotStyle -> {Thick, RGBColor[0.35, 0.6, 1]},
    AxesLabel -> {"x (ly)", "t (yr)"},
    BaseStyle -> 14,
    PlotRange -> {{-1, 10}, {0, All}},
    AspectRatio -> 1,
    ImageSize -> 600,
    Prolog -> lightRays,
    Epilog -> {{DarkBlue, PointSize[0.03], Point[pts]}, labels},
    Background -> Black
  ];

  Column[
    {
      Style["The Twin (Quasi)Paradox — signals to home", White, 20, Bold],
      Legended[plot, legend],
      Style[
        Column[{
          Row[{
            "Profile: +", scenario[[1, 3]], " ly/year^2 (\[TildeTilde] ", NumberForm[scenario[[1, 3]]*(c/yearSec)/g, {3, 2}],
            " g) to 5 yr; ", scenario[[2, 3]], " ly/year^2 (\[TildeTilde] ", NumberForm[scenario[[2, 3]]*(c/yearSec)/g, {3, 2}],
            " g) to 15 yr; ", scenario[[3, 3]], " ly/year^2 (\[TildeTilde] ", NumberForm[scenario[[3, 3]]*(c/yearSec)/g, {3, 2}],
            " g) to 20 yr."
          }],
          Row[{
            "Signals up to \[Tau] = ", tauMax, " yr reach home by t \[TildeTilde] ",
            NumberForm[arrivalAtHome, {5, 2}], " yr."
          }]
        }, Spacings -> 0.3],
        White, 12, LineSpacing -> {1.2, 0}, Alignment -> Center
      ]
    },
    Alignment -> Center,
    Background -> Black,
    Spacings -> {Automatic, 0.6}
  ]
];

(* run *)
Export["twin-quasi-paradox-home-light-rays.png", figure[]];
