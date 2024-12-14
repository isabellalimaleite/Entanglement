function [state,rdata] = loadstatefromfile(filename)
    fileID = fopen(filename);
    rawdata = fread(fileID)';
    fclose(fileID);
    
    % First 2 bytes store Nsites
    Nsites = rawdata(1,1) + rawdata(1,2)*256;
    
    totaldatalength = length(rawdata);
    qstatedatalength = totaldatalength - 2 - 2*Nsites;  % State data, excluding Nsites (first 2 bytes) and r column vector (final 2*Nsites bytes)
    numbit32cols = ceil(sqrt(2*qstatedatalength)/32);
    
    NsitesCheck = qstatedatalength / (16 * numbit32cols);
    
    assert(NsitesCheck == Nsites);
    assert(mod(qstatedatalength,(16 * numbit32cols)) == 0);
    assert(totaldatalength == 2 + 16*Nsites*numbit32cols + 2*Nsites);
    
%     numbit32cols = ceil(Nsites / 32);
    numbytecols = numbit32cols * 4;
    numcols = Nsites;
    numrows = 2*Nsites;
     
    offset = 2; % To account for Nsites, stored in first 2 bytes
    xdata = rawdata(1,(1 + offset):(numbytecols*Nsites*2 + offset));
    zdata = rawdata(1,(numbytecols*Nsites*2 + 1 + offset):(numbytecols*Nsites*2*2 + offset));
    rdata = rawdata(1,(numbytecols*Nsites*2*2 + 1 + offset):end);
    
    xdatabin = logical(flip(int2bit(xdata,8))'); % 8-column binary array
    zdatabin = logical(flip(int2bit(zdata,8))');
    
    xdatabin = reshape(xdatabin.',[],Nsites*2).';
    zdatabin = reshape(zdatabin.',[],Nsites*2).';
    
    state = [xdatabin(:,1:numcols) zdatabin(:,1:numcols)]; % Throw away extra 0's at end of 32-bit packaging
    rdata = rdata';
    
%     % CHP counts qubits starting from site 0, so if you want to start counting from 1, you must throw away site 0
%     Nsites = Nsites - 1;
%     state = [state(2:Nsites+1,2:Nsites+1) state(2:Nsites+1,Nsites+3:end); state(Nsites+3:end,2:Nsites+1) state(Nsites+3:end,Nsites+3:end)];
end

