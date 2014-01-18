/* PRE-MADE Pbinds playing some Melodies */

(
Pbind(
	\instrument, \sound,
	\freq, Prand([300, 200, 600], inf),
	\panning, Pseq([-1, -0.7, -0.3, 0, 0.3, 0.7, 1], inf),
	\cutoff, Prand([1,2,3,4,5,6,7,8,9,10], inf),
).play;

)