# forceGUI: Explaining metrics

**General principle.** During a steady or tracking contraction, force is never perfectly constant. The fluctuations reflect the motor neuron pool's synaptic input, motor unit discharge, feedback loops (visual and proprioceptive) and mechanical filtering by muscle and tendon. Quantifying them gives a window into motor control [1].

##### Steadiness metrics (TRAP, computed on the plateau)

**SteadyMean (N)**

- *How:* mean of the filtered plateau.
- *Why:* tells you the force actually held. It is the reference for every variability measure, because force variability scales with force level (signal-dependent noise). It also shows whether the participant matched the target level.

**SteadySTD (N)**

- *How:* standard deviation of the filtered plateau.
- *Why:* absolute size of the fluctuations about the mean. It includes both fast fluctuations and slow drift. It rises with force level, so compare it only at matched target forces.

**SteadyCoV (%)**

- *How:* SD / mean × 100.
- *Why:* the standard measure of force steadiness. It normalises variability to force level, so people and force levels can be compared. A higher CoV means poorer steadiness. It is linked to the variance of common synaptic input to the motor neuron pool and to motor unit discharge variability, and is typically higher in older adults, in many patient groups and with fatigue.

**CoV2s, CoV5s and their Mean/STD (%, N)**

- *How:* a sliding window of the stated length moves along the plateau. The window with the lowest CoV is selected, and its CoV, mean and SD are reported. Window lengths come from the **CoV win** field (default 5 and 2 s).
- *Why:* the whole-plateau CoV is contaminated by slow drift and by settling after the ramp. The steadiest window reflects the participant's best sustained control, and different window lengths separate fast fluctuations from slow drift. Because it picks the best window, it is biased low, so use the same window lengths across all participants.

**CoVminus1 (%)**

- *How:* CoV of the plateau after discarding its first second.
- *Why:* removes the transition from ramp to hold (overshoot and corrective adjustment), isolating steady-state control.

**ScaledCoV (%)**

- *How:* the plateau is min–max scaled to 0–1, then SD / mean × 100. This works out to SD / (mean − minimum).
- *Why:* removes dependence on the zero offset and the units, which is useful when baselines differ. It is sensitive to the single lowest sample and isn't comparable in magnitude to SteadyCoV.

**MeanYank and RMSYank (N/s)** [2]

- *How:* yank is the first derivative of the filtered force. MeanYank is the mean of its absolute value, and RMSYank is its root mean square.
- *Why:* indexes how rapidly force is changing. Yank tells you how quickly force is ramping up (positive) or dropping off (negative). Peak positive yank shows how rapidly force can be produced, as in jumping or reacting to a perturbation.
  Negative yank shows how quickly force is reduced. During a constant-force hold, larger RMS yank means faster fluctuations or corrections.
  

**MinForce and MaxForce (N)**

- *How:* minimum and maximum of the filtered plateau.
- *Why:* the range of force excursions, and a quick sanity check on whether the target was reached.

##### Complexity metrics (TRAP; computed on the plateau downsampled ×20)

**ApEn and SampEn** [3]

- *How:* both estimate how predictable the signal is. Segments of length *m* = 2 are compared, and two segments count as a match if they differ by less than *r* = 0.1 × SD at every point. The entropy is the (negative log) probability that segments that match for *m* points still match for *m*+1. SampEn excludes self-matches and is less biased for short records. SampEn is NaN if no matches are found.
- *Why:* measures how predictable the force trace is from moment to moment, in other words, whether knowing the recent pattern helps you guess what comes next. Low values mean the same small patterns keep recurring, as in a steady rhythmic oscillation. High values mean new patterns keep appearing, so the signal is harder to predict. This captures how fluctutations are organised over time. Two traces can wobble by the same amount, one rhythmically and the other erratically. Entropy is often used as a window on how force is controlled, but irregularity can also come from noise, so it isn't automatically better. Values depend on task, force level, filtering and sampling rate.

**DFA57 (α) Detrended Fluctuation Analysis** [4]

- *How:* the plateau is mean-subtracted and integrated, and cut into boxes of increasing size (57 log-spaced sizes from 4 samples up to N/4). Each box is linearly detrended and its RMS fluctuation F(n) measured. α is the slope of log F against log n.
- *Why:* describes how force fluctuations are organised across short and long time scales, in other words, how the size of the wobble grows as you look over longer stretches of the signal. It also reflects whether past changes tend to carry on or reverse. α < 0.5 means increases tend to be followed by decreases, and vice versa. α ≈ 0.5 means no memory (white-noise-like). Between 0.5 and 1, trends tend to persist, and α ≈ 1 indicates 1/f-like long-range correlation. Values above 1 indicate nonstationary, drifting behaviour, with α ≈ 1.5 resembling a smoother random walk. This complements SD, which measures the size of fluctuations, and entropy, which measures the predictability of short patterns. α alone does not identify the control mechanism responsible.

##### Spectral metrics (TRAP; Welch PSD of the plateau)

**PSD_Low (1–5 Hz), PSD_Mid (5–15 Hz), PSD_High (15–30 Hz)** (absolute, N²) [5]

- *How:* the plateau is low-passed at 35 Hz, then Welch's method (1 s Hann window, 50% overlap) gives a power spectral density. Band power is the sum of the PSD within the band times the frequency step. Absolute band power is the share of the force variance (N²) in that band. **PSD_Total** is the power across the whole spectrum.

- **_Rel versions (%):** band power / total × 100. They don't sum to 100%, because the total also includes frequencies below 1 Hz and above 30 Hz.

- *Why:* splits the force variance by frequency to help separate mechanisms:

  - *Low (1–5 Hz):* voluntary force modulation, common modulation of motor unit discharge. Usually dominates force variability.
  - *Mid (5–15 Hz):* includes physiological tremor (about 8–12 Hz), which has mechanical and reflex components.
  - *High (15–30 Hz):* beta-band content, associated with corticospinal drive to the muscle.

  The exact band edges are conventions that vary between studies, so cite the source you follow. Use absolute power when force level is matched, and relative power to compare how variance is distributed.

A time–frequency plot (STFT) is also shown, for seeing how the spectrum changes over the hold.

##### Ramp metrics (TRAP, MCON, RAMP)

**Up_SD, Up_RMSE, Down_SD, Down_RMSE (N)**

- *How:* a straight line is fitted to each ramp, and the residuals around it are measured. RMSE is the root mean square of the residuals.
- *Why:* the intended ramp is a straight line, so detrending removes the task's intended change and leaves the unintended deviations ("wobble" or stepping) during dynamic force modulation. Higher values mean less smooth force control. They are expected to be higher in older adults and many patient groups. Up and down ramps are reported separately because rising and falling force rely on different control (recruitment versus de-recruitment).
- *Note:* residuals from a fit with an intercept have zero mean, so SD and RMSE are almost identical. Report one of them.

**Up_RMSE_Norm and Down_RMSE_Norm (fraction, shown as %)**

- *How:* RMSE divided by the range of the ramp.
- *Why:* expresses wobble as a fraction of ramp amplitude, so ramps of different size (different target forces or participants) can be compared. It depends on how you draw the ramp rectangles, so draw them consistently.

##### Tracking metrics (MCON, computed on the plateau)

**Lag (samples)**

- *How:* lag at the peak of the cross-correlation between target and force. Divide by the sampling frequency for seconds.
- *Why:* the delay with which the participant follows the target, reflecting visuomotor processing and feedback delay. Longer delays are often seen in older adults and in some neurological conditions.

**Corr**

- *How:* Pearson correlation between force and target (zero lag).
- *Why:* how well the force waveform matches the target's shape. Lower values mean poorer tracking.

**AUC and NormAUC**

- *How:* AUC is the area under the absolute error |force − target| (trapezoid rule, in N·samples). NormAUC is AUC divided by the number of samples, which is essentially the mean absolute error in N.
- *Why:* overall tracking accuracy, and a measure of motor control during a visuomotor task. Higher means worse tracking. NormAUC is better for comparing across trials of different length.
- *Caveat:* in single-channel files the target is min–max rescaled to the participant's own force range, so the error reflects shape mismatch relative to their range, not absolute accuracy against a calibrated target.

##### Bilateral coordination (Multi Channel mode, TRAP and MCON)

**LRcorr and LRlag**

- *How:* the raw left and right traces over the plateau are filtered with the same cutoff, then correlated (LRcorr) and cross-correlated (LRlag, in samples).
- *Why:* quantifies how coupled the two limbs' force fluctuations are. High coupling suggests shared neural drive across limbs, and lag shows timing offsets between them. Useful for asymmetries (for example after stroke) and for bilateral versus unilateral comparisons.

##### MVC

**MVC (single channel) or MVC_Bilat, MVC_L, MVC_R (N)**

- *How:* the peak of the filtered (and calibrated) trace. For bilateral, the left and right values are taken at the same instant as the bilateral peak, not from their own peaks.
- *Why:* maximal strength, used to set submaximal target levels (for example 10% MVC) and to compare groups. Left and right values at the bilateral peak show each limb's contribution to a bilateral effort. The 20 Hz filter makes the peak slightly lower than the raw peak, so keep the filter setting constant across participants.

## References

[1] Enoka RM, Farina D. Force Steadiness: From Motor Units to Voluntary Actions. *Physiology* 36: 114-130, 2021. doi: 10.1152/physiol.00027.2020. https://doi.org/10.1152/physiol.00027.202

[2] Lin DC, McGowan CP, Blum KP, Ting LH. Yank: the time derivative of force is an important biomechanical variable in sensorimotor systems. J Exp Biol. 2019 Sep 12;222(Pt 18):jeb180414. doi: 10.1242/jeb.180414. PMID: 31515280; PMCID: PMC6765171.

[3] Richman JS, Moorman JR. Physiological time-series analysis using approximate entropy and sample entropy. *Am J Physiol Heart Circ Physiol* 278: H2039-H2049, 2000. doi: 10.1152/ajpheart.2000.278.6.H2039. https://doi.org/10.1152/ajpheart.2000.278.6.H2039

[4] Peng CK, Havlin S, Stanley HE, Goldberger AL; Quantification of scaling exponents and crossover phenomena in nonstationary heartbeat time series. *Chaos*. 1995;5(1):82-7. https://doi.org/10.1063/1.166141

[5] Cabral, H.V., Inglis, J.G., Cudicio, A., Cogliati, M., Orizio, C., Yavuz, U.S. and Negro, F. (2024), Muscle contractile properties directly influence shared synaptic inputs to spinal motor neurons. *J Physiol*, 602: 2855-2872. https://doi.org/10.1113/JP286078


