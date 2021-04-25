function texture = createTexture(textureParams, ds, eyeInd)
%
% function texture = CreateTexture()
%
% This function returns a texture
%

eyes = {'left', 'right'};
eYe = eyes{eyeInd};
% Eye specific stimulus parameters
textParamsEye = textureParams.(eYe);
backGroundLum = ds.bkg;
switch(textParamsEye.type)
    case 1
        % Create a grating annulus texture with a specified eccentricity
        % range
        spatialFrequencyPix = (textParamsEye.spatialFrequency / ds.PIXPERDEG);
        gratContrast = textParamsEye.contrast;
        meanLuminance = ds.gray;
        orientation = (textParamsEye.orientation)*pi/180;
        if isfield(textParamsEye, 'colour')
            colour = textParamsEye.colour;
        else
            colour = []; % Gray
        end
        gratPhase = 0;
        gratingAnnulus1 = CreateGratingAnnulus(ds.eccentricity, spatialFrequencyPix, ...
            gratPhase, gratContrast, meanLuminance, orientation, 'square', backGroundLum, colour);
        
        gratPhase = pi; % For contrast reversing gratings
        gratingAnnulus2 = CreateGratingAnnulus(ds.eccentricity, spatialFrequencyPix, ...
            gratPhase, gratContrast, meanLuminance, orientation, 'square', backGroundLum, colour);
        
        texture(1) = Screen('MakeTexture', ds.windowPtr, gratingAnnulus1);
        texture(2) = Screen('MakeTexture', ds.windowPtr, gratingAnnulus2);
        
    case 2
        % Create a grating annulus texture smoothed by a Gaussian with a specified eccentricity
        % range
        spatialFrequencyPix = (textParamsEye.spatialFrequency / ds.PIXPERDEG);
        gratContrast = textParamsEye.contrast;
        meanLuminance = ds.gray;
        orientation = (textParamsEye.orientation)*pi/180;
        if isfield(textParamsEye, 'colour')
            colour = textParamsEye.colour;
        else
            colour = []; % Gray
        end
        
        grat_type = textureParams.grat_type;
        
        gratPhase = textureParams.gratPhase(eyeInd);
        gratingAnnulus1 = CreateGratingAnnulus(ds.eccentricity, spatialFrequencyPix, ...
            gratPhase, gratContrast, meanLuminance, orientation, grat_type, backGroundLum, colour, ds.gauss_sigma);
        
        gratPhase = textureParams.gratPhase(eyeInd) + pi; % For contrast reversing gratings
        gratingAnnulus2 = CreateGratingAnnulus(ds.eccentricity, spatialFrequencyPix, ...
            gratPhase, gratContrast, meanLuminance, orientation, grat_type, backGroundLum, ...
            colour, ds.gauss_sigma);
        
        texture(1) = Screen('MakeTexture', ds.windowPtr, gratingAnnulus1);
        texture(2) = Screen('MakeTexture', ds.windowPtr, gratingAnnulus2);
    case 3
        % Create overlaying gratings, with which go from 1+1 in terms of
        % contrast to 1+0
        spatialFrequencyPix = (textParamsEye.spatialFrequency / ds.PIXPERDEG);
        gratContrast = textParamsEye.contrast/2; % For overlaying gratings divide the contrast by 2
        meanLuminance = ds.gray;
        orientation = (textureParams.orientation)*pi/180;
        
        gratPhase = 0;
        gratingAnnulus1 = CreateGratingAnnulus(ds.eccentricity, spatialFrequencyPix, ...
            gratPhase, gratContrast, meanLuminance, orientation(eyeInd), 'square', backGroundLum);
        
        for ii = 1:textureParams.nContrastSteps
            gratingAnnulus2 = CreateGratingAnnulus(ds.eccentricity, spatialFrequencyPix, ...
                gratPhase, gratContrast-textureParams.contrastIncs(ii)/2, meanLuminance, orientation(3-eyeInd), 'square', backGroundLum);
            texture(ii) = Screen('MakeTexture', ds.windowPtr, (gratingAnnulus1+gratingAnnulus2)/2);
        end
end

end