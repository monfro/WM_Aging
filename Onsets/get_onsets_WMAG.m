function make_onsets( input_args )


subs = [4];
n = length(subs);

session = 1;
fmriMode = 1;
% fmriMode = 1;
%load


for i= 1:n

    
%load suvject file.
if fmriMode == 0
    filename = sprintf('WMAG_data_s%d_session_%d.mat',subs(i),session);
elseif fmriMode == 1
    filename = sprintf('WMAG_FMRI_data_s%d_session_%d.mat',subs(i),session);
end

load(filename)

%Get start time for the task, i.e., when the task begins

%each each onsets that needs to be put in the model and subtract the onsets
%form the start time 


%so  Ignore_onsets = T.ignore_start_time - T.starttime.  

% so in the script to run the fmri study you will record the time of the
% screen flip which leads to the presentation of the to-be-ignored stimuli.
% 


%durations can be calculated by substracting the starttime (the screen flip
%which presents info on the screen from the end time - the time when the
%screen flip removes the images from the screen. Yes, this should be around
%2 seconds for all stimuli, so you could just put 2 seconds.

  onsets = cell(1,13);
    durations = cell(1,13);
    names = cell(1,13);
    %pmod = cell(1,9);


    names{1} = 'enc';
    preonsets{1} = T.encoding_on(isnan(T.encoding_on) == 0);  %preonsets{1} = T.encoding_on; 
    onsets{1} = preonsets{1} - (timingpulses(31));  
    durations{1} = T.encoding_off(isnan(T.encoding_off) == 0) - T.encoding_on(isnan(T.encoding_on) == 0);
    
%     names{2} = 'Screen';
%     onsets{2} = R.screen_onsets;
%     durations{2} = R.screen_durations;
    

    
    names{2} = 'intIG';
    preonsets{2} = T.i2_ignore_on(typetrial_cond == 0);
    onsets{2} = preonsets{2} - (timingpulses(31));
    durations{2} =  T.i2_ignore_off(typetrial_cond == 0) - T.i2_ignore_on(typetrial_cond == 0);
    
    names{3} = 'intNX';
    preonsets{3} = T.i2_noint_on(typetrial_cond == 1);
    onsets{3} = preonsets{3} - (timingpulses(31));
    durations{3} =  T.i2_noint_off(typetrial_cond == 1) - T.i2_noint_on(typetrial_cond == 1);
    
    names{4} = 'intUP';
    preonsets{4} = T.i2_update_on(typetrial_cond == 2);
    onsets{4} = preonsets{4} - (timingpulses(31));
    durations{4} =  T.i2_update_off(typetrial_cond == 2) - T.i2_update_on(typetrial_cond == 2);
    
    %% PROBES %% 
    %%IGNORE %%
    
    names{5} = 'PIGnov';
    preonsets{5} = T.probe_on(typetrial_cond == 0 & probetype_cond == 0); 
    onsets{5} = preonsets{5} - (timingpulses(31));
    durations{5} = T.probe_off(typetrial_cond == 0 & probetype_cond == 0) - preonsets{5};
    
    names{6} = 'PIGdist';
    preonsets{6} = T.probe_on(typetrial_cond == 0 & probetype_cond == 1); 
    onsets{6} = preonsets{6} - (timingpulses(31));
    durations{6} = T.probe_off(typetrial_cond == 0 & probetype_cond == 1) - preonsets{6};
    
    names{7} = 'PIGtarg';
    preonsets{7} =  T.probe_on(typetrial_cond == 0 & probetype_cond == 2); 
    onsets{7} = preonsets{7} - (timingpulses(31));
    durations{7} = T.probe_off(typetrial_cond == 0 & probetype_cond == 2) - preonsets{7};
    
    %% NX %%
    
    names{8} = 'PNXnov';
    preonsets{8} = T.probe_on(typetrial_cond == 1 & probetype_cond == 0); 
    onsets{8} = preonsets{8} - (timingpulses(31));
    durations{8} = T.probe_off(typetrial_cond == 1 & probetype_cond == 0) - preonsets{8};
    
    names{9} = 'PNXtarg';
    preonsets{9} = T.probe_on(typetrial_cond == 1 & probetype_cond == 2); 
    onsets{9} = preonsets{9} - (timingpulses(31));
    durations{9} = T.probe_off(typetrial_cond == 1 & probetype_cond == 2) - preonsets{9};
    
    %% UPDATE %%
    
    names{10} = 'PUPnov';
    preonsets{10} = T.probe_on(typetrial_cond == 2 & probetype_cond == 0); %straks: T.probe_on
    onsets{10} = preonsets{10} - (timingpulses(31));
    durations{10} = T.probe_off(typetrial_cond == 2 & probetype_cond == 0) - preonsets{10};
    
    names{11} = 'PUPdist';
    preonsets{11} = T.probe_on(typetrial_cond == 2 & probetype_cond == 1); %straks: T.probe_on
    onsets{11} = preonsets{11} - (timingpulses(31));
    durations{11} = T.probe_off(typetrial_cond == 2 & probetype_cond == 1) - preonsets{11};
    
    names{12} = 'PUPtarg';
    preonsets{12} = T.probe_on(typetrial_cond == 2 & probetype_cond == 2); %straks: T.probe_on
    onsets{12} = preonsets{12} - (timingpulses(31));
    durations{12} = T.probe_off(typetrial_cond == 2 & probetype_cond == 2) - preonsets{12};
    
    %% extra check %%
    
    names{13} = 'MotorActiv';
    onsets{13} = T.probe_on - (timingpulses(31));
    durations{13} = 0.1;
%    %parametric modulation
%     pmod = struct('name',{''},'param',{},'poly',{});
%  
%     pmod(5).name{1} = 'rt';
%     pmod(5).param{1} = [s_rt];
%     pmod(5).poly{1} = 1;   
    
       save(sprintf('NamOnsDur_s%d_session_%d_motor', subs(i), session),'names', 'onsets', 'durations') %'pmod') 
    
end 
end

