(* Two-panel comparison: light cones with t vertical, x horizontal *)

Clear[makePanel];
makePanel[cVal_, xRange_, tRange_, xLabel_, tLabel_, tag_] := Module[{},
  Show[
    {
     RegionPlot[Abs[x] >= cVal*Abs[t], {x, -xRange, xRange}, {t, -tRange, tRange},
       PlotStyle -> Directive[Opacity[0.18], RGBColor[0.3, 0.4, 0.5]], BoundaryStyle -> None],
     Plot[Evaluate[{cVal*t, -cVal*t}], {t, -tRange, tRange},
       PlotStyle -> {{Orange, Thick}, {Orange, Thick}}, Axes -> False, PlotRange -> {{-xRange, xRange}, {-tRange, tRange}}],
     Graphics[{Gray, Dashed, Line[{{-xRange, 0}, {xRange, 0}}], Line[{{0, -tRange}, {0, tRange}}]}],
     Graphics[Text[Style[tag, 12, Gray], {0, -0.82 tRange}]]
     },
    Axes -> True,
    AxesLabel -> {xLabel, tLabel},
    PlotRange -> {{-xRange, xRange}, {-tRange, tRange}},
    Background -> Black,
    AxesStyle -> White,
    BaseStyle -> {White, 11},
    ImageSize -> 700,
    AspectRatio -> Automatic
    ]
  ];

panel1 = makePanel[1, 10, 10, "x (light-sec)", "t (sec)", "c = 1 (light-seconds)"];
panel2 = makePanel[3*10^8, 3*10^8, 1, "x (m)", "t (sec)", "c = 3×10^8 m/s"];

GraphicsRow[{panel1, panel2}, Spacings -> 0.8, Background -> Black] //
  Export["lab-book/elsewhere-two-scales.png", #, ImageResolution -> 300] &;
