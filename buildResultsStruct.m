function Results = buildResultsStruct(code, metrics)

    Results = struct();
    Results.Code     = code;
    Results.Lag      = metrics.lag;
    Results.Corr     = metrics.corr;
    Results.AUC      = metrics.AUC;
    Results.NormAUC  = metrics.normAUC;
    
    if isfield(metrics,'LRlag')
        Results.LRlag    = metrics.LRlag;
        Results.LRcorr   =  metrics.LRcorr;
    end

end