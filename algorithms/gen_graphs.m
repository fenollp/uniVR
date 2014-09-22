clear;
name = 'cvglab-01-1.mp4_1.3_lbpface';
name1 = strcat(name, '.tsvcamshift');
name2 = strcat(name, '.tsvhaar');
name3 = strcat(name, '.tsvhog');

fid = fopen(name1,'r');
X = fread(fid);
fclose(fid);

fid2 = fopen(name2,'r');
Y = fread(fid2);
fclose(fid2);

fid3 = fopen(name3,'r');
Z = fread(fid3);
fclose(fid3);

nbl = sum(X==10);
nbl2 = sum(Y==10);
nbl3 = sum(Z==10);

log = zeros(nbl,4);
log2 = zeros(nbl2,4);
log3 = zeros(nbl3,4);

fid = fopen(name1, 'r');
fid2 = fopen(name2, 'r');
fid3 = fopen(name3, 'r');

for k=1:length(log)
    line= fscanf(fid, '%d %d %d %d\n', [1 4]);
    log(k, :) = line;
end

for j=1:length(log2)
    line2 = fscanf(fid2, '%d %d %d %d\n', [1 4]);
    log2(j, :) = line2;
end

for j=1:length(log3)
    line3 = fscanf(fid3, '%d %d %d %d\n', [1 4]);
    log3(j, :) = line3;
end

fclose(fid);
fclose(fid2);
fclose(fid3);

frameNb = log(:, 1);
time = log(:, 2);
%time = time(:) / 1000000000;
ObjCount = log(:, 3);
Objcenter = log(:, 4);

frameNb2 = log2(:, 1);
time2 = log2(:, 2);
%time2 = time2(:) / 1000000000;
ObjCount2 = log2(:, 3);
Objcenter2 = log2(:, 4);

frameNb3 = log3(:, 1);
time3 = log3(:, 2);
%time3 = time3(:) / 1000000000;
ObjCount3 = log3(:, 3);
Objcenter3 = log3(:, 4);

f1=figure('visible','off');
plot(frameNb, time, 'cyan', frameNb2, time2, 'black', frameNb3, time3, 'red', frameNb, mean(time),'--', frameNb2, mean(time2),'--',frameNb3, mean(time3),'--');
title('Compute time');
xlabel('Frames');
ylabel('Compute time(ns)');
hleg1 = legend('CamShift','Haar', 'Hog');
set(hleg1,'Location','Best');
set(hleg1,'Interpreter','none');

f2 = figure('visible','off');
plot(frameNb, Objcenter, 'cyan', frameNb2, Objcenter2, 'black', frameNb3, Objcenter3, 'red');
title('Object found');
xlabel('Frames');
ylabel('Distance between the center object and origin');
hleg1 = legend('CamShift','Haar', 'Hog');
set(hleg1,'Location','Best');
set(hleg1,'Interpreter','none');

f3 = figure('visible','off');
plot(frameNb, ObjCount, 'cyan', frameNb2, ObjCount2, 'black', frameNb3, ObjCount3, 'red');
title('Object detected');
xlabel('Frames');
ylabel('Number of detected object');
hleg1 = legend('CamShift','Haar', 'Hog');
set(hleg1,'Location','Best');
set(hleg1,'Interpreter','none');

count = nnz(ObjCount);
count2 = nnz(ObjCount2);
count3 = nnz(ObjCount3);

disp(count/length(frameNb));
disp(count2/length(frameNb2));
disp(count3/length(frameNb3));

saveas(f1, strcat(name,'.compute_time.jpg'), 'jpg');
saveas(f2, strcat(name, '.object_found.jpg'), 'jpg');
saveas(f3, strcat(name, '.object_detected.jpg'), 'jpg');