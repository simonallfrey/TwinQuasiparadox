(* Two-panel comparison: light cones with t vertical, x horizontal, square aspect, clean labels *)

Clear[makePanel];
makePanel[cVal_, xRange_, tRange_, xLabel_, tLabel_, tag_] := Module[{},
  Show[
    {
     RegionPlot[Abs[x] >= cVal*Abs[t], {x, -xRange, xRange}, {t, -tRange, tRange},
       PlotStyle -> Directive[Opacity[0.18], RGBColor[0.3, 0.4, 0.5]], BoundaryStyle -> None],
     Plot[Evaluate[{x/cVal, -x/cVal}], {x, -xRange, xRange},
       PlotStyle -> {{Orange, Thick}, {Orange, Thick}}, Axes -> False, PlotRange -> {{-xRange, xRange}, {-tRange, tRange}}],
     Graphics[{Gray, Dashed, Line[{{-xRange, 0}, {xRange, 0}}], Line[{{0, -tRange}, {0, tRange}}]}],
     Graphics[Text[Style[tag, 12, Gray], {0, -0.82 tRange}]]
     },
    Axes -> True,
    AxesLabel -> {Style[xLabel, 11, White], Style[tLabel, 11, White]},
    TicksStyle -> White,
    PlotRange -> {{-xRange, xRange}, {-tRange, tRange}},
    Background -> Black,
    AxesStyle -> White,
    BaseStyle -> {White, 11},
    ImagePadding -> 60,
    ImageSize -> 500,
    AspectRatio -> 1
    ]
  ];

panel1 = makePanel[1, 1, 1, "x (light-sec)", "t (sec)", "c = 1"];
cKmPerMs = 300; (* 3e5 km/s = 300 km/ms *)
panel2 = makePanel[cKmPerMs, 1000, 20, "x (km)", "t (ms)", "c = 3×10^5 km/s"];

GraphicsRow[{panel1, panel2}, Spacings -> 0.8, Background -> Black, ImageMargins -> 20] //
  Export["lab-book/elsewhere-two-scales.png", #, ImageResolution -> 300] &;
