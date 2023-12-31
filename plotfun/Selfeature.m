function [varsel] = Selfeature(handles, ttlabel, mainfig_pos)
    varsel = [];
    scrsz = handles.scrsz;
    pos = mainfig_pos;
    pos(1) = pos(1)+100;
    pos(3) = pos(3)-300;

    hplot = figure(25); clf('reset')
    set(hplot, 'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...        
        'Name', 'Set up fitting', 'Position', pos);

    % feature list
    uicontrol(hplot, 'Style', 'text',...
        'Units', 'normalized',...
        'Position',[0.1 0.9 0.2 0.05],...
        'FontSize', 10, ...
        'string', 'Select traces');

    neulist = uitable(hplot,'Data',ttlabel',...
        'Units', 'normalized',...
        'Position',[0.1 0.5 0.6 0.4],...
        'ColumnName', handles.datafilename,...
        'RowName', [], ...
        'CellSelection',@getidx);
        
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