(* Two-panel comparison: light cones in light-seconds/seconds vs meters/seconds *)

(* Panel 1: x in light-seconds (c=1 units), t in seconds *)
panel1 = Module[{xRange = 10, tRange = 10},
  Show[
    {
     RegionPlot[Abs[x] >= Abs[t], {x, -xRange, xRange}, {t, -tRange, tRange},
       PlotStyle -> Directive[Opacity[0.15], LightBlue], BoundaryStyle -> None],
     Plot[Evaluate[{t, -t}], {t, -tRange, tRange},
       PlotStyle -> {{Orange, Thick}, {Orange, Thick}}, Axes -> False],
     Graphics[{Gray, Dashed, Line[{{-xRange, 0}, {xRange, 0}}], Line[{{0, -tRange}, {0, tRange}}]}],
     Graphics[Text[Style["c = 1 (light-seconds)", 12, Gray], {0, -tRange*0.85}]]
     },
    Axes -> True, AxesLabel -> {"x (light-sec)", "t (sec)"},
    PlotRange -> {{-xRange, xRange}, {-tRange, tRange}},
    Background -> Black, AxesStyle -> White, BaseStyle -> {White, 11}, ImageSize -> 400
    ]
  ];

(* Panel 2: x in meters, t in seconds (c ~ 3e8 m/s, so cones are very narrow) *)
cMeters = 3*10^8; xRange2 = 3*10^8; tRange2 = 1;
panel2 = Module[{},
  Show[
    {
     RegionPlot[Abs[x] >= cMeters*Abs[t], {x, -xRange2, xRange2}, {t, -tRange2, tRange2},
       PlotStyle -> Directive[Opacity[0.15], LightBlue], BoundaryStyle -> None],
     Plot[Evaluate[{cMeters*t, -cMeters*t}], {t, -tRange2, tRange2},
       PlotStyle -> {{Orange, Thick}, {Orange, Thick}}, Axes -> False, PlotRange -> {{-xRange2, xRange2}, {-tRange2, tRange2}}],
     Graphics[{Gray, Dashed, Line[{{-xRange2, 0}, {xRange2, 0}}], Line[{{0, -tRange2}, {0, tRange2}}]}],
     Graphics[Text[Style["c = 3×10^8 m/s", 12, Gray], {0, -tRange2*0.85}]]
     },
    Axes -> True, AxesLabel -> {"x (m)", "t (sec)"},
    PlotRange -> {{-xRange2, xRange2}, {-tRange2, tRange2}},
    Background -> Black, AxesStyle -> White, BaseStyle -> {White, 11}, ImageSize -> 400
    ]
  ];

GraphicsRow[{panel1, panel2}, Spacings -> 1, Background -> Black] //
  Export["lab-book/elsewhere-two-scales.png", #, ImageResolution -> 300] &;
