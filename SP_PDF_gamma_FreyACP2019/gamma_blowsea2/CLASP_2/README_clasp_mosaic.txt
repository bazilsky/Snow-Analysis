README    	CLASP - Compact Light Weight Aerosol Spectrometer Probe  MOSAiC 2019/20
March-2021 (MF)

FILES
clasp_all_1min.mat
f_plot_meteo_CLASP_SPC.m - plot figure (in SPC/m_files/plotting_routines)


VARIABLES
CLASP[struct]   .conc [number_density_cm^-3 sigma_cm^-3 N]; QCed but not filtered for pollution  


METHOD (see CLASP-manual-MOSAiC.docx)

size-segregated total particle count at 10Hz sampling frequency
16 size bins with mean particle radii (!!) 0.275-10 micrometer:
0.275, 0.3375, 0.4375, 0.575, 0.75, 1, 1.325, 1.75, 2.25, 2.8, 3.55, 4.5, 5.625, 6.875, 8.25, 10
set pump flow rate: 2701 (~3 STP-L/min)

Unit P at 2m (MetCity Tower)

DATA PROCESSING

N = h * SR * Q-1

N, particle number density (particle cm-3)
h, particle count histogram (-)
SR, sample rate (s-1)
Q, pump flow rate at STP (cm3 s-1)

Matlab Variable histogram = h * SR (particle s-1 or particle min-1)


RUN_CLASP.m % Main routine calling functions f_*.m
f_CLASP_proc_MOSAiC.m % Read, preprocess & plot raw CLASP 10Hz data
f_CLASP_read_MOSAiC.m % import ASCII data from 2019/20 MOSAiC
f_CLASP_apply_cal_MOSAiC.m % create warning flags and apply flow correction
f_CLASP_average_MOSAiC.m % average CLASP 10Hz data
f_CLASP_combine_MOSAiC.m % combine daily CLASP mat files
f_CLASP_plot_MOSAiC.m % plot CLASP on selected days


Questions for IB (1/4/2021)
- LaserRef out of bounds?
- post-season calibration?
- files 3..2MB but no text data …
- change of Unit in July 2020?

TODO
QC  - remove pollution (if any)
Compare to GRIMM data




REFERENCES:

Hill, M. K., Brooks, B. J., Norris, S. J., Smith, M. H., Brooks, I. M., and de Leeuw, G.: A Compact Lightweight Aerosol Spectrometer Probe (CLASP), Journal of Atmospheric and Oceanic Technology, 25, 1996–2006, doi: 10.1175/2008JTECHA1051.1, 2008.

Norris, S. J., Brooks, I. M., de Leeuw, G., Smith, M. H., Moerman, M., and Lingard, J. J. N.: Eddy covariance measurements of sea spray particles over the Atlantic Ocean, Atmospheric Chemistry and Physics, 8, 555–563, doi: 10.5194/acp-8-555-2008, 2008.
