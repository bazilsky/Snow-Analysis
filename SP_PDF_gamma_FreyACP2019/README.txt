README 							Gamma Distributions

PA 1 Oct 2018
Hello Markus,
 
1. gamma PDF: as you say, area under gamPDF is (and must be) = 1, so for real data (x axis in nm, y axis in counts per time) area can be anything, so I always fit a pseudo-gamPDF with an extra multiplier in y direction.
 
number(nm) = y-scale * gampdf(shape, scale)
 
after all, I'm only interested in the mean and mode diameter and shape.
 
The return value of the 'scale' parameter depends on the diameter units (inches, millimetre, furlong), but the mode and mean from can then be translated in the units you use.
 
2. Temporal trends in shape are indeed interesting, but despite a happy couple of evenings reading about sediment transport, it it not clear to me why even sand (which does not evaporate) has a gampdf shape? Why not more and more particles the smaller you go? Where IS all the dust in a sand storm? This is important, because we think (I assume!) that our loss of very small particles is due to evaporation… which leads onto
 
3. >>> a dedicated short BSn physics paper (including also more data from the N-ICE2015 cruise), could be a possibility, which would require I think comparison to a model such as Kouichi’s Bsn scheme <<<
 
Yes indeed! The excellent data you gathered would be most welcome addition to this puzzle .
 
I'll work up some cut down words and a figure for your paper: in the midst of a This Friday proposal deadline today, so keep nudging me.
 
atb
 
Phil
