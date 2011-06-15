%% GO TO THE CURRENT DIRECTORY
if ispc,
  cd('q:/');
else
  %cd('/Volumes/public_hamm/PCIMESSLAB3/data/20110526/');
  cd('/Users/robbert/Desktop/20110526/');
end

%% MEASUREMENTS
% description
j = 1;

name = 'pepandprot';
pop_time = 300;
time_stamp = 1439;
undersampling = 1;

mess(j) = load2d(name, pop_time, time_stamp, 'meta', true);
mess(j).undersampling = undersampling;
mess(j) = freq2d(mess(j));
mess(j).w3 = mess(j).freq - 0;


%% CALCULATE
j = 1;

zeropadding = 1; % how many times should be zeropadded

mess(j) = absorptive2d(mess(j),...
  'phase', mess(j).phase,...
  'zeropad', zeropadding * length(mess(j).time),...
  'range', [mess(j).freq(1), mess(j).freq(end)],...
  'fft_type','sgrsfft');

figure(j),clf
rb2dPlot(mess(j))

%% SHOW TIME DOMAIN
j = 1;

figure(j),clf
rbPlotTime(srun(j), 'pixel', 0, 'plot', 'time', 'ylim', [-200 200])

%% REPLOT
figure(j),clf
rb2dPlot(mess(j))
