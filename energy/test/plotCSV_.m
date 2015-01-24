function ret = plotCSV_(filename)

    function [dataL, dataE, dataO] = load3(filenm)
        dataL = csvread(strcat('csv_latest/',   filenm, '.csv'));
        dataE = csvread(strcat('csv_noenergy/', filenm, '.csv'));
        dataO = csvread(strcat('csv_noopti/',   filenm, '.csv'));
    end

    [dataL, dataE, dataO] = load3(filename);
    N = dataL(:, 1);
    h = figure('visible', 'off');

    set(gcf, 'Color', 'white'); % white bckgr

    for i=2:5
        subplot(2, 2, i - 1);
        switch i
            case 2
                dataL(:,i) = dataL(:,i) / (1000^2);
                dataE(:,i) = dataE(:,i) / (1000^2);
                dataO(:,i) = dataO(:,i) / (1000^2);
        end
        plot(N, dataL(:,i), 'k:',... % Latest : black
             N, dataE(:,i), 'r:',... % noEnergy : red
             N, dataO(:,i), 'b:');   % noOpti : blue
        xlabel('Frame Number');
        switch i
            case 2
                ylabel('Compute time (ms)');
            case 3
                ylabel('X coordinate');
            case 4
                ylabel('Y coordinate');
            case 5
                ylabel('Z coordinate');
        end
    end
    fn = strcat('graph/', filename, '_LEO');
    export_fig(gcf, fn, '-painters', '-jpg', '-r300');

end
