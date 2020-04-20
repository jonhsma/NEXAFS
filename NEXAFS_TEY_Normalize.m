% This function normalizes the TEY signal with the direct beam
% The actual TEY is obtained by subtrating the TEY with the TEY background,
% which is taken from the direct scan (where the diode is exposed. Then the
% TEY is normalized with both ALS storage ring current and the gold mesh
% current. The same normalization is applied to the diode current of the
% direct scan. After that the ALS normalized TEY will be divided by the ALS
% normalized direct current. Same goes for the I_zero normalized data.
function [Data_dir, Data_array] = NEXAFS_TEY_Normalize(Data_dir,Data_array)
	%% Some basic info and warnings
	nSpec = numel(Data_array);
	if ~isfield(Data_dir,'TEYgain') || ~isfield(Data_array,'TEYgain')
		disp('TEY gain information missing.')
		return
	end
	%% Extract the direct current
	
	% The dark current of the diode
	diode_dk_mu_arr=[];
	diode_dk_arr=[];
	diode_dk_sd_arr=[];
	for ii = 1:nSpec
		diode_dk_mu_arr = [diode_dk_mu_arr mean(Data_array(ii).Photodiode)];
		diode_dk_arr = [diode_dk_arr; mean(Data_array(ii).Photodiode)];
		diode_dk_sd_arr = [diode_dk_sd_arr std(Data_array(ii).Photodiode)/sqrt(numel(Data_array(ii).Photodiode))];
	end
	
	if std(diode_dk_arr) > max(diode_dk_sd_arr)
		disp('Inconsisten diode dark counts!')
		figure(7100)
		errorbar(diode_dk_mu_arr,diode_dk_sd_arr,'o','MarkerSize',10)
		title({'Inconsistent diode dark counts!','Diode dark counts for different runs'},...
			'interpreter','none')
		ylabel('Diode (raw)')
		set(gca,'XTickLabel',{Data_array.name},'XTickLabelRotation',-90,...
			'XTick',1:nSpec,'XLim',[0.5 nSpec+0.5],'TickLabelInterpreter','none')
	end
	
	diode_dk = mean(diode_dk_arr);
	
	%% Normalization of diode current
	Data_dir.Photodiode_dkRM = Data_dir.Photodiode - diode_dk;
	Data_dir.Photodiode_dkRM_ALS = Data_dir.Photodiode_dkRM./Data_dir.BeamCurrent;
	Data_dir.Photodiode_dkRM_Izero = Data_dir.Photodiode_dkRM./Data_dir.AI3Izero;
	
	%% TEY dark current and subtraction
	tey_dark = mean(Data_dir.TEYSignal)/(10.^(Data_dir.TEYgain));
	debug = 0;
	eShift = 0;
	
	for ii=1:nSpec
		Data_array(ii).TEYSignal_dkRM = Data_array(ii).TEYSignal./(10.^(Data_array(ii).TEYgain))-tey_dark;
		Data_array(ii).TEYSignal_dkRM_ALS = Data_array(ii).TEYSignal_dkRM./Data_array(ii).BeamCurrent;
		Data_array(ii).TEYSignal_dkRM_Izero = Data_array(ii).TEYSignal_dkRM./Data_array(ii).AI3Izero;
		Data_array(ii).TEYSignal_dkRM_ALS__Photodiode=...
			Data_array(ii).TEYSignal_dkRM_ALS./...
			interp1(Data_dir.BeamlineEnergy,Data_dir.Photodiode_dkRM_ALS,Data_array(ii).BeamlineEnergy-eShift,...
			'spline','extrap');
		Data_array(ii).TEYSignal_dkRM_Izero__Photodiode=...
			Data_array(ii).TEYSignal_dkRM_Izero./...
			interp1(Data_dir.BeamlineEnergy,Data_dir.Photodiode_dkRM_Izero,Data_array(ii).BeamlineEnergy-eShift,...
			'spline','extrap');
		Data_array(ii).TEYSignal_dkRM__Photodiode=...
			Data_array(ii).TEYSignal_dkRM./...
			interp1(Data_dir.BeamlineEnergy,Data_dir.Photodiode_dkRM,Data_array(ii).BeamlineEnergy,...
			'spline','extrap');
		
		if debug
			figure(6900+ii)
			plot(Data_array(ii).BeamlineEnergy,Data_array(ii).TEYSignal_dkRM_Izero__Photodiode)
			hold on
			plot(Data_array(ii).BeamlineEnergy,Data_array(ii).TEYSignal_dkRM_ALS__Photodiode)
		end
	end
	
	
end