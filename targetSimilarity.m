function [ targetsimilarity, targetsimilarity_targetID, fix_rgb, target_index_ids] = targetSimilarity( category )
%targetSimilarity will load the appropriate category specific
%targetsimilarity matrix and make a small alteration to the name string.
%the alteration makes the name compatible with the names used by the
%stimulus images used by monkeylogic(as opposed to the original images).
%additionally, this function returns the category specific values for the
%fix_rgb and the target_index_ids used by the TextFile fxn.


if strcmpi(category, 'BFly')
    fix_rgb = [ 0 0 1]; %Blue fixation square.
    target_index_ids = [ 1 2 3 4 5 6 7 8 9 10 ];
    load('bflysimilarity.mat') %bearsimilarity matrix ranks the chi^2 distance
    %of various image features between the 500 distractors & each target
    %bfly
    %1st column is the distractor sstring names, second is average distractor
    %distances for all bfly targets, 3:11 are distractor rankings for each
    %bfly
    load( 'bflysimilarity_targetID' ) %bfly target for each column of bflysimilarity
    targetsimilarity = bflysimilarity;
    targetsimilarity_targetID = bflysimilarity_targetID;
    
    for ii = 1:size( targetsimilarity,1 )
        entry = targetsimilarity{ ii,1 };
        new_name = [ 'DBfly_' char(entry) ];
        targetsimilarity{ ii,1 } = new_name;
    end
elseif strcmpi(category, 'Bear')
    fix_rgb = [ 1 0 0 ]; %Red fixation square
    target_index_ids = [ 84 36 147 25 40 123 99 102 10 57 ];
    %bear similarity by target
    load('bearsimilarity.mat') %bearsimilarity matrix ranks the chi^2 distance
    %of various image features between the 500 distractors & each target teddy bear
    %1st column is the distractor sstring names, second is average distractor
    %distances for all bear targets, 3:11 are distractor rankings for each bear
    load( 'bearsimilarity_targetID' ) %bear target for each column of bearsimilarity
    targetsimilarity = bearsimilarity;
    targetsimilarity_targetID = bearsimilarity_targetID;
    
    
    for ii = 1:size( targetsimilarity,1 )
        entry = targetsimilarity{ ii,1 };
        entry_split = regexp(entry, '\_', 'split');
        new_name = [ char(entry_split(1)) 'Bear_' char(entry_split(2)) ];
        targetsimilarity{ ii,1 } = new_name;
    end
end

end

