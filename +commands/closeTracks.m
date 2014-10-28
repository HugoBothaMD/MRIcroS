function closeTracks(v)
%MRIcroS('closeTracks');
v = guidata(v.hMainFigure);
if isfield(v, 'tracks')
	drawing.trk.dePlotTracks(v);
    v = rmfield(v, 'tracks');
	guidata(v.hMainFigure, v);%store changes
end
drawing.createDemoObjects(v, true);
%end closeNodes()

