function [ taskVariableVal ] = BHV_VariableValue( BHV, trialNum, taskVariableName_str )
%BHV_VariableValue takes in the trialNum integer value and the
%taskVariableName string. This function return the taskVariable's value at 
%the point in the experiment when the trialNum was executed to return the 
%proper integer value in case the variable's value was changed over the 
%course of the experiment.
%EXAMPLE
%taskVariableName_str = 'target_window'; 
%targetWindowRadius = BHV_VariableValue( BHV, trialNum, taskVariableName_str )
% targetWindowRadius =
% 
%      6

Stem_str = 'BHV.VariableChanges.';
Trial_str = '.Trial';
Value_str = '.Value( ';


eval_str = [ Stem_str taskVariableName_str Trial_str ];
variableChangeTrials = eval( eval_str );

% find the maximun value of variableChangeTrials where trialNum <=
% variableChangeTrials
variableChangeLessThan = trialNum >= variableChangeTrials;
[ A taskVariableValue_idx ] = max( variableChangeTrials( variableChangeLessThan ) );

eval_str2 = [ Stem_str taskVariableName_str Value_str 'taskVariableValue_idx )' ];
taskVariableVal = eval( eval_str2 );


end

