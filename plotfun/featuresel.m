function variablesel = featuresel(variableinfo, handles, disptext)
    mainfig_pos = get(handles.mainfigure, 'Position');
    variablesel = [];
    pos = mainfig_pos;
    pos(1) = pos(1)+100;
    pos(2) = pos(2)+100;
    pos(3) = 300;
    pos(4) = 300;
    hplot = dialog('Position', pos, 'Name', 'Select variable');
    if nargin<3
        disptext = 'Select custom features matrix'; 
    end
    txt = uicontrol('Parent', hplot,...
               'Style','text',...
               'Units', 'normalized',...               
               'Position',[0.1 0.85 0.8 0.1],...
               'FontSize', 10, ...
               'String', disptext);
           
    featurelist = uicontrol(hplot, 'Style', 'listbox',...
        'Units', 'normalized',...
        'Position',[0.1 0.2 0.8 0.6],...
        'FontSize', 10, ...
        'max', length(variableinfo),...
        'string',variableinfo,...
        'Callback', @featurelist_callback);

    btn = uicontrol('Parent', hplot,...
        'Units', 'normalized',...
        'Position',[0.7 0.05 0.2 0.1],...
        'FontSize', 10, ...
        'String','Close',...
        'Callback','delete(gcf)');
    uiwait(hplot)

    function featurelist_callback(featurelist, event)
        variablesel = get(featurelist,'value');
    end
end