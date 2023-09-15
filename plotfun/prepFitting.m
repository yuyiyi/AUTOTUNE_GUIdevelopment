function [stampsel, glist, funcsel, neusel,ifcircular, fmodel,...
    fmodel_Independent,fmodel_Coefficients,fmodel_startpoint, dosave] = ...
    prepFitting(handles, ttlabel, varsel, mainfig_pos)
    dosave = 0;
    fmodel = '';
    funcsel = 1;
    ifcircular = 0;
    neusel = [];
    fmodel_Independent = ''; 
    fmodel_Coefficients = '';
    fmodel_startpoint = [];
    scrsz = handles.scrsz;
    pos = mainfig_pos;
    pos(1) = pos(1)+100;
    pos(3) = pos(3)-200;

    stampinfo = handles.stampinfo{1};
    varNames = stampinfo.Properties.VariableNames;

    glist = sort(unique(table2array(stampinfo(:,varsel))),1);
    
    N = length(glist);
    hplot = figure(25); clf('reset')
    set(hplot, 'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...        
        'Name', 'Set up fitting', 'Position', pos);
    
    % list stimulus stamps
    uicontrol(hplot, 'Style', 'text',...
        'Units', 'normalized',...
        'Position',[0.05 0.9 0.2 0.05],...
        'FontSize', 10, ...
        'string', 'Select stamps');

    stmplist = uicontrol(hplot, 'Style', 'listbox',...
        'Units', 'normalized',...
        'Position',[0.05 0.5 0.25 0.4],...
        'FontSize', 10, ...
        'max', N,...
        'string',glist);
    
    % trace list
    uicontrol(hplot, 'Style', 'text',...
        'Units', 'normalized',...
        'Position',[0.35 0.9 0.2 0.05],...
        'FontSize', 10, ...
        'string', 'Select traces');

    neulist = uitable(hplot,'Data',ttlabel,...
        'Units', 'normalized',...
        'Position',[0.35 0.5 0.6 0.4],...
        'ColumnName', handles.datafilename,...
        'RowName', [], ...
        'CellSelection',@getidx);

    % select fitting function
    uicontrol(hplot, 'Style', 'text',...
        'Units', 'normalized',...
        'Position',[0.1 0.4 0.4 0.05],...
        'FontSize', 10, ...
        'string', 'Select a fitting function');
    funclist = {'None', 'Gaussian1', 'Gaussian2', ...
        'Linear without intercept', 'Linear with intercept',...
        'Quadratic', 'Sigmoidal', 'Custom function'};
    fpopup = uicontrol(hplot, 'Style', 'popupmenu',...
        'Units', 'normalized',...
        'Position',[0.1 0.35 0.4 0.05],...
        'FontSize', 10, ...
        'string', funclist, ...
        'Callback', @fpopup_sel);  
    
    ifcircular_sel = uicontrol(hplot,'Style','radiobutton',...
        'Units', 'normalized',...
        'String','If do circular Gaussian fitting', ...
        'Position',[0.55 0.35 0.4 0.05],...
        'FontSize', 10);
    
    h_textbox = uicontrol(hplot, 'Style','edit',...
            'Units', 'normalized',...
            'FontSize', 10, ...
            'Position',[0.1 0.22 0.75 0.12],...
            'String', 'No function selected');
        
    % saving data
    scheck = uicontrol(hplot, 'Style','checkbox',...
            'Units', 'normalized',...
            'FontSize', 10, ...
            'Position',[0.3 0.1 0.3 0.05], ...
            'String', 'Save Data', ...
            'Value', 0);
        
    % pushbutton
    p = uicontrol(hplot,'style','pushbutton',...
        'Units', 'normalized',...
        'String', 'Go',...
        'position', [0.6 0.1 0.2 0.05],...
        'FontSize', 11, ...
        'Callback', @Gopress); 
    
    uiwait(hplot)
    stampsel = get(stmplist,'value');
    funcsel = get(fpopup, 'value');
    
    %[fmodel, startpoint] = modelclass(funcsel);
    dosave = get(scheck, 'value');
    close(hplot)

    function getidx(hObject, eventdata)
        neusel = eventdata.Indices;
        assignin('base', 'neusel', neusel)
    end
    
    function fpopup_sel(hObject, eventdata)
        funcsel = get(hObject, 'value');
        [funcsel, fmodel,fmodel_Independent,fmodel_Coefficients,fmodel_startpoint] ...
            = modelclass(funcsel);
        set(h_textbox, 'String', fmodel)
    end

    function Gopress(hObject, eventdata)
        if get(hObject, 'Value') == 1
            stampsel = get(stmplist,'value');
            dosave = get(scheck, 'value');
            ifcircular = get(ifcircular_sel, 'value');
            uiresume;
            return
        end
    end

    function [funcsel, fmodel,fmodel_Independent,fmodel_Coefficients,fmodel_startpoint]...
            = modelclass(funcsel)
        fmodel_startpoint = [];
        fmodel = '';
        fmodel_Independent = '';
        fmodel_Coefficients  = '';
        switch funcsel
            case 1 % none               
                fmodel = 'none';
            case 2 % 1peak Gaussian fitting
                fmodel = 'f(x) = a1*exp(-((x-b1)/c1)^2)';                
            case 3 % 2peak Gaussian fitting
                fmodel = 'f(x) = a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-(b1+pi))/c2)^2)'; 
            case 4 % Linear without intercept
                fmodel = 'f(x) = p1*x';
            case 5 % Linear with intercept
                fmodel = 'f(x) = p1*x + p2';
            case 6 % poly2
                fmodel = 'f(x) = p1*x^2 + p2*x + p3';   
            case 7 % Sigmoidal
                fmodel = 'f(x) = 1./(1+exp((x-a)./b))+c';                
            case 8 % custom function
                userinput = custommodel;
                if ~isempty(userinput{1}) && ~isempty(userinput{2}) && ~isempty(userinput{3})
                    fmodel = userinput{1};
                    fmodel_Independent = split(userinput{2}, ',');
                    fmodel_startpoint = str2num(userinput{3});
                    ff = fittype(fmodel, 'independent', fmodel_Independent);
                    fmodel_Coefficients = coeffnames(ff);                    
                    if length(fmodel_startpoint) ~= length(fmodel_Coefficients)
                       f = 'Start points should match the number of coefficients';
                       warndlg(sprintf(...
                       '%s,\n %d coefficients and %d start points identified',...
                       f, length(fmodel_Coefficients), length(fmodel_startpoint)));
                       funcsel = 1;
                       fmodel = 'none';
                    end
                end
        end
    end
    function userfun = custommodel
        prompt = {'Enter a function (eg. 1./(1+exp((x-a)./b))+c)', 'Independent (eg. x)',...
            'Start points (eg. [0.5,1,0])'};
        dlgtitle = 'CustomFunction'; 
        userfun = inputdlg(prompt, dlgtitle); 
    end
end