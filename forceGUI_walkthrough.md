# forceGUI: User Walkthrough

forceGUI is a MATLAB app for analysing force traces recorded alongside EMG experiments (isometric contractions on ankle, hand, knee, arm and Derby Chair rigs). It takes you from a raw `.mat` recording to a table of tidy metrics in a few clicks: load, calibrate and filter, mark the segments of interest, compute metrics, export.

This document is a practical guide for someone who has just cloned the repo. It is written from the source code, so where behaviour is surprising it says so.

Repository: https://github.com/ppxma7/forceGUI  (current build: `v0.1.5-alpha`, a dev build and prone to bugs)

---

## 1. Installation

**Tested on:** MATLAB R2025b (Update 4), Windows 11.

**Required toolboxes** (Home → Add-Ons):

| Toolbox                                 | Used for                                                                                     |
| --------------------------------------- | -------------------------------------------------------------------------------------------- |
| Signal Processing Toolbox               | `butter`, `filtfilt`, `xcorr`, `pwelch`, `spectrogram`                                       |
| Image Processing Toolbox                | `drawrectangle` (segment selection), `bwareaopen`/`bwconncomp` (multi-contraction detection) |
| Statistics and Machine Learning Toolbox | `pdist2` (entropy), `corr`                                                                   |

**Steps**

1. `git clone https://github.com/ppxma7/forceGUI.git` (or download the zip).
2. In MATLAB, `cd` into the folder, or add it to the path: `addpath('path/to/forceGUI')`.
3. Type `forceGUI` in the Command Window.

All helper functions must be on the path, because the app calls them by name. The GUI prints a banner with its version to the Command Window on startup. Keep the Command Window visible: much of the diagnostic output goes there.

---

## 2. The big picture

Every analysis follows the same five-step pipeline, mapped to the buttons on the left of the app:

```
Load File  →  Filter  →  Select Segment  →  Compute Metrics  →  Export Results
```

Buttons are enabled progressively, so you can't skip ahead. Two exceptions: **MVC** analysis skips Select Segment, and **Redo** skips both Filter and Select Segment (see below). In **TRAP_multi**, Filter only applies the calibration (see §6).

**What each step does under the hood**

1. **Load File**: reads a `.mat` file using a *template* chosen from your Analysis / Mode / Rig dropdown settings, and plots the raw trace.
2. **Filter**: (a) calibrates to Newtons, (b) subtracts a baseline, (c) low-pass filters. The filtered trace is plotted.
3. **Select Segment**: you draw two rectangles, one around the up-ramp and one around the down-ramp. The plateau is whatever lies between them.
4. **Compute Metrics**: calculates the metrics for your analysis type and shows them in the table.
5. **Export Results**: writes a CSV and a "full state" MAT file next to your original data.

---

## 3. The interface

**Top row of dropdowns, set these BEFORE loading a file:**

| Control      | Options                                                         | Meaning                                            |
| ------------ | --------------------------------------------------------------- | -------------------------------------------------- |
| **Analysis** | `MCON`, `TRAP`, `TRAP_multi`, `RAMP`, `MVC`                     | What kind of contraction/analysis (see §5)         |
| **Rig**      | `None`, `Ankle`, `Hand`, `Knee`, `Arm`, `Derby Chair`, `Custom` | Which load cell / calibration to use (see §6)      |
| **Mode**     | `Single Channel`, `Multi Channel`, `Dual Channel`               | How many force channels the file contains (see §4) |
| **Channel**  | `Left`, `Right`, `Bilateral`                                    | Which channel to analyse (multi/dual files)        |

**Left-hand buttons:** Load File, Filter, Select Segment, Compute Metrics, Export Results, Reset, Hard Reset.

**Left-hand options:** Multi (contraction picker), Show Target, Redo?, mV to V?

**Bottom-left fields:** Cut off (Hz), Samp Freq (Hz), CoV win

**Bottom-centre:** Left / Right calibration fields, Edit Calib, Flip

**Other:** Colour (change the window background), a GitHub link, the results table at the bottom, and the plot axes at the top.

Hovering over most controls shows a tooltip.

**Dropdown side effects**

- Choosing **MVC** forces Mode to *Multi Channel* and locks the Mode dropdown.
- Choosing the **Derby Chair** rig forces Mode to *Single Channel* and locks both the Mode and Channel dropdowns.
- Choosing **TRAP_multi** enables the **Multi** dropdown.

---

## 4. Loading data: Modes and file formats

forceGUI doesn't assume one file layout. `selectTemplate.m` picks a template based on your dropdowns and `loadData_generic.m` uses it to unpack the file. If a file doesn't match what the template expects, you get an **"Invalid File"** alert listing your Mode / Rig / Analysis settings and the underlying error. The usual fix is to check those dropdowns.

Time is plotted in seconds. If the file has a `Time` variable it is zeroed to start at 0; otherwise the time axis is built from the sampling frequency.

### 4.0 Recommended file formats (start here)

The loaders accept many legacy layouts (described in 4.1 onwards). For **new recordings, save your `.mat` in one of the formats below**. There is no single layout that works for every Mode, because the Mode dropdown decides which variables are read, but every format follows the same rules:

**Rules for all files**

- Variables sit at the top level of the `.mat` (v7 or v7.3 both work). Anything extra is ignored.
- **Variable names:** every loader looks for the same common names, defined in one place, `forceAliases.m`. Force = `Force`, `FORCE`, `force`, `Torque`, `torque`, `F`, `ref_signal`. Target = `Target`, `target`, `TARGET`, `requested`, `Desired`. Sampling rate = `SamplingFrequency`, `fs`, `Fs`, `fsamp`, `SampleRate`. If your variable has a different name (e.g. `myforce`), rename it or add the name to `forceAliases.m`. The same names apply to every Mode and Rig.
- **Sampling rate:** if no rate variable is found, the app assumes 2000 Hz (2048 Hz for the Derby Chair).
- `Time` is optional. If absent, the time axis is built from the sampling frequency.
- Force should be the **raw** signal in the units your Rig calibration expects (see §6). Use Rig = `None` if it's already in Newtons.
- `Target` is optional. It is min–max rescaled to the force range (single channel), or multiplied by `mvc_value` (multi channel).
- Check your file with `whos -file myfile.mat` before loading.

**A. Single Channel** (Mode = Single Channel; Analysis = TRAP, MCON or RAMP)

```matlab
Force             = force;      % 1×N or N×1, raw
Target            = target;     % optional, N samples (resampled if the length differs)
SamplingFrequency = 2000;
save('P01_TRAP.mat', 'Force', 'Target', 'SamplingFrequency')
```

The same format is used for **RAMP** and for the **Derby Chair** (whose default rate is 2048 Hz if none is given).

**B. Multi Channel** (Mode = Multi Channel; Analysis = TRAP, MCON or RAMP). This is the format in the example below.

```matlab
Force             = [forceL; forceR; forceBi];   % channels × samples: row 1 = Left, 2 = Right, 3 = Bilateral
Target            = target;                      % 1×N, normalised target (fraction of MVC)
mvc_value         = mvc;                         % scalar MVC, same units as Force
SamplingFrequency = 2000;
save('P01_TRAP.mat', 'Force', 'Target', 'mvc_value', 'SamplingFrequency')
```

- Channels must be in **rows** (the loader transposes). Only rows 1–3 are used as force. In the lab's 7-row layout, rows 4–6 are the MVC-normalised versions of rows 1–3 (ignored) and row 7 is the target (used if there is no separate `Target` variable).
- If you only have Left and Right, make row 3 the sum (`forceL + forceR`).

**C. MVC** (Analysis = MVC)

```matlab
signal_mvc.auxiliary = [forceBi; forceL; forceR];   % 3×N: row 1 = Bilateral, 2 = Left, 3 = Right
signal_mvc.fsamp     = 2000;
```

A single-row `auxiliary` is accepted and used for all three channels.

**D. TRAP_multi** (several contractions in one trace; no target)

```matlab
Ch1.values   = force;       % N×1 or 1×N
Ch1.interval = 1/2000;      % seconds per sample
```

Any variable named `Ch<number>` with these two fields works (the first match is used).

### 4.1 Single Channel

Handled by `template_single.m`. Accepted layouts:

- Named variables: any of the accepted names in `forceAliases.m` (`Force`, `FORCE`, `force`, `Torque`, `F`, `ref_signal`, ...), optionally with a target (`Target`, `target`, `requested`, `Desired`), `Acq` and `Perf`.
- A `Data` cell whose first element is a matrix with columns: **1 = Force, 2 = Acq, 3 = Perf, 4 = Target**. A 2-column matrix is read as Force + Target, and 1 column as Force only.
- Sampling frequency comes from any of the names in `forceAliases.m` (`SamplingFrequency`, `fs`, `fsamp`, ...), otherwise **defaults to 2000 Hz**.
- **Target scaling:** if a target exists it is automatically min–max rescaled to the range of the raw force trace (`scaleTarget.m`). So the target is a shape-matched reference, not an independently calibrated one.

Special cases: **RAMP** files (`template_ramp.m`) and **Derby Chair + TRAP** files (`template_derby.m`) use the same accepted names. The Derby Chair also falls back to column 66 of a legacy `Data` block, and defaults to **2048 Hz** if no rate is given. If no force variable is found, the loader reports which names it looked for.

### Multi Channel

Handled by `template_multi.m`. Left, Right and Bilateral force channels in one file.

- **New format:** a `Force` matrix (channels × samples); channels 1–3 are L, R, Bilateral. The target is taken from `Target` or channel 7, and multiplied by `mvc_value`, which must be present (otherwise a debug `keyboard` stop is hit).
- **Legacy format:** a `Data` block with a `Description` list; columns 1–3 are force L/R/Bi, and the target is detected from channels whose description contains "requested" and that actually vary.
- When loading, a figure pops up plotting every channel, for sanity-checking.

### Dual Channel

Handled by `template_dual.m`, for files with only two channels (L and R; built for the canapi data). Detects the channel count from the number of `AUX` entries in `Description`. There's no target. Choosing *Bilateral* will tell you to select Left or Right instead, unless the file has three AUX channels (untested).

### TRAP_multi (several contractions in one long recording)

Handled by `template_multiContract.m`. Needs either a `Data` cell (col 1 = force, col 4 = target) or channel structs named `Ch<number>` with `.values` and `.interval`. The loader **finds contractions automatically**:

1. Low-pass at 20 Hz.
2. Anything above 20% of max force, sustained for ≥5 s, counts as a plateau.
3. Each contraction is extended outward until force drops below 10% of max, plus 1.5 s padding either side (so you can draw the ramps).

Two diagnostic figures open (all contractions overlaid, and the whole filtered trace).

**Optional labels:** put a `contractionLabels.txt` in the same folder as the `.mat` (one label per line, same count as detected contractions). Otherwise they're numbered. The **Multi** dropdown then lists `Con 1  <label>`, etc.

### MVC (maximum voluntary contraction)

Handled by `template_mvc.m`. Reads `signal_mvc.auxiliary` (row 1 = bilateral, 2 = left, 3 = right; a single-row file is used for all three) and the sampling rate from `signal_mvc.fsamp`.

---

## 5. Analysis types

| Analysis       | Use it for                                                               | Needs segmenting?    | Output                                                 |
| -------------- | ------------------------------------------------------------------------ | -------------------- | ------------------------------------------------------ |
| **TRAP**       | Trapezoid contraction (ramp up, hold, ramp down): steadiness of the hold | Yes                  | Steadiness/complexity/spectral metrics + ramp metrics  |
| **TRAP_multi** | Several trapezoids in one recording                                      | Yes, per contraction | Same as TRAP, one contraction at a time                |
| **MCON**       | Matched-contraction / tracking a target                                  | Yes                  | Tracking-error metrics (lag, corr, AUC) + ramp metrics |
| **RAMP**       | Ramp-only analyses                                                       | Yes                  | Ramp metrics only                                      |
| **MVC**        | Maximal effort                                                           | No                   | Peak force                                             |

---

## 6. Calibration / Filter

The **Filter** button first converts raw voltages into Newtons using the Rig setting. Values live in `defaultCalibration.m`. **Edit Calib** opens that file (uses `winopen`, so Windows only; on other systems open the file manually).

| Rig                   | Conversion                                                           |
| --------------------- | -------------------------------------------------------------------- |
| **None**              | No conversion (bilateral = L + R summed)                             |
| **Ankle**             | `((raw − b) / M) × 9.81` (linear regression, M and b per side)       |
| **Hand / Knee / Arm** | `raw × scale × 9.81` (scale per side)                                |
| **Derby Chair**       | `raw × scale` (one scale, no 9.81)                                   |
| **Custom**            | `raw × scale × 9.81`, scale must be typed into the Left/Right fields |

**Overriding the scale from the GUI:** for Hand/Knee/Arm, type a number into **Left** and/or **Right**; leave **0** to keep the default from `defaultCalibration.m`. Ankle and Derby Chair always use the file values and ignore the fields. For *Custom*, the field(s) needed for your selected channel must be non-zero or you'll get a "Missing Calibration" alert.

**Important:** in MCON analysis on the normal rigs, the signal is **not** calibrated (it's passed through as-is). Calibration is applied for TRAP, RAMP, MVC, and for the Derby Chair.

**TRAP_multi:** Filter also applies the calibration here. Set Rig, Channel (**Left or Right only**; Bilateral is not supported) and any Left/Right value, then press **Filter**. You can change the value and press Filter again at any time: it always recalibrates from a saved raw copy of each contraction, so calibrations never compound. If you have already drawn segments or computed metrics, press Reset and recompute afterwards. Segment detection at load time runs on the uncalibrated trace. Rig `None` leaves the data as it is.

---

## 7. Filtering and baseline

After calibration, **Filter** applies:

1. **Baseline subtraction** (TRAP/RAMP): subtract the mean of the first 0.5 s from the force (and target). *Not* applied for MCON (it would alter the tracking error) or MVC (people sometimes start pushing before the recording begins, so only the peak matters).
2. **Low-pass filter**: 5th-order Butterworth, zero-phase (`filtfilt`), via `lpbutter.m`. The cutoff is the **Cut off (Hz)** field (default **20 Hz**). A cutoff ≥ Nyquist disables filtering; a cutoff ≤ 0 zeros the signal.

**Sampling frequency:** the file's own value is used unless you type something non-zero into **Samp Freq (Hz)**.

Note: TRAP_multi uses a fixed 20 Hz filter applied at load time, so the Cut off field is ignored. Its Filter button only applies the calibration (§6).

Tick/untick **Show Target** to toggle the target line (only works if a target exists).

---

## 8. Selecting segments

Click **Select Segment** and follow the prompts:

1. **"Draw rectangle for UP RAMP"**: drag a rectangle over the up-ramp, from its bottom to where it reaches the plateau. Only the horizontal extent matters. The segment turns green.
2. **"Draw rectangle for DOWN RAMP"**: same for the down-ramp, from where it leaves the plateau to the bottom. It turns blue.
3. The **plateau** (magenta) is automatically everything between the two rectangles (from the end of the up-ramp to the start of the down-ramp).

If the ramps overlap (no plateau), you'll get a "Segment Error" and need to redo it. Rectangles are clamped to the trace edges. In Multi Channel mode, switching the Channel dropdown re-filters and **reuses your existing segments**, so you can compare L/R/Bilateral without redrawing.

---

## 9. Metrics

Press **Compute Metrics**. If results are already in the table you must press **Reset** first.

### 9.1 TRAP metrics (computed on the plateau)

| Column                                 | Meaning                                                                                                                        |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `SteadyMean`, `SteadySTD`, `SteadyCoV` | Mean, SD and coefficient of variation (SD/mean × 100) over the whole plateau                                                   |
| `CoV2s`, `CoV5s` (+ `Mean…`, `STD…`)   | Statistics for the **steadiest window**: the window of that length with the lowest CoV (a sliding search over the plateau)     |
| `ScaledCoV`                            | CoV after min–max scaling the plateau to 0–1                                                                                   |
| `CoVminus1`                            | CoV excluding the first second of the plateau                                                                                  |
| `MeanYank`, `RMSYank`                  | Mean absolute and RMS of the derivative of force (N/s), i.e. how jerky the force is                                            |
| `ApEn`, `SampEn`                       | Approximate / sample entropy (m = 2, r = 0.1 × SD) on the plateau **downsampled by 20**                                        |
| `DFA57`                                | Detrended fluctuation analysis scaling exponent using 57 log-spaced box sizes (4 samples up to N/4), on the downsampled signal |
| `MinForce`, `MaxForce`                 | Range of the plateau                                                                                                           |

**Custom CoV windows:** the **CoV win** field takes a MATLAB-style list of window lengths in seconds, e.g. `5 2` (the default if blank) or `10 3`. Column names follow the length (`CoV10s`, `Mean10s`, `STD10s`). Use whole numbers: a fractional window such as `2.5` produces an invalid field name and an error.

**Spectral bands** (also computed for TRAP): the plateau is low-passed at 35 Hz, then Welch's method (1 s Hann window, 50% overlap) gives:

| Band  | Range    |
| ----- | -------- |
| Delta | 0.5–4 Hz |
| Theta | 4–8 Hz   |
| Alpha | 8–13 Hz  |
| Beta  | 13–30 Hz |

You get absolute band power (`PSD_Delta` … `PSD_Beta`, in N²), `PSD_Total`, and relative power in % (`PSD_*_Rel`). A figure shows the filtered force on top and a high-resolution time–frequency spectrogram below with band boundaries marked.

### 9.2 Ramp metrics (computed for TRAP, MCON and RAMP)

For each ramp, a straight line is fitted and the residuals measured: how wobbly is the force around a perfectly linear ramp?

| Column                           | Meaning                                                           |
| -------------------------------- | ----------------------------------------------------------------- |
| `Up_SD`, `Down_SD`               | SD of residuals from the linear fit                               |
| `Up_RMSE`, `Down_RMSE`           | RMSE of those residuals                                           |
| `Up_RMSE_Norm`, `Down_RMSE_Norm` | RMSE divided by the ramp's range (fraction of the ramp amplitude) |

A figure shows each ramp, its fit, and the residuals (titled with the normalised RMSE as a percentage).

### 9.3 MCON metrics (tracking a target; plateau)

| Column    | Meaning                                                                                                                                       |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `Lag`     | Lag of peak cross-correlation between target and force, **in samples** (divide by fs for seconds). Check the sign convention on your own data |
| `Corr`    | Pearson correlation between force and target                                                                                                  |
| `AUC`     | Area under the absolute error curve (`trapz(                                                                                                  |
| `NormAUC` | `AUC` divided by the number of samples                                                                                                        |

### 9.4 Left/Right coupling (Multi Channel mode, TRAP and MCON)

When Mode is *Multi Channel*, the raw left and right traces over the plateau are filtered (same cutoff) and compared:

- `LRlag`: lag at peak cross-correlation between left and right (samples)
- `LRcorr`: correlation between left and right

### 9.5 MVC

No segments needed. Press Filter, then Compute Metrics.

- **Single/other channel:** `MVC` = peak of the filtered trace.
- **Multi Channel + Bilateral:** `MVC_Bilat` = peak of the calibrated, filtered bilateral force (L + R); `MVC_L` and `MVC_R` are the left and right values **at the same instant** as the bilateral peak (not their own separate peaks). The Command Window prints each channel's own peaks alongside, for debugging.

Run **Filter** first for the bilateral case, because it sets the calibration used here.

### 9.6 TRAP_multi workflow

1. Load the file and pick a contraction in **Multi**. Its trace is plotted.
2. If your data needs calibrating, set Rig, Channel (Left or Right) and any Left/Right value, then press **Filter** (§6).
3. Select Segment (up-ramp, down-ramp), then Compute Metrics.
4. Export, then move to the next contraction.

Results are stored per contraction, and **Reset** clears only the current contraction's segments and results.

---

## 10. Exporting

**Export Results** saves two files in the *same folder as the loaded file*, without overwriting anything (a timestamp is added):

- `<name>_<yyyyMMdd_HHmmss>_forceresults.csv`: the metrics table. Columns are ordered `Code, SteadyMean, SteadySTD, SteadyCoV, CoV2s, CoV5s, CoVminus1, MeanYank, RMSYank, ApEn, SampEn, DFA57, MinForce, MaxForce, Mean/STD windows, Up/Down ramp metrics`, followed by any remaining columns (spectral bands, LR coupling, etc.).
- `<name>_<timestamp>_fullstate.mat`: everything needed to reproduce the analysis (data, filtered traces, segments, metrics, results).

TRAP_multi adds `_con<N>_<label>` to the name, one file per contraction. Redo exports add `_redo`.

---

## 11. Redo: reprocessing a saved analysis

Tick **Redo?** *before* loading, then load a `*_fullstate.mat` from a previous export. The app restores the data, filtered signal and segments, skips Filter and Select Segment, and enables **Compute Metrics** directly. Useful for recomputing metrics after a code update, or changing the **CoV win**, without re-drawing segments. Keep the Mode / Channel / Analysis dropdowns the same as the original run. Exports carry a `_redo` suffix.

---

## 12. Utility controls

| Control            | What it does                                                                                                                                                                                                                            |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Reset**          | Soft reset: clears segments, results and the table so you can re-draw. Keeps the file loaded.                                                                                                                                           |
| **Hard Reset**     | Clears everything. You must load a file again. (Load File does this automatically.)                                                                                                                                                     |
| **Flip**           | Inverts the trace (`−force`, then shifts the minimum to 0) for signals recorded upside-down. The target is shifted too. Press **Filter** again afterwards. Pressing Flip twice undoes it.                                               |
| **mV to V?**       | Divides all loaded numeric traces by 1000 (unticking multiplies back). It acts on the data loaded *at the moment you toggle it*, so tick it after loading each file, and untick/re-tick if you load a new file while it's still ticked. |
| **Samp Freq (Hz)** | Override sampling frequency (0 = use the file's).                                                                                                                                                                                       |
| **Colour**         | Pick the window background colour.                                                                                                                                                                                                      |

---

## 13. Combining results across participants: `combineMatFileResults.m`

A standalone script (not part of the GUI) that stitches the exported CSVs together:

1. Open the script and set `thisMode = 'TRAP';` (or `'MCON'`, `'RAMP'`).
2. Run it and choose the folder of exported results.
3. It reads every `*_forceresults*.csv`, keeps only the columns expected for that mode (`modeCols` at the top), and writes `combined_<mode>_<timestamp>.csv` to the same folder.

Files missing any expected column are **skipped and listed** at the end. Extra columns (for example the PSD band columns) are dropped, so edit `modeCols` if you want them. The `MCON` list includes `LRlag`/`LRcorr`, so single-channel MCON exports will be skipped.

---

## 14. Quick-start recipes

**A. Single-channel ankle TRAP**

1. Analysis = `TRAP`, Rig = `Ankle`, Mode = `Single Channel`.
2. Load File → Filter (cutoff 20 Hz) → Select Segment (up, then down ramp) → Compute Metrics → Export Results.

**B. Bilateral TRAP with left/right coupling**

1. Analysis = `TRAP`, Rig = `Knee` (type L/R scales if needed), Mode = `Multi Channel`, Channel = `Bilateral`.
2. Load → Filter → Select Segment → Compute. The table includes `LRlag` and `LRcorr`. Switch Channel to Left or Right to get per-limb metrics from the same segments.

**C. Bilateral MVC**

1. Analysis = `MVC` (Mode locks to Multi Channel), Channel = `Bilateral`, pick your Rig.
2. Load → Filter → Compute Metrics → Export.

**D. Many contractions in one recording**

1. Analysis = `TRAP_multi`. Optionally add `contractionLabels.txt` to the data folder.
2. Load, then for each contraction in **Multi**: Select Segment → Compute → Export.

---

## 15. Troubleshooting

| Symptom                                                                    | Likely cause / fix                                                                                                                                                             |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| "Invalid File" alert                                                       | Dropdowns don't match the file. Check Analysis, Mode, Rig.                                                                                                                     |
| "You must filter the signals before selecting a segment"                   | Press Filter first.                                                                                                                                                            |
| "Results already exist. Press Reset…"                                      | Press Reset, then recompute.                                                                                                                                                   |
| "Ramp segments overlap"                                                    | Redraw with the down-ramp rectangle starting after the up-ramp ends.                                                                                                           |
| "Custom rig requires a Left/Right value"                                   | Enter the scale in the Left/Right fields.                                                                                                                                      |
| Wrong units or huge values                                                 | Check the Rig and the Left/Right overrides; for mV data try *mV to V?*.                                                                                                        |
| Error with a custom CoV window                                             | Use whole-number seconds, e.g. `10 3`.                                                                                                                                         |
| "No force variable found. Looked for: …"                                   | Your force variable has a different name. Rename it, or add the name to `forceAliases.m`.                                                                                      |
| "Force is a NxM matrix. For multi-channel files set Mode = Multi Channel." | A multi-channel file was loaded in Single Channel mode. Change Mode and reload.                                                                                                |
| MATLAB drops into debug mode (`K>>`) when loading                          | A `keyboard` statement in `template_multi.m` (no `mvc_value` in the file) or `template_mvc.m` (legacy single-channel file) was hit. Type `dbcont` to continue or fix the file. |
| Edit Calib does nothing                                                    | `winopen` is Windows only; open `defaultCalibration.m` manually.                                                                                                               |
| Entropy/CoV step is slow                                                   | Long plateaus make the sliding CoV window search and pairwise-distance entropy calculations heavy.                                                                             |

---

## 16. Repository map

**Core app:** `forceGUI.m` (the app and all callbacks).

**Loading:** `selectTemplate.m` → `loadData_generic.m` using one of `template_single/ramp/derby/multi/dual/multiContract/mvc.m`. `loadData_redo.m` handles Redo. `loadContractionLabels.m`, `getTimeAxis.m`, `getTargetOrEmpty.m`, `scaleTarget.m`, `forceAliases.m` (accepted variable names; add your own here), `pickField.m`.

**Calibration:** `defaultCalibration.m` (edit this for your rig), `calibrateTRAP.m` (also used for RAMP/MVC), `calibrateDerby.m`.

**Signal processing and metrics:** `lpbutter.m`, `computeTRAP.m`, `computeMetrics.m` (MCON), `computeRampStuff.m`, `computeSpectralBands.m`, `plotBandsTFS.m`, `computeBilateralMVC.m`, `DFA.m`, `FastApEn.m`, `FastSampEn.m`, `calc_entropy.m`.

**Results shaping:** `buildTRAPResultsStruct.m`, `buildResultsStruct.m`, `buildRampResultsStruct.m`.

**Post-processing:** `combineMatFileResults.m`.

**Legacy / scratch (not used by the app):** `loadData.m`, `loadData_derby.m`, `getTimeAxis_legacy.m`, `template_redo.m`, `calc_entropy_multiple.m`, `ForceCompl.m`, `example_plot.m`, `extractSegment.m`.

**Licence:** GNU GPL v3 (see `LICENSE`).
