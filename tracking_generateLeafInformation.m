function  [EP, LP, TP, Area] = tracking_generateLeafInformation(testIm, TempInfo, leafID, newS)
                                          
nLeaf = numel(leafID);
LP = zeros(nLeaf, 8);
EP = cell(nLeaf, 1);
TP = zeros(nLeaf, 4);
Area = zeros(nLeaf, 1);

[distanceMap, edgePixelPositionMap] = bwdist(testIm);
edgePixelPositionMap = double(edgePixelPositionMap);
[m, n] = size(testIm);

threshold = 0.1; % distance of tips are 10% larger than the leaf length
for i = 1 : nLeaf
    if leafID(i)~=0
        temp = TempInfo.Template{i};
        tempTip = TempInfo.TemplateTip(i, :);
        theta = newS(i, 1);
        r = newS(i, 2);
        tx = newS(i, 3);
        ty = newS(i, 4);
        x0 = temp(:,1) - mean(temp(:,1));
        y0 = temp(:,2) - mean(temp(:,2));

        newTemp = [cos(theta), -sin(theta); sin(theta), cos(theta)]*[x0';y0']*r + repmat([tx+mean(temp(:,1));ty+mean(temp(:,2))], 1, numel(x0));
        x1 = round(newTemp(1, :))';
        y1 = round(newTemp(2, :))';
        index1 = find(x1<1);
        index2 = find(y1<1);
        index3 = find(x1>m);
        index4 = find(y1>n);
        index = unique([index1(:); index2(:); index3(:); index4(:)]);
        x1(index) = [];
        y1(index) = [];
        EP{i} = [x1, y1];
        
        mask = TempInfo.AllMasks{i};
        Area(i) = sum(mask(:));
        
        [xx1, yy1] = ind2sub(size(testIm), edgePixelPositionMap(sub2ind(size(testIm), x1, y1)));
        start_x = min(xx1);
        start_y = min(yy1);
        height = max(xx1) - min(xx1);
        width = max(yy1) - min(yy1);
        score = sum(sum(distanceMap(sub2ind(size(testIm), x1, y1))))/numel(x1);
        LP(i, 4:8) = [start_x, start_y, height, width, score]; 

        newTempTip = [cos(theta), -sin(theta); sin(theta), cos(theta)]*[tempTip(1:2:end)- mean(temp(:,1)); tempTip(2:2:end)- mean(temp(:,2))]*r + repmat([tx + mean(temp(:,1));ty + mean(temp(:,2))], 1, 2);
        tip = round(newTempTip);
        [tip_x, tip_y] = data_adjustWithinImage(testIm, tip(1,:), tip(2,:));
        [tip_x, tip_y] = ind2sub(size(testIm), edgePixelPositionMap(sub2ind(size(testIm), tip_x, tip_y)));
        tip1 = [tip_x; tip_y];
        TP(i, :) = tip1(:)';

        leafLength = sqrt((TP(i,1)-TP(i,3)).^2 + (TP(i,2)-TP(i,4)).^2);
        if distanceMap(TP(i,3), TP(i,4)) > threshold*leafLength
            TP(i, 3:4) = [tip(1,2), tip(2,2)];
        end 
    end
end


