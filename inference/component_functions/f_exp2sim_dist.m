function expsim_dists = f_exp2sim_dist(exp_ss_array, sim_ss_array, exp_strain_list)
global num_statistics

% Compute the appropriate distances between each of the
% simulations and the experimental references

% Constuct a n-by-m-by-l+1 matrix for containing the distances between each 
% experiment (n) and each simulation (m) for each of the summary statistics
% computed (l)

numSims = size(sim_ss_array,1);
numStrains = length(exp_strain_list);
expsim_dists = zeros(numStrains,numSims, num_statistics);

for strainCtr = 1:numStrains
    for simCtr = 1:numSims
        
        if strainCtr ==1 && simCtr ==1
            running_dists = zeros(1,size(exp_ss_array,2)-1,numStrains);
        end
        
        exp_data = exp_ss_array(strainCtr,2:end);
        sim_data = sim_ss_array(simCtr,2:end);
        %%% THIS NEEDS TO CHECKED IN DEBUG MODE
        for statCtr = 1:length(sim_data)
            if length(exp_data{statCtr})>1
                exp_data{statCtr} = norm(exp_data{statCtr}-sim_data{statCtr});
                sim_data{statCtr} = 0;
            end
        end
        
        % Compute the distance between this simulation and the reference
        dists = cell2mat(exp_data)-cell2mat(sim_data);
        running_dists(:,:,strainCtr) = running_dists(:,:,strainCtr)+dists;
        expsim_dists(strainCtr,simCtr,:) = horzcat(norm(dists),dists);
        %%%
    end
end

% Normalization: divide the distances from each summary stat by the mean for that
% strain. This ensures that each summary statistic contribution is weighted
% similarly in the distance function. Else, summary statistics at a larger
% scale would dwarf others when the mean euclidean distance is calculated.

for strainCtr = 1:numStrains
    for statCtr = 2:num_statistics
        expsim_dists(strainCtr,:,statCtr) = expsim_dists(strainCtr,:,statCtr)...
            ./mean(expsim_dists(strainCtr,:,statCtr));  
    end
    
    for simCtr = 1:numSims
        expsim_dists(strainCtr,simCtr,1) = sum(expsim_dists(strainCtr,simCtr,2:num_statistics));
    end
end

        %%% THIS NEEDS TO CHECKED IN DEBUG MODE

% Consider the distance composition to check whether this normalization of
% the summary statistic weights has been successful.
sim_strain_vars = zeros(numStrains,num_statistics-1);

for strainCtr = 1:numStrains
    for statCtr = 2:num_statistics
        sim_strain_vars(strainCtr, statCtr-1) = var(expsim_dists(strainCtr,:,statCtr));
    end
end

% To ensure pie is full
if sum(sim_strain_vars)<=1
    sim_strain_vars(:) = sim_strain_vars(:).*(1/sum(sim_strain_vars));
end

pie_data = zeros(strainCtr,num_statistics-1);
figure;
for strainCtr = 1:numStrains
    for statCtr = 1:num_statistics-1
        pie_data(strainCtr,statCtr) = sum(expsim_dists(strainCtr,:,statCtr+1));
    end
        
    subplot(2,numStrains+1,strainCtr)
    pie(pie_data(strainCtr,:))
    title(exp_strain_list(strainCtr), 'interpreter','none')
    
    subplot(2,numStrains+1,strainCtr+numStrains+1)
    pie(sim_strain_vars(strainCtr,:))
    title('var in distances')
end
subplot(2,numStrains+1,strainCtr+1)
pie(sum(pie_data))
title('Average across strains')
%%%
end