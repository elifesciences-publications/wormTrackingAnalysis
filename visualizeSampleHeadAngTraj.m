% script takes saved sample traj data in microns (generated by analyzeHeadTurn.m), and plots/saves figures of worm trajectories

close all
clear

%% set parameters
featureToSample = 'headAngNorm'; %'headAngTotal','headAngNorm', or 'headAngSpeed'
numSampleTraj = 200;
saveResults = false;  %true or false.

dataset = 2; %1 or 2.
marker = 'pharynx'; %'pharynx' or 'bodywall'.
strains = {'npr1'}; % 'N2' or 'npr1'
wormnum = '40';
phase = 'joining'; %'fullMovie','joining', or 'sweeping'.
wormcats = {'leaveCluster','loneWorm'};

%% determine head ranges and sample unit
if strcmp(featureToSample,'headAngTotal') | strcmp(featureToSample,'headAngSpeed')
    headAngRanges = [0, 0.25; pi/2-0.25, pi/2+0.25; pi-0.25, pi+0.25; 3/2*pi-0.25, 3/2*pi+0.25; 2*pi-0.25, 2*pi];
    if strcmp(featureToSample,'headAngTotal')
        sampleTrajUnit = 'radian';
    else
        sampleTrajUnit = 'radian/s';
    end
elseif strcmp(featureToSample,'headAngNorm')
    headAngRanges = [0 0.01; 0.01 0.02; 0.02 0.03; 0.03 0.05; 0.05 1];
    sampleTrajUnit = 'radian/micron';
else
    warning('Wrong feature selected for trajectory visualisation')
end

%% loop through and plot trajectories
for strainCtr = 1:length(strains)
    strain = strains{strainCtr};
    % load file
    load(['figures/turns/results/headAngSampleTraj_' featureToSample '_' strain '_' wormnum '_' phase '_data' num2str(dataset) '_' marker '.mat'])f
    for rangeCtr = 1:size(headAngRanges,1)
        for wormcatCtr = 1:length(wormcats)
            samplePathFig = figure; hold on
            % remove empty cells
            headAngSampleTrajRange = squeeze(headAngSampleTraj.(wormcats{wormcatCtr})(:,:,rangeCtr));
            headAngSampleTrajRange = headAngSampleTrajRange(~cellfun('isempty',headAngSampleTrajRange));
            headAngSampleTrajRange = reshape(headAngSampleTrajRange,[],2);
            % randomly select sample trajectories from the saved ones
            numSavedTraj = size(headAngSampleTrajRange,1);
            if numSampleTraj<=numSavedTraj
                trajSamples = randi(size(headAngSampleTrajRange,1),[numSampleTraj,1]);
            else
                trajSamples = 1:numSavedTraj;
            end
            % loop through each saved trajectory
            for trajCtr = 1:length(trajSamples)
                % get xy coordinates for sample traj
                xcoords = headAngSampleTraj.(wormcats{wormcatCtr}){trajSamples(trajCtr),1,rangeCtr};
                ycoords = headAngSampleTraj.(wormcats{wormcatCtr}){trajSamples(trajCtr),2,rangeCtr};
                % set all trajectories to start at 0,0
                xcoords = xcoords - xcoords(1);
                ycoords = ycoords - ycoords(1);
                % rotate trajectory
                [xcoords, ycoords] = rotateTraj(xcoords, ycoords);
                % plot
                set(0,'CurrentFigure',samplePathFig)
                plot(xcoords,ycoords)
            end
            
            %% format and save plot
            if strcmp(featureToSample,'headAngTotal') | strcmp(featureToSample,'headAngSpeed')
                title([strain '\_' wormcats{wormcatCtr} ', '...
                    sprintf('%0.1f',headAngRanges(rangeCtr,1)) '-' sprintf('%0.1f',headAngRanges(rangeCtr,2)) sampleTrajUnit],'FontWeight','normal')
            else
                title([strain '\_' wormcats{wormcatCtr} ', '...
                    sprintf('%0.2f',headAngRanges(rangeCtr,1)) '-' sprintf('%0.2f',headAngRanges(rangeCtr,2)) sampleTrajUnit],'FontWeight','normal')
            end
            set(samplePathFig,'PaperUnits','centimeters')
            xlim([-1.5e3 1.5e3])
            ylim([-1.5e3 1.5e3])
            xlabel('microns');
            ylabel('microns');
            ax = gca;
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';
            figurename = ['figures/turns/sampleTraj/' featureToSample '_' strain '_' wormnum '_' wormcats{wormcatCtr} '_range' num2str(rangeCtr) '_' phase '_data' num2str(dataset) '_' marker ];
            if saveResults
                load('exportOptions.mat')
                exportfig(samplePathFig,[figurename '.eps'],exportOptions)
%                 system(['epstopdf ' figurename '.eps']);
%                 system(['rm ' figurename '.eps']);
            end
        end
    end
end