import random

# generates a random vector within the unit cube
def rand_vec():
	return (random.random()*2-1, random.random()*2-1)

def vec_sqrmag(v):
	return v[0]*v[0] + v[1]*v[1]

nsamples = 16
f = open("angleBasedAOSamples.txt", 'w')
for i in range(nsamples):
	v = rand_vec()
	# gen sample within radius of 1
	while vec_sqrmag(v) > 1.0:
		v = rand_vec()
	f.write("float2(%f, %f),\n" % (v[0], v[1]))
f.write("float2(0,0)\n")
