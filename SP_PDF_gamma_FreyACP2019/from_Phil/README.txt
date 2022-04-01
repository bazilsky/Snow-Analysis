******************************************************************************************************************************************************
30 October 2018 

Hello Markus: suggested text for end of section 4.1.1.
 
>>> 
A Monte Carlo model which generates multiple noisy gamma distributions of known [apha] and [beta]  shows that retrieving these parameters is robust, even when the data are limited to d_p >  mode of the distribution; that is, only the tail is captured in the data. Furthermore, the uncertainty in [apha] and [beta] can also be retrieved from the relative scale of the smallest bin and the residual noise.  Care is needed however, not to assume that the limited (or under-sampled) data are 'normal'; if they are under-sampled, the distribution is not unity: instead, the function fitting must include a gain parameter in the y-axis.
<<< 
 
What this means is that if you only want shape and scale (to get mean diameter) then fit
 
p(3) * gampdf(p(1), p(2))
 
where p are THREE fitted parameters. You can fit this to the raw data, (p(3) is then in the millions but it doesn't matter): you then ignore p(3). Also, ensure that the x and y data you send to fminsearch (or similar) is ONLY the valid measurements: don't pad the smaller bins with zeros, or the curve will attempt to accomodate  those data as well.
 
What you then get is values of mean D and variance which are different from just averaging and StandardDeviation-ing you data, because the fitted curve is now, effectively, including the unseen data < minimum-bin.
 
atb
 
Phil



******************************************************************************************************************************************************
30 October 2018 

Hello Marcus,
 
Again sorry for delay, I have been awaiting some feedback from Kouishi:
 
My simple modelling of the clipped gamma function appears (not proven yet) that the Dover and Nishimura papers may have an artefact in their shape parameter and mean diameter profiles, due to taking mean and variance directly from the histograms, whilst the gampdf fitting using matlab does not have this artifact. I sent Kouishi an email last night asking him to check my analysis, as he may point out my mistake in the coding, or already be aware of the effect and has corrected for it.
 
But in the mean time, until he replies one way or another (+ following discussion) , I want to let you finish and submit your paper. So, I will suggest a minimal sentence or paragraph for you that does not touch on the issue.
 
atb
 
Phil


******************************************************************************************************************************************************
29 October 2018 

Hello Markus,
 
Have been working on the blowing snow over the weekend: instead of greater clarity, alas, I am now even more puzzled.
 
1. Good news: some nice plots now available if you are interested for your paper: examples attached (see below for explanation)
 
2. Re-reading Dover thesis, there is no real evidence that 'shape' changes significantly with height: ou data show similar on the occasions when CROW is operating well (less often the SEAICE unit). So at least we don't have to worry about that!
 
3. Mean particle diameter can then be taken from the curve fitting: mean = shape * scale. The above plots show this: a lot of noise, a bit of signal, but no blindingly clear case that CROW has a smaller mean diameter than SEAICE.  Very oddÉ
 
4. Total number (as calculated from integrating the gampdf) IS blindingly different (phew!). You saw this years ago when the data returned, just that the gampdf make it more plot-able.
 
So, in practical terms for your paper: I'll write a paragraph on the gampdf fitting and give typical uncertainty for shape.
 
PLOTS Taken from the 'best' of the 8 events: July 26th
 
the shscD plot shows the two time series of shape and scale for CROW and SEAICE, with the mean diameter ( = shape x scale) below: mean D does not change significantly over time OR between the two instruments! OddÉ Finally bottom right: the sum of the gamma PDF which is a proxy for total number density: I need to show this as a ratio but ran out of timeÉ
 
Other plot is a surface plot of the SPC data fro the two instruments: might be better one on top of the otherÉ you can use or ignore, I just find these useful to visualise where there are events and also identify the odd behaviour of CROW SPC below 100 um on most records (clipped out of this plot) . NB eyeballing the data show ca x20 more particles at SEAICE than CROW.
 
sorry for delay
 
Phil

***********************************************************************************************************************************************************
3 October
Hello Markus, All,
 
Very pleased to be part of the paper: exciting progress on the topic of measured snow distributions. Still working up Monte Carlo Matlab experiments to get sigma (uncertainty on estimate) on the shape parameter given known residual noise and known clipping ('the ignoring of') the smaller bins.
 
Couple of immediate points in the interim, if I may:
 
1. On previous measurements of  shape parameter as a function of height above surface, was any note taken of literature from non-evaporative systems with gravitational settling, such as sand storms, river sediments, or (from a Julian Hunt comment decades ago) particles in power plant cooling systems? I ask this as it is clear that the mean (or mode) diameter will decrease with height, but I was not aware of a mechanism for shape parameter change with height É most happy to be informed.
 
2a. I'd suggest care when presenting the climate of 'moisture content' (e.g. figure 3) as a specific humidity, qv. This unit is vital for the chemistry, but because the atmosphere near the ice surface is most often saturated (air and surface are in dynamic equilibrium), the qv follows a well-defined exponential dependence on temperature. The 'windrose' climate of qv is therefore very nearly identical to that for air temperature, Ta. For the purposes of the physical evolution of the blowing snow event, it is the evaporative behaviour of the system that is a significant constraint, that is the Relative Humidity, RH. RH is effectively  a measure of the 'evaporating power' of the air. So, all other effects being equal, RH=90% will evaporate surface or particles twice as effectively as RH=95%.
 
2b. Given that, be very clear that you present RH  'with respect to ice', even though data from Polarstern, forecasts and most instruments report it as 'with respect to water': they are different. I can hand over some Matlab (or even C !) functions that convert between forms.
 
atb
 
Phil
