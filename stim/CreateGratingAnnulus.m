function gratingAnn = CreateGratingAnnulus(eccentricity, spatialFrequency, gratPhase, ...
    gratContrast, meanLuminance, orientation, gratType, backGroundLum, colour, gauss_sigma)
%
% gratingAnn = CreateGratingAnnulus(eccentricity, spatialFrequency, gratPhase, gratContrast, meanLuminance, orientation, gratType, colour)
%
% Creates an annulus of wave grating grating
% gratType can be 'square', 'sin', 'cos'

if ~exist('gratType', 'var'), gratType = 'square'; end

if ~exist('colour', 'var'), colour = []; end

gratSize = max(eccentricity);

[xx, yy] = meshgrid(-gratSize:gratSize, -gratSize:gratSize);
[~, rr] = cart2pol(xx, yy);

 switch(gratType)
    case 'square'
        gratingAnn = backGroundLum + ...
        (meanLuminance*gratContrast)*square(2*pi*spatialFrequency*(xx*cos(orientation) + yy*sin(orientation))...
        - gratPhase);
    case 'sin'
        gratingAnn = backGroundLum + ...
        (meanLuminance*gratContrast)*sin(2*pi*spatialFrequency*(xx*cos(orientation) + yy*sin(orientation))...
        - gratPhase);
    case 'cos'
        gratingAnn = backGroundLum + ...
        (meanLuminance*gratContrast)*cos(2*pi*spatialFrequency*(xx*cos(orientation) + yy*sin(orientation))...
        - gratPhase);
end

if  ~isempty(gauss_sigma)
    gauss_mask = exp(-(rr.^2)./(2*gauss_sigma.^2));
    gratingAnn = gratingAnn .* gauss_mask;
end

if ~isempty(colour)
    cm = repmat(colour', [1 size(gratingAnn)]); % Colour matrix
    cm = permute(cm, [2, 3, 1]);
    gratingAnn = repmat(gratingAnn, [1, 1, 3]) .* cm;
    rr = repmat(rr, [1, 1, 3]);
end

% Cut off the inner and outer portions of the annulus
% gratingAnn(rr<eccentricity(1) | rr>eccentricity(2)) = backGroundLum;
gratingAnn(rr<eccentricity(1)) = 0;

 
end