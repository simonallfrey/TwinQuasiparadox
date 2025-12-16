(* Spacelike "elsewhere" when c is large (c=10) *)
cVal = 10;
xRange = 20;
tRange = 1;

elsewhere = RegionPlot[
   Abs[x] >= cVal*Abs[t], {x, -xRange, xRange}, {t, -tRange, tRange},
   PlotStyle -> Directive[Opacity[0.18], LightBlue],
   BoundaryStyle -> None
   ];

cones = Plot[Evaluate[{cVal*t, -cVal*t}], {t, -tRange, tRange},
   PlotStyle -> {{Orange, Thick}, {Orange, Thick}},
   PlotRange -> {{-xRange, xRange}, {-tRange, tRange}},
   Axes -> False
   ];

axes = Graphics[{Gray, Dashed, Line[{{-xRange, 0}, {xRange, 0}}], Line[{{0, -tRange}, {0, tRange}}]}];

labels = Graphics[
   {
    Text[Style["light cone x = ± c t", 12, Orange, Bold], {xRange*0.35, tRange*0.7}, {0, 0}],
    Text[Style["spacelike 'elsewhere' (almost the whole x-axis for small t)", 12, Darker@Blue], {xRange*0.05, tRange*0.4}, {0, 0}],
    Text[Style["c = 10 → cones nearly vertical, 'now' band stays wide in x", 12, Gray], {0, -tRange*0.85}, {0, 0}]
    }
   ];

Show[
  elsewhere, cones, axes, labels,
  Axes -> True,
  AxesLabel -> {"x", "t"},
  PlotRange -> {{-xRange, xRange}, {-tRange, tRange}},
  ImageSize -> 840,
  Background -> Black,
  AxesStyle -> White,
  BaseStyle -> {White, 12}
  ] // Export["lab-book/elsewhere-not-c1.png", #, ImageResolution -> 600] &;
