function get_onsets_WMAG
%get NameOnsetDuration file for all pps based on behavioral log files acquired during fMRI

clc
cd
datadir = 'M:\B_PhD\Tyro_Old\WMAG\WMAG_data\Behavior\analysis1_beh\';
outputdir = 'M:\B_PhD\Tyro_Old\WMAG\WMAG_analysis\Onsets\OnsetFiles\';

addpath(datadir)
addpath(outputdir)

%load drug decoding because it includes subject numbers
load('M:\B_PhD\Tyro_Old\WMAG\WMAG_data\Others\DrugDecoding_all.mat')
subs = DrugDecoding.AnalysisWM(:,1);
n = length(subs);

for i= 1:n
    for day =1:2

    %load subject file.
    filename = sprintf('WMAG_data_prep_s%dsession_%d.mat',subs(i),day);
    load(filename)

    %Get start time for the task, i.e., when the task begins
    start = timingpulses(31);
    
    %prepare empty matrices
    names = cell(1,13);
    onsets = cell(1,13);
    durations = cell(1,13);
    
    % for each onset that needs to be put in the model subtract the onsets form the start time 
    % so  Ignore_onsets = T.ignore_start_time - T.starttime.  
    %durations can be calculated by substracting the starttime (the screen flip
    %which presents info on the screen from the end time - the time when the
    %screen flip removes the images from the screen (around 2 seconds for all stimuli)

    %% encoding 
    names{1} = 'enc';
    preonsets{1} = T.encoding_on(isnan(T.encoding_on) == 0);  %preonsets{1} = T.encoding_on; 
    onsets{1} = preonsets{1} - start;  
    durations{1} = T.encoding_off(isnan(T.encoding_off) == 0) - T.encoding_on(isnan(T.encoding_on) == 0);
    
    %% intervening stimuli; IG = ignore, NX = no interference, UP = update
    names{2} = 'intIG';
    preonsets{2} = T.i2_ignore_on(typetrial_cond == 0);
    onsets{2} = preonsets{2} - start;
    durations{2} =  T.i2_ignore_off(typetrial_cond == 0) - T.i2_ignore_on(typetrial_cond == 0);
    
    names{3} = 'intNX';
    preonsets{3} = T.i2_noint_on(typetrial_cond == 1);
    onsets{3} = preonsets{3} - start;
    durations{3} =  T.i2_noint_off(typetrial_cond == 1) - T.i2_noint_on(typetrial_cond == 1);
    
    names{4} = 'intUP';
    preonsets{4} = T.i2_update_on(typetrial_cond == 2);
    onsets{4} = preonsets{4} - start;
    durations{4} =  T.i2_update_off(typetrial_cond == 2) - T.i2_update_on(typetrial_cond == 2);
    
    %% probes for all conditions above, split for nov = novel, dist = distracter, targ = target
    names{5} = 'pIGnov';
    preonsets{5} = T.probe_on(typetrial_cond == 0 & probetype_cond == 0); 
    onsets{5} = preonsets{5} - start;
    durations{5} = T.probe_off(typetrial_cond == 0 & probetype_cond == 0) - preonsets{5};
    
    names{6} = 'pIGdist';
    preonsets{6} = T.probe_on(typetrial_cond == 0 & probetype_cond == 1); 
    onsets{6} = preonsets{6} - start;
    durations{6} = T.probe_off(typetrial_cond == 0 & probetype_cond == 1) - preonsets{6};
    
    names{7} = 'pIGtarg';
    preonsets{7} =  T.probe_on(typetrial_cond == 0 & probetype_cond == 2); 
    onsets{7} = preonsets{7} - start;
    durations{7} = T.probe_off(typetrial_cond == 0 & probetype_cond == 2) - preonsets{7};
    
    names{8} = 'pNXnov';
    preonsets{8} = T.probe_on(typetrial_cond == 1 & probetype_cond == 0); 
    onsets{8} = preonsets{8} - start;
    durations{8} = T.probe_off(typetrial_cond == 1 & probetype_cond == 0) - preonsets{8};
    
    names{9} = 'pNXtarg';
    preonsets{9} = T.probe_on(typetrial_cond == 1 & probetype_cond == 2); 
    onsets{9} = preonsets{9} - start;
    durations{9} = T.probe_off(typetrial_cond == 1 & probetype_cond == 2) - preonsets{9};
    
    names{10} = 'pUPnov';
    preonsets{10} = T.probe_on(typetrial_cond == 2 & probetype_cond == 0); %straks: T.probe_on
    onsets{10} = preonsets{10} - start;
    durations{10} = T.probe_off(typetrial_cond == 2 & probetype_cond == 0) - preonsets{10};
    
    names{11} = 'pUPdist';
    preonsets{11} = T.probe_on(typetrial_cond == 2 & probetype_cond == 1); %straks: T.probe_on
    onsets{11} = preonsets{11} - start;
    durations{11} = T.probe_off(typetrial_cond == 2 & probetype_cond == 1) - preonsets{11};
    
    names{12} = 'pUPtarg';
    preonsets{12} = T.probe_on(typetrial_cond == 2 & probetype_cond == 2); %straks: T.probe_on
    onsets{12} = preonsets{12} - start;
    durations{12} = T.probe_off(typetrial_cond == 2 & probetype_cond == 2) - preonsets{12};
    
    %% extra check %% --> movement
    
    names{13} = 'Motor';
    onsets{13} = T.probe_on - start;
    durations{13} = 0.1;
    
    
%    %parametric modulation
%     pmod = struct('name',{''},'param',{},'poly',{});
%  
%     pmod(5).name{1} = 'rt';
%     pmod(5).param{1} = [s_rt];
%     pmod(5).poly{1} = 1;   
    
    save(fullfile(outputdir,sprintf('NamOnsDur_s%d_session_%d', subs(i), day)),'names', 'onsets', 'durations')
    end
end 
end

