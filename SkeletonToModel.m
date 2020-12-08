function[finalResult] = SkeletonToModel(skeleton, originalImg)
    finalResult = zeros(size(originalImg));
    skLinearIdx = find(skeleton);
    imgLinearIdx = find(originalImg);
    [x1, y1, z1] = ind2sub(size(skeleton), skLinearIdx);
    [x2, y2, z2] = ind2sub(size(originalImg), imgLinearIdx);
    skIdx = [x1 y1 z1];
    imgIdx = [x2 y2 z2];
    
    for i = 1: size(imgIdx, 1)
        dist = sqrt(sum(bsxfun(@minus, imgIdx(i, :), skIdx).^2, 2));
        minDist = min(dist);
        minSkIdx = skIdx(find(dist == minDist, 1),:);
        minImgIdx = imgIdx(i, :);
        finalResult(minImgIdx(1), minImgIdx(2), minImgIdx(3)) = ...
            skeleton(minSkIdx(1), minSkIdx(2), minSkIdx(3));
    end
end