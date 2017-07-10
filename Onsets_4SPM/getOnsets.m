%%Make onsets

%Onsets: 12 names
namesOnsets = {'enc','intIG','intNX', 'intUP','PIGnov','PIGdist','PIGtarg','PNXnov','PNXtarg','PUPnov','PUPdist','PUPtarg'};

%read in probetype and trialtype
load Rando_trial
load Rando_probe

%get the right onsets

%get the onsets for encoding
%get the onsets out of Condition that belong to intIG, intNX, intUP (trialtype = 0, 1, 2)
%get the onsets out of Probetype that belong to Novel, Distractor, Target (probetype = 0, 1, 2)

