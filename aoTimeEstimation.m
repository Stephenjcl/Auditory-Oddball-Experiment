% Auditory Oddball mixed Time Estimation Task

%Runs a time estimation task counterbalanced with an oddball task, while
%overlaying an auditory oddball.

% Version 1.0, December 2017, Stephen JC Luehr

% Adapted from:
% A. Norton, O. Krigolson, C. Hassall, C. Williams

%Auditory Oddball
%Conditionals needed
    ao_chance = 0.1;
    ao_con = 0.75;
%This requires flipand mark, and ao_trial.m to be present.       

just_testing = 0;

if just_testing
    dummy_mode = 1;
else
    dummy_mode = 0;
end
requireResponses = 1;

if dummy_mode, useDataPixx = 0, else useDataPixx = 1, end

if ~just_testing
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    
    % We'll make sure that all the TTL digital outputs are low before we start
    Datapixx('SetDoutValues', 0);
    Datapixx('RegWrRd');
    
    % Configure digital input system for monitoring button box
    Datapixx('EnableDinDebounce');                          % Debounce button presses
    Datapixx('SetDinLog');                                  % Log button presses to default address
    Datapixx('StartDinLog');                                % Turn on logging
    Datapixx('RegWrRd');
end

% start statements
KbName('UnifyKeyNames');
odd_eeg = [];
dist_eeg = [];
data = [];

%Oddball trials per block
trialsPerBlocks = 30;

ExitKey = KbName('ESCAPE');
fKey = KbName('f');
jKey = KbName('j');

% Use the correct text in the instructions for the MUSE
left_button = 'f key';
right_button = 'j key';
left_key = 'f';
right_key = 'j';



%%Begin Time Estimation Task
rand('seed',fix(100*sum(clock)));  % this seeds the random number generator to be based on the clock

while 1

    clc;
    subject_number = input('Enter the subject number:\n','s');  % get the subject number
    data_file_name = strcat('ao_TimeEst_Behavioural_',subject_number);

    checker = exist(data_file_name);

    if checker == 0

        break

    else

        disp('Filename Already Exists!');
        WaitSecs(1);

    end

end

%sn = subject_number; %Pulls out the 4 digit participant number
%%% SET UP THE DRAWING WINDOW
background_colour = [0 0 0];
Screen('Preference','SkipSyncTests', 1) % Needed to run on the SP3s and apparently DUFFMAN

if just_testing
    [win, rec] = Screen('OpenWindow', 0, background_colour, [0 0 800 600],32,2); % Windowed, for testing
else
    [win, rec] = Screen('OpenWindow', 0, 0); % Full screen
end

% * * * Graphical Properties * * *
normal_font_size = 20;
normal_font = 'Arial';
% Fixation
fixation_colour = [0 0 0];
fixation_size = 60;
% Stimuli
this_size = 20;
thickness = 8;
% Text
text_colour = [255 255 255];
% Screen properties
xmid = rec(3)/2;
ymid = rec(4)/2;
% Set the colours
blue = [0 0 255];
green = [0 255 0];
background = imread('background.jpg');
backgroundImg = Screen('MakeTexture', win, background);

rules = imread('rules.JPG');
reward = imread('correct.JPG');
penalty = imread('error.JPG');
fixation = imread('fix.JPG');

rules = Screen('MakeTexture', win, rules);
reward = Screen('MakeTexture', win, reward);
penalty = Screen('MakeTexture', win, penalty);
fixation = Screen('MakeTexture', win, fixation);

if just_testing
    number_of_blocks = 1;   % number of blocks
else
    number_of_blocks = 10;
end

rt_goal = 1;

rt_bound = 0.1;

adjust1i = 0.015;
adjust2i = 0.003;
adjust3i = 0.012;
adjust4i = 0.003;
adjust5i = 0.030;

adjust1c = 0.015;
adjust2c = 0.012;
adjust3c = 0.003;
adjust4c = 0.030;
adjust5c = 0.003;

blocks = [1 1 2 2 3 3 4 4 5 5];
block = Shuffle(blocks);

Screen(win,'TextFont','Arial');
Screen(win,'TextSize',40);

Screen(win,'DrawText','THE EXPERIMENTER WILL NOW GIVE YOU',100,350,[255 255 255]);
Screen(win,'DrawText','SOME INSTRUCTIONS ABOUT THIS TASK',120,425,[255 255 255]);

Screen('Flip',win);

while 1
    [x,y,buttons] = GetMouse;
	if buttons(1) == 1
		break
	end
end
buttons = [];

WaitSecs(0.5);

Screen(win,'FillRect',0);

Screen(win,'TextFont','Arial');
Screen(win,'TextSize',40);

Screen(win,'DrawText','YOU ARE NOW READY TO BEGIN',200,350,[255 255 255]);
Screen(win,'DrawText','THE EXPERIMENT',325,425,[255 255 255]);

Screen('Flip',win);

while 1
    [x,y,buttons] = GetMouse;
	if buttons(1) == 1
		break
	end
end
buttons = [];

trial = 1;

for block_counter = 1:number_of_blocks

    Screen('DrawTexture', win, rules);
    Screen('Flip',win);

    WaitSecs(3);

    DrawFormattedText(win,'Get Ready!','center','center',[0 0 0]);
    Screen('Flip',win);
    WaitSecs(1);

    if just_testing
        number_of_trials = 10;
    else
        number_of_trials = 80;
    end
    right = 0;
    wrong = 0;

    for trial_counter = 1:number_of_trials

        %lptwrite(port_num,1);
        %This single line adds an auditory oddball trial, and produces a
        %marker based on stimuli.
        marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        flipandmark(win,1,useDataPixx);
        Screen('TextBackgroundColor', win, [80 80 80]);
        Screen('DrawTexture', win, fixation);
        Screen('Flip',win);
        WaitSecs(0.02);
        %lptwrite(port_num,0);
        %Screen('Flip',win); %Flip screen for consistent visual experience.
        marker = ao_trial(ao_chance, ao_con); if marker~=0, Screen('TextBackgroundColor', win, [80 80 80]), Screen('DrawTexture', win, fixation), flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        wait_time = rand(1)*0.3+0.48;
        WaitSecs(wait_time);

        start_time = GetSecs;

        %lptwrite(port_num,2);
        flipandmark(win,2,useDataPixx);
        Snd('Play',MakeBeep(3000,0.05));
        Snd('Wait');
        Snd('Quiet');
        Snd('Close');
        WaitSecs(0.02);
        %lptwrite(port_num,0);
        WaitSecs(0.12); marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        %Screen('Flip',win); %Flip screen for consistent visual experience.

        while 1
            [~, ~, keyCode, ~] = KbCheck;
            if strcmp(KbName(keyCode),'j')
                flipandmark(win,3,useDataPixx);
                 rt = GetSecs - start_time;
                 break
            end
        end

        data(trial,1) = trial;
        data(trial,2) = block_counter;
        data(trial,3) = block(block_counter);
        data(trial,4) = trial_counter;
        data(trial,5) = rt;
        data(trial,6) = rt_bound;

        WaitSecs(0.05);
        marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        %Screen('Flip',win); %Flip screen for consistent visual experience.
        WaitSecs(0.05);
        %marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        flipandmark(win,101,useDataPixx);
        Screen('TextBackgroundColor', win, [80 80 80]);
        Screen('DrawTexture', win, fixation);
        Screen('Flip',win);
        WaitSecs(0.1);
        %lptwrite(port_num,0);
        marker = ao_trial(ao_chance, ao_con); if marker~=0, Screen('TextBackgroundColor', win, [80 80 80]), Screen('DrawTexture', win, fixation), flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        %Screen('Flip',win); %Flip screen for consistent visual experience.
        wait_time = rand(1)*0.3+0.4;
        WaitSecs(wait_time);

        if (rt > (rt_goal - rt_bound)) & (rt < (rt_goal + rt_bound))

            right = right + 1;

            if block(block_counter) == 1
                rt_bound = rt_bound - adjust1c;
                trigger = 11;
            end
            if block(block_counter) == 2
                rt_bound = rt_bound - adjust2c;
                trigger = 21;
            end
            if block(block_counter) == 3
                rt_bound = rt_bound - adjust3c;
                trigger = 31;
            end
            if block(block_counter) == 4
                rt_bound = rt_bound - adjust4c;
                trigger = 41;
            end
            if block(block_counter) == 5
                rt_bound = rt_bound - adjust5c;
                trigger = 51;
            end

            %lptwrite(port_num,trigger);
            flipandmark(win,trigger,useDataPixx);
            data(trial,7) = trigger;
            Screen('DrawTexture', win, reward);
            Screen('Flip',win);

        else

            wrong = wrong + 1;

            if block(block_counter) == 1
                rt_bound = rt_bound + adjust1i;
                trigger = 12;
            end
            if block(block_counter) == 2
                rt_bound = rt_bound + adjust2i;
                trigger = 22;
            end
            if block(block_counter) == 3
                rt_bound = rt_bound + adjust3i;
                trigger = 32;
            end
            if block(block_counter) == 4
                rt_bound = rt_bound + adjust4i;
                trigger = 42;
            end
            if block(block_counter) == 5
                rt_bound = rt_bound + adjust5i;
                trigger = 52;
            end

            %lptwrite(port_num,trigger);
            flipandmark(win,trigger,useDataPixx);
            data(trial,7) = trigger;
            Screen('DrawTexture', win, penalty);
            Screen('Flip',win);

        end

        if rt_bound < 0.005
            rt_bound = 0.005
        end

        WaitSecs(0.5);
        %lptwrite(port_num,0);
        marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        %Screen('Flip',win); %Flip screen for consistent visual experience.
        WaitSecs(0.5);
        Screen('Flip',win);

        wait_time = rand(1)*0.3+0.5;
        WaitSecs(wait_time);

        data(trial,8) = str2num(subject_number);

        clc;
        disp(['Current Trial: ',num2str(trial_counter)]);
        disp(['Current Block: ',num2str(block_counter)]);
        disp(['Block Type: ',num2str(block(block_counter))]);
        disp(['Correct Guesses: ',num2str(right)]);
        disp(['Incorrect Guesses: ',num2str(wrong)]);
        disp(['Current RT: ',num2str(rt)]);
        disp('');
        disp('');
        disp('');

        trial = trial + 1;
    this_data_line = [block_counter trial_counter block(block_counter) right wrong rt];
    dlmwrite(['ao_TimeEst_Behavioural_' subject_number],this_data_line,'delimiter', '\t', '-append');
    end % of a trial

    Screen(win,'TextFont','Arial');
    Screen(win,'TextSize',40);

    Screen(win,'DrawText','THIS IS A REST BREAK',280,250,[255 0 0]);
    Screen(win,'DrawText','PLEASE PRESS',355,325,[255 0 0]);
    Screen(win,'DrawText','THE MOUSE WHEN READY TO CONTINUE',120,400,[255 0 0]);
    Screen('Flip',win);

    while 1
        [x,y,buttons] = GetMouse;
        if buttons(1) == 1
            break
        end
    end
    buttons = [];

if block_counter==1
  % Display oddball instructions
  % Instructions (what the participant sees first)
  instructions = sprintf('On each trial, you''re going to see a blue or green circle in the middle of the display\nTry to keep your eyes on the middle of the display at all times\nEach time you see a green circle, press the %s.\nEach time you see a blue circle, press the %s.\nPress space bar to proceed.',left_button,right_button);
  questions = 'Any questions?\nPress space bar to proceed.';
  Screen(win,'TextFont',normal_font);
  Screen(win,'TextSize',normal_font_size);
  DrawFormattedText(win, instructions,'center', 'center', text_colour,[],[],[],2);
  Screen('Flip',win);

  % Wait until keys are released
  [keyIsDown, ~, ~, ~] = KbCheck;
  while keyIsDown
      [keyIsDown, ~, ~, ~] = KbCheck;
  end
  WaitSecs(0.2);

  % Wait for space bar press
  done_looking = 0;
  while ~done_looking
      [~, ~, keyCode, ~] = KbCheck;
      if strcmp(KbName(keyCode),'space')
          done_looking = 1;
      end
  end


  DrawFormattedText(win, questions,'center', 'center', text_colour,[],[],[],2);
  Screen('Flip',win);

  % Wait until keys are released
  [keyIsDown, ~, ~, ~] = KbCheck;
  while keyIsDown
      [keyIsDown, ~, ~, ~] = KbCheck;
  end
  WaitSecs(0.2);

  % Wait for space bar press
  done_looking = 0;
  while ~done_looking
      [~, ~, keyCode, ~] = KbCheck;
      if strcmp(KbName(keyCode),'space')
          done_looking = 1;
      end
  end

  % END OF INSTRUCTIONS
end
  
num_odd = 0;
num_dist = 0;

% Main loop (blocks)
    % Initialize stuff
    trial_counter = 1;
    %Set oddball probabilities to match the block of Time Estimation
    %accuracy beforehand.
    if right >= wrong
        oddballProbability = wrong/(right + wrong);
    else
        oddballProbability = right/(right+wrong);
    end

    % Start of Block message
    blockStartMsg = sprintf('Beginning Block %d\n\nRemember: press the %s for green circles,\n%s for blue circles!',block_counter,left_button,right_button);
    Screen(win,'TextFont',normal_font);
    Screen(win,'TextSize',normal_font_size*2);
    DrawFormattedText(win, blockStartMsg,'center', 'center', text_colour,[],[],[],2);
    Screen('Flip',win);

    WaitSecs(3);

    % GO message
    Screen(win,'TextFont',normal_font);
    Screen(win,'TextSize',normal_font_size*2);
    DrawFormattedText(win, 'GO','center', 'center', text_colour,[],[],[],2);
    Screen('Flip',win);

    WaitSecs(1);

    % Trial loop
    odds = 0;
    for trial_counter = 1:trialsPerBlocks
        dispText = sprintf('Trial Counter = %d',trial_counter);
        %disp(dispText);
        % Decide if this is a oddball trial
        if (rand() < oddballProbability)
            odd_trial  = 0;
            odds = odds + 1;
        else
            odd_trial = 1;
        end

        % Draw crosshairs
        Screen('DrawTexture', win, backgroundImg);
        %Screen('TextSize',win,fixation_size);
        %DrawFormattedText(win, '+','center', 'center', fixation_colour,[],[],[],2);
        Screen('DrawLine', win, [fixation_colour], xmid-(this_size-5), ymid, xmid+(this_size-5), ymid, 4);
        Screen('DrawLine', win, [fixation_colour], xmid, ymid+(this_size-5), xmid, ymid-(this_size-5), 4);
        %oscsend(u,'/muse/elements/marker','i',201);
        marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), Screen('DrawTexture', win, backgroundImg), Screen('DrawLine', win, [fixation_colour], xmid-(this_size-5), ymid, xmid+(this_size-5), ymid, 4), Screen('DrawLine', win, [fixation_colour], xmid, ymid+(this_size-5), xmid, ymid-(this_size-5), 4), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        flipandmark(win,201,useDataPixx);
        %Screen('Flip',win)

        jitter_amount = (rand() - 0.5) / 5;
        WaitSecs(0.3 + jitter_amount);

        if odd_trial == 0
            square_colour = blue;
        else
            square_colour = green;
        end

        % Draw the circle
        marker = ao_trial(ao_chance, ao_con); if marker~=0, flipandmark(win, marker, useDataPixx), Screen('DrawTexture', win, backgroundImg), Screen('TextSize',win,fixation_size), WaitSecs(0.5 + (rand() - 0.5)/5), end;
        if odd_trial == 0
            %oscsend(u,'/muse/elements/marker','i',202);
            Screen('DrawTexture', win, backgroundImg);
            Screen('TextSize',win,fixation_size);
            Screen('FillOval', win , square_colour, [xmid-this_size ymid-this_size xmid+this_size ymid+this_size], thickness); % Left
            flipandmark(win,202,useDataPixx);
        else
            %oscsend(u,'/muse/elements/marker','i',203);
            Screen('DrawTexture', win, backgroundImg);
            Screen('TextSize',win,fixation_size);
            Screen('FillOval', win , square_colour, [xmid-this_size ymid-this_size xmid+this_size ymid+this_size], thickness); % Left
            flipandmark(win,203,useDataPixx);
        end

        isDone = 0;
        counter = 1;
        elapsed_time = 0;
        invalid_response = 1;
        key_pressed = 0;

        %Wait for response
        tic;
        while ~isDone
            if (requireResponses == 1)

                % Check for response
                done_looking = 0;
                while ~done_looking
                    [~, ~, keyCode, ~] = KbCheck;
                    if strcmp(KbName(keyCode),left_key)% Left
                        key_pressed = 1;
                        invalid_response = 0;
                        elapsed_time = toc;
                        done_looking = 1;
                    elseif strcmp(KbName(keyCode),right_key) % Right
                        key_pressed = 2;
                        invalid_response = 0;
                        elapsed_time = toc;
                        done_looking = 1;
                    end
                end
            end
            %If took too long
            if ((invalid_response == 0) || (toc > 2))

                if (invalid_response == 1)
                    elapsed_time = toc;
                end
                isDone = 1;
            end
        end
            % Append this trial
    this_data_line = [block_counter trial_counter odd_trial elapsed_time key_pressed invalid_response];
    dlmwrite(['ao_Oddball_Behavioural_' subject_number],this_data_line,'delimiter', '\t', '-append');
    end


    [~, ~, keyCode] = KbCheck();
    if keyCode(ExitKey)
        break;
    end

% % Wait for space bar press
% done_looking = 0;
% while ~done_looking
%     [~, ~, keyCode, ~] = KbCheck;
%     if strcmp(KbName(keyCode),'space')
%         done_looking = 1;
%     end
% end
end% of a block     

Screen(win,'TextFont','Arial');
Screen(win,'TextSize',40);

Screen(win,'DrawText','YOU ARE NOW DONE THE EXPERIMENT',110,200,[255 255 255]);
Screen(win,'DrawText','PLEASE WAIT',355,275,[255 255 255]);
Screen(win,'DrawText','SOMEONE WILL BE WITH YOU SHORTLY',120,350,[255 255 255]);
Screen(win,'DrawText','THANK YOU!',370,525,[255 255 255]);
Screen('Flip',win);

%Below here is where the data is saved for the time estimation task.
save(data_file_name,'data');
% Close the DataPixx2
if ~useDataPixx
    Datapixx('Close');
end
WaitSecs(10);
% Close the Psychtoolbox window and bring back the cursor and keyboard
Screen('CloseAll');
ListenChar(0);
ShowCursor();

disp('***** SAVING DATA *****');
written = 0; dg = 0;
while 1
    fn = strcat(data_file_name, '.mat');
    written = exist(fn);
    if written == 2
    break
    else
        disp('Saving...');
        WaitSecs(1);
        dg = dg + 1;
        if dg > 15, disp('ERROR, FILE NOT SAVED'), break, end;
    end
end
if dg < 16, disp('File Successfully Saved'), end;