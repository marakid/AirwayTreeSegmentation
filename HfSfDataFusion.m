function [fusion] = HfSfDataFusion(img)
    minV = -1000;
    maxV = 100;

    img = 255*(img-minV)/(maxV-minV);
    [d1, d2, d3] = size(img);

    % % Hard filter: sharpening
    sharp = zeros(size(img));
    for k = 1 : d3
        sharp(:, :, k) = imsharpen(img(:, :, k), 'Radius',2,'Amount',1);
    end

    % % Soft filter: Gauss
    soft = zeros(size(img));
    for n = 1 : d3
        soft(:, :, n) = imgaussfilt(img(:, :, n));
    end

    fusion = zeros(size(img));

    for i = 1:d1
        for j = 1:d2
            for z = 1:d3
                if abs(sharp(i, j, z)) >= abs(soft(i, j, z))
                    fusion(i, j, z) = sharp(i, j, z);
                else
                    fusion(i, j, z) = soft(i, j, z);
                end
            end
        end
    end
    
    niftiwrite(int8(fusion), 'HfSfFilteredCT.nii');
end