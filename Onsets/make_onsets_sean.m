function make_onsets( input_args )


subs = [];

%load

for i= 1:numel(subs)

    
%load suvject file.


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




  onsets = cell(1,6);
    durations = cell(1,6);
    names = cell(1,6);
    %pmod = cell(1,9);


    names{1} = 'i1';
    onsets{1} = R.i1_onsets;
    durations{1} = R.i1_durations;
    
%     names{2} = 'Screen';
%     onsets{2} = R.screen_onsets;
%     durations{2} = R.screen_durations;
    

    
    names{2} = 'i2_ignore';
    onsets{2} = R.i2_ignore_onsets;
    durations{2} =  R.i2_ignore_durations;
    
    names{3} = 'i2_nx';
    onsets{3} = R.i2_fixation_onsets;
    durations{3} =  R.i2_fixation_durations;
    
    names{4} = 'i2_update';
    onsets{4} = R.i2_update_onsets;
    durations{4} =  R.i2_update_durations;
    
    names{5} = 'probe';
    onsets{5} = R.probe_all_onsets;
    durations{5} = 0;
    
    names{6} = 'accuracy';
    onsets{6} = R.end_block_onsets; 
    durations{6} = R.end_block_durations;
    
   %parametric modulation
    pmod = struct('name',{''},'param',{},'poly',{});

    
    
    pmod(5).name{1} = 'rt';
    pmod(5).param{1} = [s_rt];
    pmod(5).poly{1} = 1;   
    
       save('insert subject name and directory to save','names', 'onsets', 'durations', 'pmod') 
    
end 
end

