function mrtrix_nbs(partID,session)
%%% opens .mat output from QSIprep multishell recon
datadir='/data/';
%datadir='/shared/mrfil-data/pcamach2/MBB/bids/derivatives/qsirecon/'
msmtconnectome = strcat(datadir,partID,"/",session,"/dwi/",partID,"_",session,"_run-1_space-T1w_desc-preproc_space-T1w_msmtconnectome.mat");
load(msmtconnectome);



%%% normalizes weight of edges by maximum value using the BCT
%%% weight_conversion function, followed by an autofix to set the zero
%%% diagonal in the NxN matrix
aal116norm = weight_conversion(aal116_sift_radius2_count_connectivity, 'normalize');
aal116normF = weight_conversion(aal116norm, 'autofix');
aal116MeanStrength = mean(strengths_und(aal116normF));
aal116GlobalEfficiency = efficiency_wei(aal116normF, 0);
aal116MeanClusteringCoeff = mean(clustering_coef_wu(aal116normF));
%%%New
[aal116OptimalCommunityStructure, aal116MaximizedModularity] = modularity_und(aal116normF,1);
aal116weightedLengthMat = weight_conversion(aal116normF, 'lengths');
aal116distanceMat = distance_wei(aal116weightedLengthMat);
aal116NetworkCharacteristicPathLen = charpath(aal116distanceMat);
%[aal116GlobalDiffusionEfficiency,aal116PairwiseDiffusionEfficiencyMatrix] = diffusion_efficiency(aal116normF)

aal116NBSmat = zeros(1,5);
aal116NBSmat(1,1) = aal116GlobalEfficiency;
aal116NBSmat(1,2) = aal116MeanClusteringCoeff;
aal116NBSmat(1,3) = aal116MeanStrength;
%aal116NBSmat(1,4) = aal116OptimalCommunityStructure;
aal116NBSmat(1,4) = aal116MaximizedModularity;
aal116NBSmat(1,5) = aal116NetworkCharacteristicPathLen;    
%aal116NBSmat(1,6) = aal116GlobalDiffusionEfficiency;  
%save aal116PairwiseDiffusionEfficiencyMatrix;
save aal116OptimalCommunityStructure;

header = {'GlobalEfficiencyAAL116SC','MeanClusteringCoeffAAL116SC','MeanStrengthAAL116SC','MaximizedModularityAAL116SC','NetworkCharacteristicPathLenAAL116SC'};
NBStable = array2table(aal116NBSmat,'VariableNames',header);
nbstablename=strcat("qsi_nbs_",string(partID),"_aal116.txt");
writetable(NBStable,nbstablename);

%%%ROI-Wise Measures
               
aal116LocalEfficiency = efficiency_wei(aal116normF,2);
aal116ClusteringCoeff = clustering_coef_wu(aal116normF);
aal116Strength = strengths_und(aal116normF);
aal116Strength = aal116Strength.';
              
aal116NBSmatROI = zeros(length(aal116Strength),3);
aal116NBSmatROI(:,1) = aal116LocalEfficiency;
aal116NBSmatROI(:,2) = aal116ClusteringCoeff;
aal116NBSmatROI(:,3) = aal116Strength;
              
%Adds labels to save out per subject tables
aal116labels = cellstr(aal116_region_labels);
header1 = {'LocalEfficiency','ClusteringCoeff','Strength',};
                         
aal116NBSmatROIslabeled = aal116NBSmatROI;
aal116NBSmatROIslabeled = array2table(aal116NBSmatROIslabeled,'VariableNames',header1);
aal116NBSmatROIslabeled = addvars(aal116NBSmatROIslabeled,aal116labels,'Before','LocalEfficiency');
tableName = strcat(string(partID),"_qsi_nbs_rois_AAL116.txt");
writetable(aal116NBSmatROIslabeled,tableName);

brainnetome246norm = weight_conversion(brainnetome246_sift_radius2_count_connectivity, 'normalize');
brainnetome246normF = weight_conversion(brainnetome246norm, 'autofix');
brainnetome246MeanStrength = mean(strengths_und(brainnetome246normF));
brainnetome246GlobalEfficiency = efficiency_wei(brainnetome246normF, 0);
brainnetome246MeanClusteringCoeff = mean(clustering_coef_wu(brainnetome246normF));         
%%%New
[brainnetome246OptimalCommunityStructure, brainnetome246MaximizedModularity] = modularity_und(brainnetome246normF,1);
brainnetome246weightedLengthMat = weight_conversion(brainnetome246normF, 'lengths');
brainnetome246distanceMat = distance_wei(brainnetome246weightedLengthMat);
brainnetome246NetworkCharacteristicPathLen = charpath(brainnetome246distanceMat);
%[brainnetome246GlobalDiffusionEfficiency,brainnetome246PairwiseDiffusionEfficiencyMatrix] = diffusion_efficiency(brainnetome246normF)

brainnetome246NBSmat = zeros(1,5);
brainnetome246NBSmat(1,1) = brainnetome246GlobalEfficiency;
brainnetome246NBSmat(1,2) = brainnetome246MeanClusteringCoeff;
brainnetome246NBSmat(1,3) = brainnetome246MeanStrength;
%brainnetome246NBSmat(1,4) = brainnetome246OptimalCommunityStructure;
brainnetome246NBSmat(1,4) = brainnetome246MaximizedModularity;
brainnetome246NBSmat(1,5) = brainnetome246NetworkCharacteristicPathLen;    
%brainnetome246NBSmat(1,6) = brainnetome246GlobalDiffusionEfficiency;  
%save brainnetome246PairwiseDiffusionEfficiencyMatrix;
save brainnetome246OptimalCommunityStructure; 
             
header = {'GlobalEfficiencyBrainnetome246SC','MeanClusteringCoeffBrainnetome246SC','MeanStrengthBrainnetome246SC','MaximizedModularityBrainnetome246SC','NetworkCharacteristicPathLenBrainnetome246SC'};
NBStable = array2table(brainnetome246NBSmat,'VariableNames',header);
nbstablename=strcat("qsi_nbs_",string(partID),"_brainnetome246.txt");
writetable(NBStable,nbstablename);

%%%ROI-Wise Measures
               
brainnetome246LocalEfficiency = efficiency_wei(brainnetome246normF,2);
brainnetome246ClusteringCoeff = clustering_coef_wu(brainnetome246normF);
brainnetome246Strength = strengths_und(brainnetome246normF);
brainnetome246Strength = brainnetome246Strength.';
              
brainnetome246NBSmatROI = zeros(length(brainnetome246Strength),3);
brainnetome246NBSmatROI(:,1) = brainnetome246LocalEfficiency;
brainnetome246NBSmatROI(:,2) = brainnetome246ClusteringCoeff;
brainnetome246NBSmatROI(:,3) = brainnetome246Strength;
              
%Adds labels to save out per subject tables
brainnetome246labels = cellstr(brainnetome246_region_labels);
header1 = {'LocalEfficiency','ClusteringCoeff','Strength',};
                         
brainnetome246NBSmatROIslabeled = brainnetome246NBSmatROI;
brainnetome246NBSmatROIslabeled = array2table(brainnetome246NBSmatROIslabeled,'VariableNames',header1);
brainnetome246NBSmatROIslabeled = addvars(brainnetome246NBSmatROIslabeled,brainnetome246labels,'Before','LocalEfficiency');
tableName = strcat(string(partID),"_qsi_nbs_rois_brainnetome246.txt");
writetable(brainnetome246NBSmatROIslabeled,tableName);

power264norm = weight_conversion(power264_sift_radius2_count_connectivity, 'normalize');
power264normF = weight_conversion(power264norm, 'autofix');
power264MeanStrength = mean(strengths_und(power264normF));
power264GlobalEfficiency = efficiency_wei(power264normF, 0);
power264MeanClusteringCoeff = mean(clustering_coef_wu(power264normF));
            
%%%New
[power264OptimalCommunityStructure, power264MaximizedModularity] = modularity_und(power264normF,1);
power264weightedLengthMat = weight_conversion(power264normF, 'lengths');
power264distanceMat = distance_wei(power264weightedLengthMat);
power264NetworkCharacteristicPathLen = charpath(power264distanceMat);
%[power264GlobalDiffusionEfficiency,power264PairwiseDiffusionEfficiencyMatrix] = diffusion_efficiency(power264normF)

power264NBSmat = zeros(1,5);
power264NBSmat(1,1) = power264GlobalEfficiency;
power264NBSmat(1,2) = power264MeanClusteringCoeff;
power264NBSmat(1,3) = power264MeanStrength;
%power264NBSmat(1,4) = power264OptimalCommunityStructure;
power264NBSmat(1,4) = power264MaximizedModularity;
power264NBSmat(1,5) = power264NetworkCharacteristicPathLen;    
%power264NBSmat(1,6) = power264GlobalDiffusionEfficiency;  
%save power264PairwiseDiffusionEfficiencyMatrix;
save power264OptimalCommunityStructure;
              
header = {'GlobalEfficiencyPower264SC','MeanClusteringCoeffPower264SC','MeanStrengthPower264SC','MaximizedModularityPower264SC','NetworkCharacteristicPathLenPower264SC'};
NBStable = array2table(power264NBSmat,'VariableNames',header);
nbstablename=strcat("qsi_nbs_",string(partID),"_power264.txt");
writetable(NBStable,nbstablename);

%%%ROI-Wise Measures
               
power264LocalEfficiency = efficiency_wei(power264normF,2);
power264ClusteringCoeff = clustering_coef_wu(power264normF);
power264Strength = strengths_und(power264normF);
power264Strength = power264Strength.';
              
power264NBSmatROI = zeros(length(power264Strength),3);
power264NBSmatROI(:,1) = power264LocalEfficiency;
power264NBSmatROI(:,2) = power264ClusteringCoeff;
power264NBSmatROI(:,3) = power264Strength;
              
%Adds labels to save out per subject tables
power264labels = cellstr(power264_region_labels);
header1 = {'LocalEfficiency','ClusteringCoeff','Strength',};
                         
power264NBSmatROIslabeled = power264NBSmatROI;
power264NBSmatROIslabeled = array2table(power264NBSmatROIslabeled,'VariableNames',header1);
power264NBSmatROIslabeled = addvars(power264NBSmatROIslabeled,power264labels,'Before','LocalEfficiency');
tableName = strcat(string(partID),"_qsi_nbs_rois_power264.txt");
writetable(power264NBSmatROIslabeled,tableName);


end
