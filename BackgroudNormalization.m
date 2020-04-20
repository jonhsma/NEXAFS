function Data_out = BackgroudNormalization(Data,specName,varargin)
	if numel(Data)>1
		for ii = 1:numel(Data)
			Data_out(ii)=BackgroudNormalization(Data(ii),specName,varargin{:});
		end
		return
	end
	
	%% Defaults and what not
	if ~isfield(Data,specName)
		disp(['Field ' specName ' does not exist'])
		return
	else 
		resultName=[specName '_bkNRM'];
	end
	eStart = min([Data.BeamlineEnergy],[],'all');
	eEnd = max([Data.BeamlineEnergy],[],'all');
	lnBkgRng=[eStart, eStart + 10];
	heBkgRng=[eEnd-10 eEnd];
	heln = 0; % linear fit for high energy background
	norm2nd = 0; % secondary multiplicative normalization
	additional = 0;
	
	ii = 1;
	while ii <=numel(varargin)
		if regexp(varargin{ii},'heln')
			heln = 1;
			ii=ii+1;
		elseif regexp(varargin{ii},'ln')
			lnBkgRng = varargin{ii+1};
			ii=ii+2;
		elseif regexp(varargin{ii},'he')
			heBkgRng = varargin{ii+1};
			ii=ii+2;
		else
			ii=ii+2;
		end
	end
	
	% get the x-axis
	x_axis = Data.BeamlineEnergy;
	% spectrum of interest
	SOI = Data.(specName);
	
	%select the range
	ln_idxRange = x_axis >= lnBkgRng(1) & x_axis <= lnBkgRng(2);
	
	% linear fit
	xMatrix=x_axis(ln_idxRange);
	xMatrix(:,2)=xMatrix;
	xMatrix(:,1)=1;
	
	coef=xMatrix\SOI(ln_idxRange);
	
	Data.(resultName)=Data.(specName)-coef(1)-...
		Data.BeamlineEnergy*coef(2);
	% high energy normalization
	he_idxRange = x_axis >= heBkgRng(1) & x_axis <= heBkgRng(2);
	if heln
		xMatrix=x_axis(he_idxRange);
		xMatrix(:,2)=xMatrix;
		xMatrix(:,1)=1;
		coef=xMatrix\Data.(resultName)(he_idxRange);
		mul = coef(1)+x_axis*coef(2);
		temp=Data.(resultName)./mul;
		temp(x_axis>heBkgRng(2)) = NaN;
		Data.(resultName) = temp;
		
		if norm2nd
		end
	else
		mu = mean(Data.(resultName)(he_idxRange));
		Data.(resultName)=Data.(resultName)./mu;
	end
		
	Data_out=Data;

end

