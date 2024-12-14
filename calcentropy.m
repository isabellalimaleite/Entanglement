function entrobj = calcentropy(qstate,region,stabdestab)
    % qstate includes stabilizers AND destabilizers
    if nargin < 3
        stabdestab = 'stab';
    end
    
    Nsites = length(qstate)/2;
    
    % Remove any trailing NaNs
    region = region(1:find(~isnan(region),1,'last'));
    
    if isempty(region)
        entrobj.entropy = 0;
        entrobj.region = [];
        return
    end
    
    if strcmp(stabdestab,'stab')    % Use stabilizers
        statex = qstate(Nsites+1:end,1:Nsites);
        statez = qstate(Nsites+1:end,Nsites+1:end);
    else                            % Use destabilizers
        statex = qstate(1:Nsites,1:Nsites);
        statez = qstate(1:Nsites,Nsites+1:end);
    end
    
    statesubreg = [statex(:,region+1) statez(:,region+1)];  % Add 1 to every index (CHP is indexed from 0, matlab is indexed from 1)
    
    S = gfrank(statesubreg,2) - length(region);
    
    entrobj.entropy = S;
    entrobj.region = region;
end

