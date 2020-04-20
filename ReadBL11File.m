function Data=ReadBL11File(path)
	fileText = fileread(path);
	lineBreaks = find(fileText==13);
	%disp(fileText(1:lineBreaks(15)))
	
	Data.path = path;
	
	[~,Data.name,~]=fileparts(path);
	
	Data.Date =...
		fileText(lineBreaks(3)+6:... 
			lineBreaks(4));	
	Data.Scan_Config =...
		fileText(lineBreaks(2)+2:... The +2 is to accomodate the carriage return
			lineBreaks(3));
	Data.Scan_Type =...
		fileText(lineBreaks(3)+2:... The +2 is to accomodate the carriage return
			lineBreaks(4));
	Data.Script_Path =...
		fileText(lineBreaks(4)+2:... The +2 is to accomodate the carriage return
			lineBreaks(5));
	
	% un-nammed quantity counter
	UNQ_counter = 0;
	
	for ii=6:15
		currLine = fileText(lineBreaks(ii-1)+2:... The +2 is to accomodate the carriage return
			lineBreaks(ii));
		cln_x = find(currLine==58);
		eql_x = find(currLine==61);
		
		if ~isempty(cln_x)
			sep = ':';
			sep_x = cln_x;
		elseif ~isempty(eql_x)
			sep = '=';
			sep_x = eql_x;
		else
			sep = '';
			sep_x = 0;
		end
		
		if sep_x <=1
			UNQ_counter = UNQ_counter+1;
			fieldName = ['UnnamedQuantity_' sprintf('%03d',UNQ_counter)];
		else
			fieldName = currLine(1: sep_x -1);
			fieldName(fieldName=='('|...
				fieldName==')'|...
				fieldName==' '|...
				fieldName=='-'...
				) = '_';
		end
		
		numeric = str2double(currLine(sep_x + 1:end));
		%display(numeric)
		if ~isnan(numeric)
			item = numeric;
		else
			item = currLine(sep_x + 1:end);
		end
		Data.(fieldName)=item;
	end
	
	% Temporary file. Use random names in case I need parallelization
	tempFilename = ['temp' sprintf('%05d',round(rand()*10000)) '.dat'];
	
	tfp = fopen(tempFilename,"wt");
	fprintf(tfp,'%s',fileText(lineBreaks(15)+2:end));
	fclose(tfp);
	
	array_data=table2struct(readtable(tempFilename));
	
	arrfldnms = fieldnames(array_data);
	for kk = 1:numel(arrfldnms)
		Data.(arrfldnms{kk})=[array_data.(arrfldnms{kk})]';
	end
	
	delete(tempFilename)
	
end
