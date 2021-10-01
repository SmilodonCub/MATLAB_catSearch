function [ Category_str ] = catergoryReturn_catSearchPHYSIOL( BHV )
%catergoryReturn_catSearchPHYSIOL takes in a BHV struct and returns a
%string indicating whether this experiment was run with the 'Bear' or
%'BFly' category or whether it is an 'Interleaved' experiment

findCatergory = BHV.TaskObject;
DBearLogicArray = cellfun(@(x)~isempty(strfind(x,'DBear')), findCatergory );
DBflyLogicArray = cellfun(@(x)~isempty(strfind(x,'DBfly')), findCatergory );
if sum( sum( DBearLogicArray ) ) ~= 0
    Category_str = 'Bear';
elseif sum( sum( DBflyLogicArray ) ) ~= 0
    Category_str = 'Bfly';
elseif sum( sum( DBflyLogicArray ) ) ~= 0 && sum( sum( DBearLogicArray ) ) ~= 0
    Category_str = 'Interleaved';
elseif sum( sum( DBflyLogicArray ) ) == 0 || sum( sum( DBearLogicArray ) ) == 0
    disp( 'Wut is this I don''t even know' )
end


end

