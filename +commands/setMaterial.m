function setMaterial(v,varargin)
%function setMaterial(v,varargin)
% --- set surface appearance (shiny, matte, etc)
% inputs: ambient(0..1), diffuse(0..1), specular(0..1), specularExponent(0..inf), backFaceLighting (0 or 1)
%MRIcroS('setMaterial', 0.5, 0.5, 0.7, 100, 1);
%if not specified, will use current value

if (length(varargin) < 1), return; end;

inputResults = parseInputParamsSub(v.vprefs.materialKaKdKsn, v.vprefs.backFaceLighting, varargin);

v.vprefs.materialKaKdKsn(1) = inputResults.ambient;
v.vprefs.materialKaKdKsn(2) = inputResults.diffuse;
v.vprefs.materialKaKdKsn(3) = inputResults.specular;
v.vprefs.materialKaKdKsn(4) = inputResults.specularExponent;
v.vprefs.backFaceLighting = inputResults.backFaceLighting;

guidata(v.hMainFigure,v);%store settings
drawing.redrawSurface(v);
%end setMaterial()


function inputParams = parseInputParamsSub(materialKaKdKsn, backFaceLighting, args)

d.ambient = materialKaKdKsn(1);
d.diffuse = materialKaKdKsn(2);
d.specular = materialKaKdKsn(3);
d.specularExponent = materialKaKdKsn(4);
d.backFaceLighting = backFaceLighting;

p = inputParser;
p.addOptional('ambient',d.ambient, @(x) validateattributes(x, {'numeric'}, {'>=', 0, '<=' 1}));
p.addOptional('diffuse',d.diffuse, @(x) validateattributes(x, {'numeric'}, {'>=', 0, '<=', 1}));
p.addOptional('specular',d.specular, @(x) validateattributes(x, {'numeric'}, {'>=', 0, '<=', 1}));
p.addOptional('specularExponent', d.specularExponent, @(x) validateattributes(x, {'numeric'}, {'nonnegative'}));
p.addOptional('backFaceLighting', d.backFaceLighting, @(x) validateattributes(x, {'numeric'}, {'binary'}));

p = utils.stringSafeParse(p, args, fieldnames(d), d.ambient, d.diffuse, d.specular, d.specularExponent, d.backFaceLighting);

inputParams = p.Results;