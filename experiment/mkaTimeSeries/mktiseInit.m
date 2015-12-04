function [config, store] = mktiseInit(config)                      
% mktiseInit INITIALIZATION of the expCode project mkaTimeSeries   
%    [config, store] = mktiseInit(config)                          
%      - config : expCode configuration state                      
%      -- store  : processing data to be saved for the other steps 
                                                                   
% Copyright: Mathieu Lagrange                                      
% Date: 26-Aug-2014                                                
                                                                   
if nargin==0, mkaTimeSeries(); return; else store=[]; end                         
                                                       
 expMex(config, 'dtw', 'dtw_c.c');

  expMex(config, 'dependencies/clusteringAlgorithms/kAverages', 'kaverages', 'compileKAverages');

   expMex(config, '../kAverages', 'kaverages', 'compileKAverages');

