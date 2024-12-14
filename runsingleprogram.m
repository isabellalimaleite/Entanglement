function datadir = runsingleprogram(program,printcycle)
    datafolder = 'C:/Users/Usuario/OneDrive/Circuits_code/data';
%     datafolder = 'data';
    programfile = ['programs/' program '.chp'];
    if isfile(programfile)
        if ~exist([datafolder '/' program], 'dir')
            mkdir(datafolder,program);
        end

        timestamp = datestr(datetime('now'),'yymmdd.HHMMSS.FFF');
        datadir = [datafolder '/' program '/' timestamp];
        mkdir([datafolder '/' program],timestamp);
    
        copyfile(programfile, [datadir '/' program '.chp']);
    else
        error(['Program ' program '.chp does not exist']);
    end
    
%     chpcmd = ['"' pwd '/programs/CHP" "' pwd '/' datadir '/' program '.chp" "' pwd '/' datadir '" ' int2str(printcycle)];
    chpcmd = ['"' pwd '/programs/main_program.exe" "' datadir '/' program '.chp" "' datadir '" ' int2str(printcycle)];
    disp(chpcmd)
    status = system(chpcmd);
end
