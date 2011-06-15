function [w,p] = fftFreqAxis(t,varargin)
%function [w,p]= fftFreqAxis(t,varargin)
% 'time_units' = {'ps','fs','unitless'}
% 'freq_units' = { {'wavenumbers','cm-1'},'Hz','eV',{'unitless','radians'}}
% 'fftshift' = {'on','off'}
% 'zeropad' = zeropaddedlength
% 'undersampling' = undersampling
%
% p is an optional struct of 
% p.resolution
% p.centerfreq
% p.delta_w (width in freq space, i.e. <a>)
% p.dw (frequency spacing)
% p.ind (index of the band containing the center freq)
%
% a quick word on undersampling: when I say undersampling of n, I mean that
% the time step is (2n+1)*dt_ny, where dt_ny is the nyquist sampling rate
% dt_ny=1/(4*nu_main), where nu_main is the central frequency in Hz (not
% rad or cm-1) so if the main frequency is 1600 cm-1 (20 fs period), the
% nyquist dt_ny = 5 fs, so undersampling n=1 means dt = (2*1+1)*5 =15 fs,
% n=2 => 25 fs etc

% global c q h
c = 2.9979e10;
q = 1.6e-19;
h = 6.626e-34;

%old defaults
%time_units = 'unitless'
%freq_units = 'unitless'
%shift = 'normal'

%set default values
time_units = 'ps';
freq_units = 'wavenumbers';
shift = 'on';
n_under = 0;

n_t = length(t);

%read optional arguments
while length(varargin)>=2
  arg = varargin{1};
  value = varargin{2};

  switch lower(arg)
    case {'time','time_units'}
      time_units= value;
    case {'freq','freq_units'}
      freq_units = value;
    case {'fftshift','shift'}
      shift = value;
    case {'zeropad','zero_pad'}
      if ~isempty(value)&&value~=0
        n_t = value;
      end
    case {'undersampling','n_under'}
      n_under = value;
    otherwise
      warning(['Unknown option ' arg ' in fftFreqAxis']);
  end
  varargin = varargin(3:end);
end

if n_under>0 && strcmpi(shift,'on')
  %shift = 'off';
  warning('fftFreqAxis: use p.ind to find the right part of the spectrum');
end

if any(isempty([c h q ]))
  error('Physical constants c h and q are missing! Rerun startup.m or define them as global')
end
conversion = 1;
switch lower(freq_units)
  case {'wavenumbers','cm-1'}
    conversion =conversion*c;
  case 'hz'
    warning([freq_units ' not yet tested!']);
  case 'ev'
    conversion = conversion*q/h;
  case {'unitless','radians'}
    warning([freq_units ' not yet tested!']);
    conversion = conversion/(2*pi);
  otherwise
    error('Could not deterimine the frequency units you want in fftFreqAxis');    
end
switch time_units
  case 'ps'
    conversion = conversion*1e-12;
  case 'fs'
    conversion = conversion*1e-15;
  case 'unitless'
    warning([time_units ' not yet tested!']);
    conversion = conversion;
  otherwise
    error('Could not deterimine the time units you want in fftFreqAxis');    
end


dt = t(2)-t(1);
a=1/dt/conversion;
dw = a/n_t;
switch lower(shift)
  case 'on'
    if mod(n_t,2)==0
      %disp('even')
      w=(-a/2:dw:a/2-dw);
    else
      %disp('odd')
      w=(-a/2:dw:a/2-dw)+dw/2;
    end
  case 'off'
    w = (0:(n_t-1))*dw;
  otherwise
    error(['Couldn''t determine whether or not to fftshift axis with shift ' shift]);
end

resolution = 1/(n_t*dt*conversion);
w_center = (2*n_under+1)/(4*dt*conversion);
w = w+w_center*(1-mod(2*n_under+1,4)/(2*n_under+1));

p.resolution = resolution;
p.centerfreq = w_center;
p.delta_w = a;
p.dw = dw;

ind = find(w >= w_center-a/4 &w <= w_center+a/4);
p.ind = ind;

%disp(['res ' num2str(resolution)]);
%disp(['center ' num2str(w_center)]);
