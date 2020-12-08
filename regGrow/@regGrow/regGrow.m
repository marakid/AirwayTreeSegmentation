classdef regGrow < handle
% class regGrow 
%
%   Basic implementation of region growing segmentation for 2D images or 3D
%   volumes in C. One need to compile the c files first!
%
% Input:
%
%   I             <-  2D image or 3D volume (double in range [0 1] preferred)
%   initPosition  <-  coordinates to the seed point (1x2 or 1x3 double) 
%
% Optional input:
%
%   thresholdVal  <-  absolut threshold value for pixels (double)
%   maxDist       <-  maximum euclidean distance to the seed point (double) 
%   fillHoles     <-  closes holes in the segmented image (logical)
%
% Output:
%
%   segmentationResult -> binary mask of the segmented region
%
% Compiling the c files:
%
%   regGrow().compile
%
% Sample call:
%   2D:
%   testImg = imread('cameraman.tif');
%   result = regGrow().segment(testImg,[80 64],0.2,inf,true);
%
%   2D (interactive):
%   testImg = imread('cameraman.tif');
%   result = regGrow().interactive(testImg);
%   
%   3D:
%    load mri
%    testVol = squeeze(D);
%    result = regGrow().segment(testVol,[60 50 10],0.2,inf,true);
%
% Development environment:
% MATLAB Version: 8.5.0.197613 (R2015a)
% MATLAB License Number: 147773
% Operating System: Microsoft Windows 7 Enterprise  Version 6.1 (Build 7601: Service Pack 1)
% Java Version: Java 1.7.0_60-b19 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
%
% Version 2 Adrian Becker 08/02/2017 
    properties (Access = private)
        isCompiled = false;%
        guiData = struct('f',[],'a',[],'i',[]);
        interImage = [];
        interSegRes = [];
    end

    properties 
        initPosition = [];%coordinates to the seed point (1x2 or 1x3 double)
        thresholdVal = [];%absolut threshold value for pixels (double)
        maxDist = [];%maximum euclidean distance to the seed point (double)
        fillHoles = [];%closes holes in the segmented image (logical)
    end
    
    methods
        function this = regGrow
            % Loads some default properties and checks the mex files
            narginchk(0,0);
            this.thresholdVal = 0.2;
            this.maxDist = inf;
            this.fillHoles = true;
            this.findMexFiles();
        end
        
        function segmentationResult = segment(this,I, varargin)
            % Returns the segmented mask of an input image
            % segmentationResult = regGrow().segment(I,varargin)
            narginchk(2,6);
            this.parseInputs(I,varargin{:});%Parse the input parameters
            I = im2double(I);%Convert to [0...1] double
            if this.isCompiled %If the mex files are available use them
                if size(I,3) > 1
                    segmentationResult = regGrow3D(I,this.initPosition,this.thresholdVal,this.maxDist);
                else
                    segmentationResult = regGrow2D(I,this.initPosition,this.thresholdVal,this.maxDist);
                end
            else% if not use the matlab method
                warning('regGrow:segment:notRecommended',strcat('Using the matlab version of regGrow is rather slow.',10,'Please compile the c-files first!',10,'You can use the compile() method of regGrow.'));
                segmentationResult = this.regGrowMat(I);
            end
            segmentationResult = logical(segmentationResult);%Make sure its logical
            if this.fillHoles %Fill the holes 
                for k=1:size(segmentationResult,3)%In 3D case the for loop leads to better results then imfill with 3D input
                    segmentationResult(:,:,k) = imfill(segmentationResult(:,:,k),'holes');
                end
            end
        end
        
        function segmentationResult = interactive(this,I)
            % Starts and interactive GUI for segmenting images only
            % segmentationResult = regGrow().interactive(I)
            narginchk(2,2);
            assert(ismatrix(I),'Input must be a 2D image');%Make sure I is 2D
            this.interImage = I;
            segmentationResult = this.startInteractiveSegmentation;%Start GUI helper
        end
    
        function compile(this)
            % Helper to compile the mex files
            % This method assumes the files to be in the right directory
            % structure. One can compile them manually but this class will 
            % look for the mex files in its private folder
            this.compileMexFiles();
        end
    end
    
    methods (Access = private)
        function segRes = startInteractiveSegmentation(this)
            this.guiData.f = figure;%Create figure and set some properties
            set(this.guiData.f,'name','Interactive segmentation','numbertitle','off','Units', 'normalized', 'Position', [0.25 0.25 0.5 0.5],'closerequestfcn',@this.cbClose);%Set custom Window name
            set(this.guiData.f,'MenuBar','none');%Comment out if bothering
            this.guiData.a(1) = subplot(1,2,1);%Create axes for the original image
            this.guiData.i(1) = imshow(this.interImage,[]);%Display
            this.guiData.a(2) = subplot(1,2,2);%Create axes for the segmentation result
            this.guiData.i(2) = imshow(false(size(this.interImage)));%Display a black image
            this.resetUIcomponents();%Initialize ui buttons and slider
            waitfor(this.guiData.f);%wait until the gui terminates
            segRes = this.interSegRes;%Return the last result to user
        end
        
        function resetUIcomponents(this)
            %For information about the ui controls read matlab
            %documentation -> uicontrol properties
            this.guiData.pbSelectPoint = uicontrol(this.guiData.f,'Style', 'pushbutton',...
                              'String', 'Select Point',...
                              'Enable','on',...
                              'Units','normalized',...
                              'Position', [0.13 0.05 0.15 0.05],...
                              'Callback', @this.cbSelectPoint);

            this.guiData.slThreshold = uicontrol(this.guiData.f,'Style', 'slider',...
                      'Enable','off',...
                      'Units','normalized',...
                      'Min',0,'Max',1,'Value',0.2,...
                      'SliderStep',[0.01 0.1],...
                      'Position', [0.34 0.05 0.35 0.05],...
                      'Callback', @this.cbThreshold);

            this.guiData.pbPref = uicontrol(this.guiData.f,'Style', 'pushbutton',...
                      'String', 'Preferences',...
                      'Enable','on',...
                      'Units','normalized',...
                      'Position', [0.75 0.05 0.15 0.05],...
                      'Callback', @this.cbPref);
        end
        
        function cbSelectPoint(this,src,event)
            %Call back for the select point button
            set(this.guiData.slThreshold,'Enable','off');
            set(this.guiData.pbPref,'Enable','off');
            hold(this.guiData.a(1),'on');%Make sure that the selection will be done in the original image
            this.initPosition = fliplr(round(ginput(1)));%flip results to matlab style
            hold(this.guiData.a(1),'off');
            set(this.guiData.pbPref,'Enable','on');
            %Check if the selected point is in image range
            if all(size(this.interImage) >= this.initPosition) && all([1 1] <= this.initPosition)
                set(this.guiData.slThreshold,'Enable','on');
                this.updateResult;%Update the segmentation results
            else
                %If its not in range, discard settings
                this.initPosition = [];
                this.interSegRes = false(size(this.interImage));
                %display a black image
                set(this.guiData.i(2),'CData',this.interSegRes);
            end
        end
        
        function cbThreshold(this,src,event)
            this.thresholdVal = round(src.Value,2);% Set the slider value as current threshold
            if ~isempty(this.initPosition)% If there is a seed
                this.updateResult;%update results
            end
        end
        
        function cbPref(this,src,event)
            %Preferences dialog
            set(this.guiData.pbSelectPoint,'Enable','off');
            set(this.guiData.slThreshold,'Enable','off');
            set(this.guiData.pbPref,'Enable','off');
            %Matlab dialog
            answer = inputdlg({'Maximum distance from seed point:','Fill holes in mask:'},'Preferences',1,{'inf','1'});
            if ~isempty(answer)
                if ~isempty(answer{1})
                    %Check if the answer is valid 
                    tempDist = str2double(answer{1});
                    if isfinite(tempDist)
                        this.maxDist = abs(tempDist);%and set the new max distance
                    end
                end
                if ~isempty(answer{2})%Check if the answer is false or zero
                    if ismember(answer{2},{'0' 'false'})
                        this.fillHoles = false;%and set fill holes accordingly
                    else
                        % Othewise set fill holes to true
                        this.fillHoles = true;
                    end                    
                end
            end
            if ~isempty(this.initPosition)% If there is a seed
                this.updateResult;%Update results
                set(this.guiData.slThreshold,'Enable','on');
            end
            set(this.guiData.pbSelectPoint,'Enable','on');
            set(this.guiData.pbPref,'Enable','on');
        end
        
        function cbClose(this,src,event)
            if ishandle(this.guiData.f)
                set(this.guiData.f,'closerequestfcn','');%Reset the closerequestfcn otherwise the destructor of figure class will cause an endless loop
                delete(this.guiData.f);%destroy figure object
                this.guiData = [];%release gui data struct
            end
        end
        
        function updateResult(this)
            tempSegRes = this.segment(this.interImage);%segment image
            set(this.guiData.i(2),'CData',tempSegRes);%display results
            this.interSegRes = tempSegRes;%save results 
        end
        
        function parseInputs(this,I,varargin)
            %Input assertion the error message will explain the condition
            if ~ismember(ndims(I),[2 3]) || isempty(I) 
                error('MATLAB:regGrow:segment','Input must be a 2D or 3D array');
            end
            if isempty(varargin)
                assert(~isempty(this.initPosition),'You must set at least the initPosition property when you call segment() with this argumentlist');
            else
                if numel(varargin) >= 1
                    tempPos = varargin{1};
                    tempPos = tempPos(:)';
                    assert(~isempty(tempPos) && all(isfinite(tempPos)),'Unspecified or invalid initial position');
                    assert(isequal(size(tempPos),[1 ndims(I)]),'Initial position must be a row vector with N-columns for ND images');
                    assert(all(size(I) >= tempPos) && all(ones(1,ndims(I)) <= tempPos),'Initial position out of range');
                    this.initPosition = tempPos;
                end
                if numel(varargin) >= 2
                    assert(~isempty(varargin{2}) && isscalar(varargin{2}) && isfinite(varargin{2}),'Unspecified or invalid threshold');
                    this.thresholdVal = varargin{2};
                end
                if numel(varargin) >= 3
                    assert(~isempty(varargin{3}) && isscalar(varargin{3}),'Maximum distance is a scalar');
                    this.maxDist = varargin{3};
                end
                if numel(varargin) == 4
                    assert(islogical(varargin{4}),'Fill holes is a logical value');
                    this.fillHoles = varargin{4};
                end
            end
        end
   
        function findMexFiles(this)
            %Search for the mex files in classdirs private subdir
            classDir = fileparts(mfilename('fullpath'));
            privDir = fullfile(classDir,'private');
            if ~exist(privDir,'dir')%if the subdir doesnt exist there cant be any file
                mkdir(privDir);
                this.isCompiled = false;
            else
                contStruct = dir(privDir);%get subdir content
                if ispc
                    mexLibId = 'w';%Mex files in windows have mexw32 or mexw64 extension
                else
                    mexLibId = 'a';%in unix systems its mexa32 or mexa64
                end
                is2D = any(~cellfun(@isempty,regexp({contStruct.name},strcat('regGrow2D.mex',mexLibId','(32|64)'))));
                is3D = any(~cellfun(@isempty,regexp({contStruct.name},strcat('regGrow3D.mex',mexLibId','(32|64)'))));
                this.isCompiled = is2D & is3D;%if both exist the files are compiled
            end
        end
        
        function compileMexFiles(this)
            currDir = pwd;%Save the current dir
            classDir = fileparts(mfilename('fullpath'));
            privDir = fullfile(classDir,'private');
            if ~exist(privDir,'dir')
                mkdir(privDir);
            end
            %Search for the original c files
            if exist(fullfile(classDir,'regGrow2D.c'),'file') && exist(fullfile(classDir,'regGrow2D.c'),'file')
                cd(privDir);%Change the working directory to the private subdir
                try
                    mex('../regGrow2D.c');%Try to compile the 2d version
                    mex('../regGrow3D.c');%Try to compile the 3d version
                    this.isCompiled = true;%Mex files are ready
                catch ME%Catch errors
                    disp('Something went wrong while compiling the c-files');
                    disp('Make sure you have write permissions and a suitable c-compiler');
                end
            else%there are no files in the class dir
                disp('regGrow can not find the necessary c-files in the class directory');
            end
            cd(currDir);%Go back to the origin
        end
        
        function segRes = regGrowMat(this,I)
            segRes = false(size(I));%Preallocation of the result
            queue = this.initPosition;%Add the first point
            if size(queue,2) == 2
                queue = [queue 1];%This is neccessary so the method can handle both images and volumes
            end
            seedPoint = queue;
            seedVal = I(queue(1),queue(2),queue(3));
            while size(queue,1)
                %Select a point
                row = queue(1,1);
                col = queue(1,2);
                pag = queue(1,3);
                %Remove this point from queue
                queue(1,:) = [];
                for x = -1:1
                    for y = -1:1
                        for z = -1:1
                            if all([(row + y) (col + x) (pag + z)] > [0 0 0]) &&...%Check lower bound
                               all([(row + y) (col + x) (pag + z)] <= [size(I,1) size(I,2) size(I,3)]) &&...%Check upper bound
                               any([x y z]) && ~segRes(row + y,col + x,pag + z) &&...%Check if its the point itselfs or a visited point
                               all(sqrt(([(row + y) (col + x) (pag + z)] - seedPoint).^2) < this.maxDist) &&...%Check dist
                               I(row + y,col + x,pag + z) <= seedVal + this.thresholdVal &&...%Check upper threshold
                               I(row + y,col + x,pag + z) >= seedVal - this.thresholdVal%Check lower threshold
                                segRes(row + y,col + x,pag + z) = true;%Set position
                                queue(end+1,:) = [row + y,col + x,pag + z];%Add position to queue
                            end
                        end
                    end
                end
                
            end
        end
    end
end