function files = netproc_single(location)

mainfolder = location;
% subfolders = dir(mainfolder);
% subfolders = subfolders([subfolders.isdir] & ~startsWith({subfolders.name},'.'));

   
    dkfiles = dir(fullfile(mainfolder,'desikanKilliany','*.net'));
    powerfiles = dir(fullfile(mainfolder,'power264','*.net'));
    aalfiles = dir(fullfile(mainfolder,'aal116','*.net'));
    
    files=[dkfiles,powerfiles,aalfiles];
    
    
    for k = 1:length(files)
        fid = fopen(fullfile(files(k).folder,files(k).name)); % corrected path
             
              %%%labels as cell
              powerlabels = {'Uncertain_1','Uncertain_2','Uncertain_3','Uncertain_4','Uncertain_5','Uncertain_6','Uncertain_7','Uncertain_8','Uncertain_9','Uncertain_10','Uncertain_11','Uncertain_12','Sensory_Somatomotor_Hand_13','Sensory_Somatomotor_Hand_14','Sensory_Somatomotor_Hand_15','Sensory_Somatomotor_Hand_16','Sensory_Somatomotor_Hand_17','Sensory_Somatomotor_Hand_18','Sensory_Somatomotor_Hand_19','Sensory_Somatomotor_Hand_20','Sensory_Somatomotor_Hand_21','Sensory_Somatomotor_Hand_22','Sensory_Somatomotor_Hand_23','Sensory_Somatomotor_Hand_24','Sensory_Somatomotor_Hand_25','Sensory_Somatomotor_Hand_26','Sensory_Somatomotor_Hand_27','Sensory_Somatomotor_Hand_28','Sensory_Somatomotor_Hand_29','Sensory_Somatomotor_Hand_30','Sensory_Somatomotor_Hand_31','Sensory_Somatomotor_Hand_32','Sensory_Somatomotor_Hand_33','Sensory_Somatomotor_Hand_34','Sensory_Somatomotor_Hand_35','Sensory_Somatomotor_Hand_36','Sensory_Somatomotor_Hand_37','Sensory_Somatomotor_Hand_38','Sensory_Somatomotor_Hand_39','Sensory_Somatomotor_Hand_40','Sensory_Somatomotor_Hand_41','Sensory_Somatomotor_Mouth_42','Sensory_Somatomotor_Mouth_43','Sensory_Somatomotor_Mouth_44','Sensory_Somatomotor_Mouth_45','Sensory_Somatomotor_Mouth_46','Cingulo_opercular_Task_Control_47','Cingulo_opercular_Task_Control_48','Cingulo_opercular_Task_Control_49','Cingulo_opercular_Task_Control_50','Cingulo_opercular_Task_Control_51','Cingulo_opercular_Task_Control_52','Cingulo_opercular_Task_Control_53','Cingulo_opercular_Task_Control_54','Cingulo_opercular_Task_Control_55','Cingulo_opercular_Task_Control_56','Cingulo_opercular_Task_Control_57','Cingulo_opercular_Task_Control_58','Cingulo_opercular_Task_Control_59','Cingulo_opercular_Task_Control_60','Auditory_61','Auditory_62','Auditory_63','Auditory_64','Auditory_65','Auditory_66','Auditory_67','Auditory_68','Auditory_69','Auditory_70','Auditory_71','Auditory_72','Auditory_73','Default_mode_74','Default_mode_75','Default_mode_76','Default_mode_77','Default_mode_78','Default_mode_79','Default_mode_80','Default_mode_81','Default_mode_82','Default_mode_83','Uncertain_84','Uncertain_85','Default_mode_86','Default_mode_87','Default_mode_88','Default_mode_89','Default_mode_90','Default_mode_91','Default_mode_92','Default_mode_93','Default_mode_94','Default_mode_95','Default_mode_96','Default_mode_97','Default_mode_98','Default_mode_99','Default_mode_100','Default_mode_101','Default_mode_102','Default_mode_103','Default_mode_104','Default_mode_105','Default_mode_106','Default_mode_107','Default_mode_108','Default_mode_109','Default_mode_110','Default_mode_111','Default_mode_112','Default_mode_113','Default_mode_114','Default_mode_115','Default_mode_116','Default_mode_117','Default_mode_118','Default_mode_119','Default_mode_120','Default_mode_121','Default_mode_122','Default_mode_123','Default_mode_124','Default_mode_125','Default_mode_126','Default_mode_127','Default_mode_128','Default_mode_129','Default_mode_130','Default_mode_131','Uncertain_132','Memory_retrieval_133','Memory_retrieval_134','Memory_retrieval_135','Memory_retrieval_136','Default_mode_137','Ventral_attention_138','Default_mode_139','Uncertain_140','Uncertain_141','Uncertain_142','Visual_143','Visual_144','Visual_145','Visual_146','Visual_147','Visual_148','Visual_149','Visual_150','Visual_151','Visual_152','Visual_153','Visual_154','Visual_155','Visual_156','Visual_157','Visual_158','Visual_159','Visual_160','Visual_161','Visual_162','Visual_163','Visual_164','Visual_165','Visual_166','Visual_167','Visual_168','Visual_169','Visual_170','Visual_171','Visual_172','Visual_173','Fronto_parietal_Task_Control_174','Fronto_parietal_Task_Control_175','Fronto_parietal_Task_Control_176','Fronto_parietal_Task_Control_177','Fronto_parietal_Task_Control_178','Fronto_parietal_Task_Control_179','Fronto_parietal_Task_Control_180','Fronto_parietal_Task_Control_181','Uncertain_182','Uncertain_183','Uncertain_184','Uncertain_185','Fronto_parietal_Task_Control_186','Fronto_parietal_Task_Control_187','Fronto_parietal_Task_Control_188','Fronto_parietal_Task_Control_189','Fronto_parietal_Task_Control_190','Fronto_parietal_Task_Control_191','Fronto_parietal_Task_Control_192','Fronto_parietal_Task_Control_193','Fronto_parietal_Task_Control_194','Fronto_parietal_Task_Control_195','Fronto_parietal_Task_Control_196','Fronto_parietal_Task_Control_197','Fronto_parietal_Task_Control_198','Fronto_parietal_Task_Control_199','Fronto_parietal_Task_Control_200','Fronto_parietal_Task_Control_201','Fronto_parietal_Task_Control_202','Salience_203','Salience_204','Salience_205','Salience_206','Salience_207','Salience_208','Salience_209','Salience_210','Salience_211','Salience_212','Salience_213','Salience_214','Salience_215','Salience_216','Salience_217','Salience_218','Salience_219','Salience_220','Memory_retrieval_221','Subcortical_222','Subcortical_223','Subcortical_224','Subcortical_225','Subcortical_226','Subcortical_227','Subcortical_228','Subcortical_229','Subcortical_230','Subcortical_231','Subcortical_232','Subcortical_233','Subcortical_234','Ventral_attention_235','Ventral_attention_236','Ventral_attention_237','Ventral_attention_238','Ventral_attention_239','Ventral_attention_240','Ventral_attention_241','Ventral_attention_242','Cerebellar_243','Cerebellar_244','Cerebellar_245','Cerebellar_246','Uncertain_247','Uncertain_248','Uncertain_249','Uncertain_250','Dorsal_attention_251','Dorsal_attention_252','Uncertain_253','Uncertain_254','Sensory_Somatomotor_Hand_255','Dorsal_attention_256','Dorsal_attention_257','Dorsal_attention_258','Dorsal_attention_259','Dorsal_attention_260','Dorsal_attention_261','Dorsal_attention_262','Dorsal_attention_263','Dorsal_attention_264'};
              aallabels = {'Precentral_L','Precentral_R','Frontal_Sup_L','Frontal_Sup_R','Frontal_Sup_Orb_L','Frontal_Sup_Orb_R','Frontal_Mid_L','Frontal_Mid_R','Frontal_Mid_Orb_L','Frontal_Mid_Orb_R','Frontal_Inf_Oper_L','Frontal_Inf_Oper_R','Frontal_Inf_Tri_L','Frontal_Inf_Tri_R','Frontal_Inf_Orb_L','Frontal_Inf_Orb_R','Rolandic_Oper_L','Rolandic_Oper_R','Supp_Motor_Area_L','Supp_Motor_Area_R','Olfactory_L','Olfactory_R','Frontal_Sup_Medial_L','Frontal_Sup_Medial_R','Frontal_Med_Orb_L','Frontal_Med_Orb_R','Rectus_L','Rectus_R','Insula_L','Insula_R','Cingulum_Ant_L','Cingulum_Ant_R','Cingulum_Mid_L','Cingulum_Mid_R','Cingulum_Post_L','Cingulum_Post_R','Hippocampus_L','Hippocampus_R','ParaHippocampal_L','ParaHippocampal_R','Amygdala_L','Amygdala_R','Calcarine_L','Calcarine_R','Cuneus_L','Cuneus_R','Lingual_L','Lingual_R','Occipital_Sup_L','Occipital_Sup_R','Occipital_Mid_L','Occipital_Mid_R','Occipital_Inf_L','Occipital_Inf_R','Fusiform_L','Fusiform_R','Postcentral_L','Postcentral_R','Parietal_Sup_L','Parietal_Sup_R','Parietal_Inf_L','Parietal_Inf_R','SupraMarginal_L','SupraMarginal_R','Angular_L','Angular_R','Precuneus_L','Precuneus_R','Paracentral_Lobule_L','Paracentral_Lobule_R','Caudate_L','Caudate_R','Putamen_L','Putamen_R','Pallidum_L','Pallidum_R','Thalamus_L','Thalamus_R','Heschl_L','Heschl_R','Temporal_Sup_L','Temporal_Sup_R','Temporal_Pole_Sup_L','Temporal_Pole_Sup_R','Temporal_Mid_L','Temporal_Mid_R','Temporal_Pole_Mid_L','Temporal_Pole_Mid_R','Temporal_Inf_L','Temporal_Inf_R','Cerebelum_Crus1_L','Cerebelum_Crus1_R','Cerebelum_Crus2_L','Cerebelum_Crus2_R','Cerebelum_3_L','Cerebelum_3_R','Cerebelum_4_5_L','Cerebelum_4_5_R','Cerebelum_6_L','Cerebelum_6_R','Cerebelum_7b_L','Cerebelum_7b_R','Cerebelum_8_L','Cerebelum_8_R','Cerebelum_9_L','Cerebelum_9_R','Cerebelum_10_L','Cerebelum_10_R','Vermis_1_2','Vermis_3','Vermis_4_5','Vermis_6','Vermis_7','Vermis_8','Vermis_9','Vermis_10'};
              desikanKillianylabels = {"Left_Cerebral_White_Matter","Left_Lateral_Ventricle","Left_Inf_Lat_Vent","Left_Cerebellum_White_Matter","Left_Cerebellum_Cortex","Left_Thalamus_Proper","Left_Caudate","Left_Putamen","Left_Pallidum","Third_Ventricle","Fourth_Ventricle","Brain_Stem","Left_Hippocampus","Left_Amygdala","CSF","Left_Accumbens_area","Left_VentralDC","Left_vessel","Left_choroid_plexus","Right_Cerebral_White_Matter","Right_Lateral_Ventricle","Right_Inf_Lat_Vent","Right_Cerebellum_White_Matter","Right_Cerebellum_Cortex","Right_Thalamus_Proper","Right_Caudate","Right_Putamen","Right_Pallidum","Right_Hippocampus","Right_Amygdala","Right_Accumbens_area","Right_VentralDC","Right_vessel","Right_choroid_plexus","WM_hypointensities","non_WM_hypointensities","Optic_Chiasm","CC_Posterior","CC_Mid_Posterior","CC_Central","CC_Mid_Anterior","CC_Anterior","ctx_lh_unknown","ctx_lh_bankssts","ctx_lh_caudalanteriorcingulate","ctx_lh_caudalmiddlefrontal","ctx_lh_cuneus","ctx_lh_entorhinal","ctx_lh_fusiform","ctx_lh_inferiorparietal","ctx_lh_inferiortemporal","ctx_lh_isthmuscingulate","ctx_lh_lateraloccipital","ctx_lh_lateralorbitofrontal","ctx_lh_lingual","ctx_lh_medialorbitofrontal","ctx_lh_middletemporal","ctx_lh_parahippocampal","ctx_lh_paracentral","ctx_lh_parsopercularis","ctx_lh_parsorbitalis","ctx_lh_parstriangularis","ctx_lh_pericalcarine","ctx_lh_postcentral","ctx_lh_posteriorcingulate","ctx_lh_precentral","ctx_lh_precuneus","ctx_lh_rostralanteriorcingulate","ctx_lh_rostralmiddlefrontal","ctx_lh_superiorfrontal","ctx_lh_superiorparietal","ctx_lh_superiortemporal","ctx_lh_supramarginal","ctx_lh_frontalpole","ctx_lh_temporalpole","ctx_lh_transversetemporal","ctx_lh_insula","ctx_rh_unknown","ctx_rh_bankssts","ctx_rh_caudalanteriorcingulate","ctx_rh_caudalmiddlefrontal","ctx_rh_cuneus","ctx_rh_entorhinal","ctx_rh_fusiform","ctx_rh_inferiorparietal","ctx_rh_inferiortemporal","ctx_rh_isthmuscingulate","ctx_rh_lateraloccipital","ctx_rh_lateralorbitofrontal","ctx_rh_lingual","ctx_rh_medialorbitofrontal","ctx_rh_middletemporal","ctx_rh_parahippocampal","ctx_rh_paracentral","ctx_rh_parsopercularis","ctx_rh_parsorbitalis","ctx_rh_parstriangularis","ctx_rh_pericalcarine","ctx_rh_postcentral","ctx_rh_posteriorcingulate","ctx_rh_precentral","ctx_rh_precuneus","ctx_rh_rostralanteriorcingulate","ctx_rh_rostralmiddlefrontal","ctx_rh_superiorfrontal","ctx_rh_superiorparietal","ctx_rh_superiortemporal","ctx_rh_supramarginal","ctx_rh_frontalpole","ctx_rh_temporalpole","ctx_rh_transversetemporal","ctx_rh_insula"};
              
              %%%labels as string
              powerlabelsS = ["Uncertain_1",'Uncertain_2','Uncertain_3','Uncertain_4','Uncertain_5','Uncertain_6','Uncertain_7','Uncertain_8','Uncertain_9','Uncertain_10','Uncertain_11','Uncertain_12','Sensory_Somatomotor_Hand_13','Sensory_Somatomotor_Hand_14','Sensory_Somatomotor_Hand_15','Sensory_Somatomotor_Hand_16','Sensory_Somatomotor_Hand_17','Sensory_Somatomotor_Hand_18','Sensory_Somatomotor_Hand_19','Sensory_Somatomotor_Hand_20','Sensory_Somatomotor_Hand_21','Sensory_Somatomotor_Hand_22','Sensory_Somatomotor_Hand_23','Sensory_Somatomotor_Hand_24','Sensory_Somatomotor_Hand_25','Sensory_Somatomotor_Hand_26','Sensory_Somatomotor_Hand_27','Sensory_Somatomotor_Hand_28','Sensory_Somatomotor_Hand_29','Sensory_Somatomotor_Hand_30','Sensory_Somatomotor_Hand_31','Sensory_Somatomotor_Hand_32','Sensory_Somatomotor_Hand_33','Sensory_Somatomotor_Hand_34','Sensory_Somatomotor_Hand_35','Sensory_Somatomotor_Hand_36','Sensory_Somatomotor_Hand_37','Sensory_Somatomotor_Hand_38','Sensory_Somatomotor_Hand_39','Sensory_Somatomotor_Hand_40','Sensory_Somatomotor_Hand_41','Sensory_Somatomotor_Mouth_42','Sensory_Somatomotor_Mouth_43','Sensory_Somatomotor_Mouth_44','Sensory_Somatomotor_Mouth_45','Sensory_Somatomotor_Mouth_46','Cingulo_opercular_Task_Control_47','Cingulo_opercular_Task_Control_48','Cingulo_opercular_Task_Control_49','Cingulo_opercular_Task_Control_50','Cingulo_opercular_Task_Control_51','Cingulo_opercular_Task_Control_52','Cingulo_opercular_Task_Control_53','Cingulo_opercular_Task_Control_54','Cingulo_opercular_Task_Control_55','Cingulo_opercular_Task_Control_56','Cingulo_opercular_Task_Control_57','Cingulo_opercular_Task_Control_58','Cingulo_opercular_Task_Control_59','Cingulo_opercular_Task_Control_60','Auditory_61','Auditory_62','Auditory_63','Auditory_64','Auditory_65','Auditory_66','Auditory_67','Auditory_68','Auditory_69','Auditory_70','Auditory_71','Auditory_72','Auditory_73','Default_mode_74','Default_mode_75','Default_mode_76','Default_mode_77','Default_mode_78','Default_mode_79','Default_mode_80','Default_mode_81','Default_mode_82','Default_mode_83','Uncertain_84','Uncertain_85','Default_mode_86','Default_mode_87','Default_mode_88','Default_mode_89','Default_mode_90','Default_mode_91','Default_mode_92','Default_mode_93','Default_mode_94','Default_mode_95','Default_mode_96','Default_mode_97','Default_mode_98','Default_mode_99','Default_mode_100','Default_mode_101','Default_mode_102','Default_mode_103','Default_mode_104','Default_mode_105','Default_mode_106','Default_mode_107','Default_mode_108','Default_mode_109','Default_mode_110','Default_mode_111','Default_mode_112','Default_mode_113','Default_mode_114','Default_mode_115','Default_mode_116','Default_mode_117','Default_mode_118','Default_mode_119','Default_mode_120','Default_mode_121','Default_mode_122','Default_mode_123','Default_mode_124','Default_mode_125','Default_mode_126','Default_mode_127','Default_mode_128','Default_mode_129','Default_mode_130','Default_mode_131','Uncertain_132','Memory_retrieval_133','Memory_retrieval_134','Memory_retrieval_135','Memory_retrieval_136','Default_mode_137','Ventral_attention_138','Default_mode_139','Uncertain_140','Uncertain_141','Uncertain_142','Visual_143','Visual_144','Visual_145','Visual_146','Visual_147','Visual_148','Visual_149','Visual_150','Visual_151','Visual_152','Visual_153','Visual_154','Visual_155','Visual_156','Visual_157','Visual_158','Visual_159','Visual_160','Visual_161','Visual_162','Visual_163','Visual_164','Visual_165','Visual_166','Visual_167','Visual_168','Visual_169','Visual_170','Visual_171','Visual_172','Visual_173','Fronto_parietal_Task_Control_174','Fronto_parietal_Task_Control_175','Fronto_parietal_Task_Control_176','Fronto_parietal_Task_Control_177','Fronto_parietal_Task_Control_178','Fronto_parietal_Task_Control_179','Fronto_parietal_Task_Control_180','Fronto_parietal_Task_Control_181','Uncertain_182','Uncertain_183','Uncertain_184','Uncertain_185','Fronto_parietal_Task_Control_186','Fronto_parietal_Task_Control_187','Fronto_parietal_Task_Control_188','Fronto_parietal_Task_Control_189','Fronto_parietal_Task_Control_190','Fronto_parietal_Task_Control_191','Fronto_parietal_Task_Control_192','Fronto_parietal_Task_Control_193','Fronto_parietal_Task_Control_194','Fronto_parietal_Task_Control_195','Fronto_parietal_Task_Control_196','Fronto_parietal_Task_Control_197','Fronto_parietal_Task_Control_198','Fronto_parietal_Task_Control_199','Fronto_parietal_Task_Control_200','Fronto_parietal_Task_Control_201','Fronto_parietal_Task_Control_202','Salience_203','Salience_204','Salience_205','Salience_206','Salience_207','Salience_208','Salience_209','Salience_210','Salience_211','Salience_212','Salience_213','Salience_214','Salience_215','Salience_216','Salience_217','Salience_218','Salience_219','Salience_220','Memory_retrieval_221','Subcortical_222','Subcortical_223','Subcortical_224','Subcortical_225','Subcortical_226','Subcortical_227','Subcortical_228','Subcortical_229','Subcortical_230','Subcortical_231','Subcortical_232','Subcortical_233','Subcortical_234','Ventral_attention_235','Ventral_attention_236','Ventral_attention_237','Ventral_attention_238','Ventral_attention_239','Ventral_attention_240','Ventral_attention_241','Ventral_attention_242','Cerebellar_243','Cerebellar_244','Cerebellar_245','Cerebellar_246','Uncertain_247','Uncertain_248','Uncertain_249','Uncertain_250','Dorsal_attention_251','Dorsal_attention_252','Uncertain_253','Uncertain_254','Sensory_Somatomotor_Hand_255','Dorsal_attention_256','Dorsal_attention_257','Dorsal_attention_258','Dorsal_attention_259','Dorsal_attention_260','Dorsal_attention_261','Dorsal_attention_262','Dorsal_attention_263','Dorsal_attention_264'];
              aallabelsS = ["Precentral_L",'Precentral_R','Frontal_Sup_L','Frontal_Sup_R','Frontal_Sup_Orb_L','Frontal_Sup_Orb_R','Frontal_Mid_L','Frontal_Mid_R','Frontal_Mid_Orb_L','Frontal_Mid_Orb_R','Frontal_Inf_Oper_L','Frontal_Inf_Oper_R','Frontal_Inf_Tri_L','Frontal_Inf_Tri_R','Frontal_Inf_Orb_L','Frontal_Inf_Orb_R','Rolandic_Oper_L','Rolandic_Oper_R','Supp_Motor_Area_L','Supp_Motor_Area_R','Olfactory_L','Olfactory_R','Frontal_Sup_Medial_L','Frontal_Sup_Medial_R','Frontal_Med_Orb_L','Frontal_Med_Orb_R','Rectus_L','Rectus_R','Insula_L','Insula_R','Cingulum_Ant_L','Cingulum_Ant_R','Cingulum_Mid_L','Cingulum_Mid_R','Cingulum_Post_L','Cingulum_Post_R','Hippocampus_L','Hippocampus_R','ParaHippocampal_L','ParaHippocampal_R','Amygdala_L','Amygdala_R','Calcarine_L','Calcarine_R','Cuneus_L','Cuneus_R','Lingual_L','Lingual_R','Occipital_Sup_L','Occipital_Sup_R','Occipital_Mid_L','Occipital_Mid_R','Occipital_Inf_L','Occipital_Inf_R','Fusiform_L','Fusiform_R','Postcentral_L','Postcentral_R','Parietal_Sup_L','Parietal_Sup_R','Parietal_Inf_L','Parietal_Inf_R','SupraMarginal_L','SupraMarginal_R','Angular_L','Angular_R','Precuneus_L','Precuneus_R','Paracentral_Lobule_L','Paracentral_Lobule_R','Caudate_L','Caudate_R','Putamen_L','Putamen_R','Pallidum_L','Pallidum_R','Thalamus_L','Thalamus_R','Heschl_L','Heschl_R','Temporal_Sup_L','Temporal_Sup_R','Temporal_Pole_Sup_L','Temporal_Pole_Sup_R','Temporal_Mid_L','Temporal_Mid_R','Temporal_Pole_Mid_L','Temporal_Pole_Mid_R','Temporal_Inf_L','Temporal_Inf_R','Cerebelum_Crus1_L','Cerebelum_Crus1_R','Cerebelum_Crus2_L','Cerebelum_Crus2_R','Cerebelum_3_L','Cerebelum_3_R','Cerebelum_4_5_L','Cerebelum_4_5_R','Cerebelum_6_L','Cerebelum_6_R','Cerebelum_7b_L','Cerebelum_7b_R','Cerebelum_8_L','Cerebelum_8_R','Cerebelum_9_L','Cerebelum_9_R','Cerebelum_10_L','Cerebelum_10_R','Vermis_1_2','Vermis_3','Vermis_4_5','Vermis_6','Vermis_7','Vermis_8','Vermis_9','Vermis_10'];
              desikanKillianylabelsS = ["Left_Cerebral_White_Matter","Left_Lateral_Ventricle","Left_Inf_Lat_Vent","Left_Cerebellum_White_Matter","Left_Cerebellum_Cortex","Left_Thalamus_Proper","Left_Caudate","Left_Putamen","Left_Pallidum","Third_Ventricle","Fourth_Ventricle","Brain_Stem","Left_Hippocampus","Left_Amygdala","CSF","Left_Accumbens_area","Left_VentralDC","Left_vessel","Left_choroid_plexus","Right_Cerebral_White_Matter","Right_Lateral_Ventricle","Right_Inf_Lat_Vent","Right_Cerebellum_White_Matter","Right_Cerebellum_Cortex","Right_Thalamus_Proper","Right_Caudate","Right_Putamen","Right_Pallidum","Right_Hippocampus","Right_Amygdala","Right_Accumbens_area","Right_VentralDC","Right_vessel","Right_choroid_plexus","WM_hypointensities","non_WM_hypointensities","Optic_Chiasm","CC_Posterior","CC_Mid_Posterior","CC_Central","CC_Mid_Anterior","CC_Anterior","ctx_lh_unknown","ctx_lh_bankssts","ctx_lh_caudalanteriorcingulate","ctx_lh_caudalmiddlefrontal","ctx_lh_cuneus","ctx_lh_entorhinal","ctx_lh_fusiform","ctx_lh_inferiorparietal","ctx_lh_inferiortemporal","ctx_lh_isthmuscingulate","ctx_lh_lateraloccipital","ctx_lh_lateralorbitofrontal","ctx_lh_lingual","ctx_lh_medialorbitofrontal","ctx_lh_middletemporal","ctx_lh_parahippocampal","ctx_lh_paracentral","ctx_lh_parsopercularis","ctx_lh_parsorbitalis","ctx_lh_parstriangularis","ctx_lh_pericalcarine","ctx_lh_postcentral","ctx_lh_posteriorcingulate","ctx_lh_precentral","ctx_lh_precuneus","ctx_lh_rostralanteriorcingulate","ctx_lh_rostralmiddlefrontal","ctx_lh_superiorfrontal","ctx_lh_superiorparietal","ctx_lh_superiortemporal","ctx_lh_supramarginal","ctx_lh_frontalpole","ctx_lh_temporalpole","ctx_lh_transversetemporal","ctx_lh_insula","ctx_rh_unknown","ctx_rh_bankssts","ctx_rh_caudalanteriorcingulate","ctx_rh_caudalmiddlefrontal","ctx_rh_cuneus","ctx_rh_entorhinal","ctx_rh_fusiform","ctx_rh_inferiorparietal","ctx_rh_inferiortemporal","ctx_rh_isthmuscingulate","ctx_rh_lateraloccipital","ctx_rh_lateralorbitofrontal","ctx_rh_lingual","ctx_rh_medialorbitofrontal","ctx_rh_middletemporal","ctx_rh_parahippocampal","ctx_rh_paracentral","ctx_rh_parsopercularis","ctx_rh_parsorbitalis","ctx_rh_parstriangularis","ctx_rh_pericalcarine","ctx_rh_postcentral","ctx_rh_posteriorcingulate","ctx_rh_precentral","ctx_rh_precuneus","ctx_rh_rostralanteriorcingulate","ctx_rh_rostralmiddlefrontal","ctx_rh_superiorfrontal","ctx_rh_superiorparietal","ctx_rh_superiortemporal","ctx_rh_supramarginal","ctx_rh_frontalpole","ctx_rh_temporalpole","ctx_rh_transversetemporal","ctx_rh_insula"];

              cline = fgetl(fid);
              if strfind(cline,'*Vertices ')
                verts = str2num(cline(11:end));
              else
                sprintf('Expected first line to have *Vertices \n')
                sprintf('Instead saw %s \n',cline)
              return
              end
              
              net_mat = zeros(verts);  % initialize net_mats to 0's
              cline = fgetl(fid);   %This is just Edges label line

              while 1
                cline = fgetl(fid);
                if ~ischar(cline), break, end
                info_line=str2double(regexp(cline,'[%_[+-]?\d.]+','match'));
                net_mat(info_line(1),info_line(2)) = info_line(3);
                net_mat(info_line(2),info_line(1)) = info_line(3);
              end

%               fclose(fid)

              netmatname=strcat(files(k).name(1:end-4),'net_mat');
              writematrix(net_mat,netmatname);
              
              %edit labels per atlas
              if contains(files(k).name, 'desikanKilliany') 
                  net_mat_label = array2table(net_mat,'VariableNames',desikanKillianylabelsS);
              elseif contains(files(k).name, 'power264')
                  net_mat_label = array2table(net_mat,'VariableNames',powerlabelsS);
              elseif contains(files(k).name, 'aal116')
                  net_mat_label = array2table(net_mat,'VariableNames',aallabelsS);
              end
              
              netmatnamelabel=strcat(files(k).name(1:end-4),"net_mat_labeled");
              writetable(net_mat_label,netmatnamelabel);

              %%%Separates NxN correlation matrix plotting with circularGraph 
              %%% (https://github.com/paul-kassebaum-mathworks/circularGraph
              Raw = net_mat;
              tmp = Raw;
              indices = (tmp)>0;
              tmp(indices) = 0;
              NegCorr = tmp;
              %Uncomment the line below for circularGraph compatibility
              %NegCorr = abs(NegCorr);
              negname=strcat(files(k).name(1:end-4),"net_mat_neg");
              writematrix(NegCorr,negname);

              %edit labels per atlas
              if contains(files(k).name, 'desikanKilliany') 
                  negtable = array2table(NegCorr,'VariableNames',desikanKillianylabelsS);
              elseif contains(files(k).name, 'power264')
                  negtable = array2table(NegCorr,'VariableNames',powerlabelsS);
              elseif contains(files(k).name, 'aal116')
                  negtable = array2table(NegCorr,'VariableNames',aallabelsS);
              end
              
              negtablelabeled=strcat(files(k).name(1:end-4),"net_mat_neg_labeled");
              writetable(negtable,negtablelabeled);
              
              tmp = Raw;
              indices = (tmp)<0;
              tmp(indices) = 0;
              PosCorr = tmp;
%             save PosCorr PosCorr
              posname=strcat(files(k).name(1:end-4),"net_mat_pos");
              writematrix(PosCorr,posname); 
              
              %edit labels per atlas
              if contains(files(k).name, 'desikanKilliany') 
                  postable = array2table(PosCorr,'VariableNames',desikanKillianylabelsS);
              elseif contains(files(k).name, 'power264')
                  postable = array2table(PosCorr,'VariableNames',powerlabelsS);
              elseif contains(files(k).name, 'aal116')
                  postable = array2table(PosCorr,'VariableNames',aallabelsS);
              end
              postablelabeled=strcat(files(k).name(1:end-4),"net_mat_pos_labeled");
              writetable(postable,postablelabeled);

              %%%Computes Network-Based Statistics using the BCT 
              %%% 
              %%% Add the downloaded folder to path first
              GlobalEfficiency = efficiency_wei(PosCorr, 0);
              [C_pos, C_neg, MeanClusteringCoeffPos, MeanClusteringCoeffNeg] = clustering_coef_wu_sign(net_mat);
              MeanClusteringCoeff = ((mean(C_pos) + mean(C_neg))/2); 
              [Spos, Sneg, TotalStrengthPos, TotalStrengthNeg] = strengths_und_sign(net_mat);
              MeanTotalStrength = (TotalStrengthPos + TotalStrengthNeg)/2;
              MeanStrength = (mean(Spos) + mean(Sneg))/2;
              %%%New
              [OptimalCommunityStructure, MaximizedModularity] = modularity_und(PosCorr,1);
              weightedLengthMat = weight_conversion(PosCorr, 'lengths');
              distanceMat = distance_wei(weightedLengthMat);
              NetworkCharacteristicPathLen = charpath(distanceMat);


              NBSmat = zeros(1,10);
              NBSmat(1,1) = GlobalEfficiency;
              NBSmat(1,2) = MeanClusteringCoeff;
              NBSmat(1,3) = MeanClusteringCoeffPos;
              NBSmat(1,4) = MeanClusteringCoeffNeg;
              NBSmat(1,5) = MeanStrength;
              NBSmat(1,6) = MeanTotalStrength;
              NBSmat(1,7) = TotalStrengthPos;
              NBSmat(1,8) = TotalStrengthNeg;
              %NBSmat(1,9) = OptimalCommunityStructure;
              NBSmat(1,9) = MaximizedModularity;
              NBSmat(1,10) = NetworkCharacteristicPathLen;
              
%	      save OptimalCommunityStructure;
        
              nbsmatname=strcat(files(k).name(1:end-4),"nbs");
              writematrix(NBSmat,nbsmatname);
              
           
%               %Adds labels to save out per subject tables
%                           
%               NBSmatS = zeros(1,8);
%               iD = str2double(files(k).name(9:end-13));
%               NBSmatS(1,1) = iD; 
%               NBSmatS(1,2:end) = NBSmat;
           
              
              header = {'GlobalEfficiency','MeanClusteringCoeff','MeanClusteringCoeffPos','MeanClusteringCoeffNeg','MeanStrength','MeanTotalStrength','TotalStrengthPos','TotalStrengthNeg','MaximizedModularity','NetworkCharacteristicPathLen'};
              NBStable = array2table(NBSmat,'VariableNames',header);
              nbstablename=strcat(files(k).name(1:end-4),"nbs_table.txt");
              writetable(NBStable,nbstablename);


              
              %%%ROI-Wise Measures
              if contains(files(k).name, 'desikanKilliany') 
                  numROI = 112;
              elseif contains(files(k).name, 'power264')
                  numROI = 264;
              elseif contains(files(k).name, 'aal116')
                  numROI = 116;
              end
              
              
              LocalEfficiency = efficiency_wei(PosCorr,2);
              Spos = Spos.';
              Sneg = Sneg.';
              
              NBSmatROI = zeros(numROI,5);
              NBSmatROI(:,1) = LocalEfficiency;
              NBSmatROI(:,2) = C_pos;
              NBSmatROI(:,3) = C_neg;
              NBSmatROI(:,4) = Spos;
              NBSmatROI(:,5) = Sneg;
              
              %Adds labels to save out per subject tables
              if contains(files(k).name, 'desikanKilliany') 
                  roilabels = desikanKillianylabelsS;
              elseif contains(files(k).name, 'power264')
                  roilabels = powerlabelsS;
              elseif contains(files(k).name, 'aal116')
                  roilabels = aallabelsS;
              end
              
              ROI = roilabels.';
              header1 = {'LocalEfficiency','ClusteringCoeffPos','ClusteringCoeffNeg','StrengthPos','StrengthNeg'};
                         
              NBSmatROIslabeled = NBSmatROI;
              NBSmatROIslabeled = array2table(NBSmatROIslabeled,'VariableNames',header1);
              NBSmatROIslabeled = addvars(NBSmatROIslabeled,ROI,'Before','LocalEfficiency');
              tableName = strcat(files(k).name(1:end-4),"_nbs_nodal.txt");
              writetable(NBSmatROIslabeled,tableName);
              
              fclose(fid);
              
    end      
              
end
    



