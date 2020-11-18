function [marker] = ao_trial(ao_chance, ao_con)
marker = [];
if rand < ao_chance
    if rand > ao_con
        Snd('Play',MakeBeep(1600,0.05)); %Oddball
        marker = 222;
    else
        Snd('Play',MakeBeep(800,0.05)); %Control
        marker = 221;
    end
else
    marker = 0;
end
end