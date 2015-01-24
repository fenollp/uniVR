function ret = plotCSV(filename)

    function [dataL, dataE, dataO] = load3(filenm)
        dataL = csvread(strcat('csv_latest/',   filenm, '.csv'));
        dataE = csvread(strcat('csv_noenergy/', filenm, '.csv'));
        dataO = csvread(strcat('csv_noopti/',   filenm, '.csv'));
    end

    [dataL, dataE, dataO] = load3(filename);
    N = dataL(:, 1);

    for i=2:5
        h = figure('visible', 'off');
        plot(N, dataL(:,i), 'k-',...
             N, dataE(:,i), 'r-',...
             N, dataO(:,i), 'b-');
        xlabel('Frame Number');
        ty = '';
        switch i
            case 2
                ty = 'T';
                ylabel('Compute time (nano seconds)');
            case 3
                ty = 'X';
                ylabel('X coordinate');
            case 4
                ty = 'Y';
                ylabel('Y coordinate');
            case 5
                ty = 'Z';
                ylabel('Z coordinate');
        end
        fn = strcat('graph/', filename, '_', ty, '_LEO');
        saveas(h, fn, 'jpg');
    end

end
