function spikesg=gauss(sigma,sfreq,spikes)% GAUSS.M convolves a gaussian with spikes, outputs spikesg% function spikesg=gauss(sigma,sfreq,spikes)%% matrix input ok (spikes should lie along the columns)% to get spikes/sec, multiply spikesg by sampling frequency% modified JBB 7/27/01if nargin < 3,	disp('usage:  spikesg=gauss(sigma,sfreq,spikes);')	returnendspikes = double(spikes);dt = 1000/sfreq;sigma = sigma/dt;% if spikes is a row vector transform it to a column vectorif size(spikes, 1) == 1 & size(spikes, 2) > 1, spikes = spikes'; enddist = (-(sigma*3):(sigma*3))';									% 3 standard deviations widegaus = 1/(sigma*sqrt(2*pi))*exp(-((dist.^2)/(2*sigma^2)));		% construct gaussian envelopespikesg = [];for i = 1:size(spikes,2),	temp = conv(gaus,spikes(:,i));								% convolve envelope with spikes	spikesg(:,i) = temp(sigma*3 + 1 : size(spikes,1) + sigma*3);	% remove added pointsendspikesg = spikesg .* 1000;