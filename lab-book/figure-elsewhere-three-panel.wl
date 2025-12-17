(* Three-panel comparison: light cones with t vertical, x horizontal, square aspect, clean labels *)

Clear[makePanel];
makePanel[cVal_, xRange_, tRange_, xLabel_, tLabelText_, tag_] := Module[
  {yLabelPosition = {-0.14, 0.5}, tLabel},
  tLabel = Rotate[Style[tLabelText, 11, White], Pi/2];
  Show[
    {
     RegionPlot[
       Abs[x] >= cVal*Abs[t],
       {x, -xRange, xRange}, {t, -tRange, tRange},
       PlotRangeClipping -> None,
       PlotStyle -> Directive[Opacity[0.18], RGBColor[0.3, 0.4, 0.5]],
       BoundaryStyle -> None
       ],
     Plot[
       Evaluate[{x/cVal, -x/cVal}], {x, -xRange, xRange},
       PlotStyle -> {{Orange, Thick}, {Orange, Thick}},
       Axes -> False,
       PlotRange -> {{-xRange, xRange}, {-tRange, tRange}}
       ],
     Graphics[{Gray, Dashed, Line[{{-xRange, 0}, {xRange, 0}}], Line[{{0, -tRange}, {0, tRange}}]}],
     Graphics[Text[Style[tag, 12, Gray], {0, -0.82 tRange}]]
     },
    Frame -> True,
    FrameLabel -> {Style[xLabel, 11, White], None},
    FrameTicksStyle -> White,
    PlotRange -> {{-xRange, xRange}, {-tRange, tRange}},
    Background -> Black,
    AxesStyle -> White,
    BaseStyle -> {White, 11},
    ImageSize -> 500,
    AspectRatio -> 1,
    ImagePadding -> {{50, 20}, {Automatic, Automatic}},
    Epilog -> {
      Inset[
        tLabel,
        Scaled[yLabelPosition],
        {0, 0},
        Automatic,
        {1, 0}
        ]
      }
    ]
  ];

cmPerS = Quantity["speed of light"] // UnitConvert // QuantityMagnitude // N;
ckmPerS = cmPerS/1000;
ckmPerMs = ckmPerS/1000;

panel1 = makePanel[1, 1, 1, "x (light-sec)", "t (sec)", Style["c = 1 light-sec/sec" 14]];

cLabel = StringForm["c = `` km/ms", ScientificForm[ckmPerMs, 4]];
panel2 = makePanel[ckmPerMs, 1000, 20, "x (km)", "t (ms)", cLabel];
cLabel = StringForm["c = `` km/s", ScientificForm[ckmPerS, 4]];
panel3 = makePanel[ckmPerS, 1000, 1, "x (km)", "t (s)", cLabel];

elsewhereCaption = Style[
   "The classical notion of a global now transforms to 'elsewhere' in special relativity (grey regions).
Using c = 1 units makes elsewhere look narrow, but if we use pedestrian mks units it flattens into a much more now like form.",
   TextAlignment -> Center, 22, FontFamily -> "Cambridge"];

GraphicsRow[{panel1, panel2, panel3}, Spacings -> 0.8, Background -> Black, ImageMargins -> 0, ImageSize -> 1200] //
  Labeled[#, elsewhereCaption, Background -> Black, Frame -> False] & //
  Export["lab-book/elsewhere-three-panel.png", #, ImageResolution -> 300] &;
