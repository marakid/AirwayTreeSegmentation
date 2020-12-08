function[img] = MorphologicalReconstruction(orig_img)
    [d1, d2, d3] = size(orig_img);
    B4 = strel('disk', 1);
    img = orig_img;
    
    img = permute(img, [1 3 2]);
    orig_img = permute(orig_img, [1 3 2]);
    for i = 1:d2
        szelet = orig_img(:, :, i);
        szelet = double(szelet);
        figure(1);
        imshow(uint8(szelet));
        osszes = zeros(size(szelet));
        for k = 2:8
            D = strel('square', k);
            Xn = imclose(szelet, D);
            h1 = Xn;
            vege = false;
            while ~vege
                h2 = max(imerode(h1, B4), szelet);
                if h2 == h1
                    vege = true;
                else
                    h1 = h2;
                end
            end
            Irec = h2;
            Idiff = Irec - szelet;
            TH = 0.2 * (max(Idiff, [], 'all') - min(Idiff, [], 'all')) + min(Idiff, [], 'all');
            TH_img = Idiff > TH;
            osszes = osszes + TH_img;
        end
        img(:, :, i) = osszes;
        figure(2);
        imshow(logical(img(:, :, i)));

    end

    img = permute(img, [1 3 2]);
    img = permute(img, [2 3 1]); 
    orig_img = permute(orig_img, [1 3 2]);
    orig_img = permute(orig_img, [2 3 1]);

    for i = 1:d1
        imslice = orig_img(:,:,i);
        imslice = double(imslice);
        osszes = zeros(size(imslice));
        figure(1);
        imshow(uint8(imslice));
        for k = 2:8
            D = strel('square', k);
            X1n_1 = imclose(imslice, D);
            h1 = X1n_1;
            vege = false;
            while ~vege
                h2 = max(imerode(h1, B4), imslice);
                if h2 == h1
                    vege = true;
                else
                    h1 = h2;
                end
            end
            X_reconst_1 = h2;
            diff_img_1 = X_reconst_1 - imslice;
            th1_1 = 0.3 * (max(diff_img_1, [], 'all') - min(diff_img_1, [], 'all')) + min(diff_img_1, [], 'all');
            th_img_1 = diff_img_1 > th1_1;
            osszes = osszes + th_img_1;
        end
        img(:, :, i) = osszes;
        figure(2);
        imshow(logical(img(:, :, i)));
    end

    img = permute(img, [3 1 2]); 
    orig_img = permute(orig_img, [3 1 2]);

    for i = 1:d3
        imslice = orig_img(:,:,i);
        imslice = double(imslice);
        figure(1);
        imshow(uint8(imslice));
        osszes = zeros(size(imslice));
        for k = 2:10
            D = strel('square', k);
            X1n_1 = imclose(imslice, D);
            h1 = X1n_1;
            vege = false;
            while ~vege
                h2 = max(imerode(h1, B4), imslice);
                if h2 == h1
                    vege = true;
                else
                    h1 = h2;
                end
            end
            X_reconst_1 = h2;
            diff_img_1 = X_reconst_1 - imslice;
            th1_1 = 0.2 * (max(diff_img_1, [], 'all') - min(diff_img_1, [], 'all')) + min(diff_img_1, [], 'all');
            th_img_1 = diff_img_1 > th1_1;
            osszes = osszes + th_img_1;
        end
        img(:, :, i) = osszes;
        figure(2);
        imshow(logical(img(:, :, i)));
    end
    
    niftiwrite(img, 'BinaryMask.nii');
end