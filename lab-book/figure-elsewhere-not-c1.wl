(* Spacetime diagram showing light cones when c != 1 (here c=10) *)
cVal = 10; (* choose a large c to show “now-like” elsewhere over modest t-range *)

coneRegion = RegionPlot[
   Abs[x] > cVal*Abs[t], {x, -20, 20}, {t, -2, 2},
   PlotStyle -> Directive[Opacity[0.15], LightBlue],
   BoundaryStyle -> None
   ];

coneLines = Plot[Evaluate[{cVal*t, -cVal*t}], {t, -2, 2},
   PlotStyle -> {{Orange, Thick}, {Orange, Thick}},
   PlotRange -> {{-20, 20}, {-2, 2}},
   Axes -> False
   ];

frame = Graphics[{Gray, Dashed, Line[{{-20, 0}, {20, 0}}], Line[{{0, -2}, {0, 2}}]}];

labels = Graphics[
   {Text[Style["light cone x = ± c t", 12, Orange, Bold], {10, 1.4}, {0, 0}],
    Text[Style["elsewhere (spacelike)", 12, Darker@Blue], {12, 0.2}, {0, 0}],
    Text[Style["c = 10 (steep cones → 'now-like' elsewhere over short t)", 12, Gray], {0, -1.6}, {0, 0}]
    }
   ];

Show[
  coneRegion, coneLines, frame, labels,
  Axes -> True,
  AxesLabel -> {"x", "t"},
  PlotRange -> {{-20, 20}, {-2, 2}},
  ImageSize -> 840,
  Background -> Black,
  AxesStyle -> White,
  BaseStyle -> {White, 12}
  ] // Export["lab-book/elsewhere-not-c1.png", #, ImageResolution -> 600] &;
