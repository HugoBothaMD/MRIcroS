function AddLayer_Callback(promptForValues, obj, ~)
% --- add a new voxel image or mesh as a layer with default options
v=guidata(obj);

supportedFileExts = '*.nii;*.hdr;*.nii.gz;*.vtk;*.nv;*.pial;*.ply;*.trib;*.trk';
supportedFileDescs = 'NIfTI/VTK/NV/Pial/PLY/trib/trk';

if utils.isGiftiInstalled()
    supportedFileExts = [supportedFileExts ';*.gii'];
    supportedFileDescs = [supportedFileDescs '/GIfTI'];
end

[brain_filename, brain_pathname] = uigetfile( ...
            {supportedFileExts, supportedFileDescs; ...
            '*.*', 'All Files (*.*)'}, ...
            sprintf('Select a %s image', supportedFileDescs));

if isequal(brain_filename,0), return; end;
filename=[brain_pathname brain_filename];
if fileUtils.isTrk(filename)
    if ~promptForValues
        commands.addTrack(v,filename);
    else
        %from AddTracks_Callback
        prompt = {'Track Sampling (1/ts tracks will be loaded, large values increase speed but decreases information):','Minimum fiber length (only sampled tracks with this minimum fiber length will be rendered, increases speed but decreases information):'};
        opts = inputdlg(prompt, 'Track Options', 1, {num2str(100), num2str(5)});
        if isempty(opts), disp('load cancelled'); return; end;
        trackSpacing = str2double(opts(1));
        fiberLen = str2double(opts(2));
        commands.addTrack(v, filename, trackSpacing, fiberLen); 
    end
    return;
end
reduce = '';
thresh = '';
smooth = '';
vertexColor = '';%CRX
if(promptForValues)  
    if fileUtils.isVtk(filename) || fileUtils.isGifti(filename) || fileUtils.isTrib(filename)
        disp('no options for vtk, gifti, or trib');
	elseif fileUtils.isNv(filename) || fileUtils.isPial(filename)
        [reduce, cancelled] = promptNvPialDialogSub(reduce);
        if(cancelled)
            disp('load cancelled'); 
            return; 
        end;
    else
        reduce = '0.05'; %CRX -> we need to supply reasonable default values
        thresh = 'Inf';
        smooth = '0';
        vertexColor = '0';
        [thresh, reduce, smooth, vertexColor, cancelled] = promptOptionsDialogSub(num2str(thresh),num2str(reduce),num2str(smooth),num2str(vertexColor));
        if(cancelled), disp('load cancelled'); return; end;
		
    end
end
commands.addLayer(v,filename, reduce, smooth, thresh, vertexColor);
end

function [thresh, reduce, smooth, vertexColor, cancelled] = promptOptionsDialogSub(defThresh, defReduce, defSmooth, defVertexColor)
    prompt = {'Surface intensity threshold (Inf=midrange, -Inf=Otsu):','Reduce Path, e.g. 0.5 means half resolution (0..1):','Smoothing radius in voxels (0=none):',...
        'Vertex color (0=no,1=gray,2=autumn,3=bone,4=cool,5=copper,6=hot,7=hsv,8=jet,9=pink,10=winter):'};
    dlg_title = 'Select options for loading image';
    def = {num2str(defThresh),num2str(defReduce),num2str(defSmooth),num2str(defVertexColor)};
    answer = inputdlg(prompt,dlg_title,1,def);
    cancelled = isempty(answer);
    if cancelled
        thresh = NaN; reduce = NaN; smooth = NaN; vertexColor = NaN;
        return; 
    end;
    thresh = str2double(answer(1));
    reduce = str2double(answer(2));
    smooth = round(str2double(answer(3)))*2+1; %e.g. +1 for 3x3x3, +2 for 5x5x5
    vertexColor = str2double(answer(4));
end
    
function [reduce, cancelled] = promptNvPialDialogSub(defReduce)
    prompt = {'Reduce Path, e.g. 0.5 means half resolution (0..1):'};
    dlg_title = 'Select options for loading Nv/Pial';
    def = {num2str(defReduce)};
    answer = inputdlg(prompt,dlg_title,1,def);
    cancelled = isempty(answer);
    if cancelled; return; end;
    reduce = str2double(answer(1));
end