function [varsel] = SelVar(handles, mainfig_pos)

    varsel = [];
    scrsz = handles.scrsz;
    pos = mainfig_pos;
    pos(1) = pos(1)+100;
    pos(3) = pos(3)-300;

    stampinfo = handles.stampinfo{1};
    varNames = stampinfo.Properties.VariableNames;
    hplot = figure(25); clf('reset')
    set(hplot, 'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...        
        'Name', 'Set up fitting', 'Position', pos);

        % trace list
    uicontrol(hplot, 'Style', 'text',...
        'Units', 'normalized',...
        'Position',[0.1 0.85 0.5 0.1],...
        'FontSize', 10, ...
        'string', 'Select the stimulus label for plot');

    varnamelist = uitable(hplot,'Data',varNames',...
        'Units', 'normalized',...
        'Position',[0.1 0.25 0.8 0.6],...
        'ColumnName', 'Stampinfo Variables',...
        'RowName', [], ...
        'CellSelection',@getidx);
        % pushbutton
        
    p = uicontrol(hplot,'style','pushbutton',...
        'Units', 'normalized',...
        'String', 'Go',...
        'position', [0.6 0.1 0.2 0.05],...
        'FontSize', 11, ...
        'Callback', @Gopress); 

    uiwait(hplot)
    close(hplot)

    function Gopress(hObject, eventdata)
        if get(hObject, 'Value') == 1
            uiresume;
            return
        end
    end
    function getidx(hObject, eventdata)
        varsel = eventdata.Indices;
        assignin('base', 'varsel', varsel)
    end
end