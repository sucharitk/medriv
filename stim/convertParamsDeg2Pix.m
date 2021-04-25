function ds = convertParamsDeg2Pix(sp, ds)
%
% function ds = convertParamsDeg2Pix(sp);
%
% Convert the parameters that are specified in degrees of visual angle to
% pixels
%
% Katyal, 10/13: Wrote it
%

ppd = ds.PIXPERDEG;

ds.eccentricity = sp.eccentricity * ppd;

ds.fixationLength = sp.fixationLength * ppd;
ds.fixationLineWidth = sp.fixationLineWidth *ppd;

ds.frameLength = sp.frameLength * ppd;
ds.frameLineWidth = sp.frameLineWidth * ppd;

ds.fixDotSize = sp.fixDotSize * ppd;
ds.adjustFixation = sp.adjustFixation * ppd;

ds.gauss_sigma = sp.gauss_sigma * ppd;

end