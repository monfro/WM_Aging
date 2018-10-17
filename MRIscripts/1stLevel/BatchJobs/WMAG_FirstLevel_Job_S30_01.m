%-----------------------------------------------------------------------
% Job saved on 09-Oct-2018 15:14:43 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_analysis/1stLevel'};
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = '3017030.06_TYR_S3001';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.dir = {'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_data/fMRI/3017030.06_TYR_S3001/func_WMAG/PAID_data'};
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.filter = 'swaM*';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPListRec';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'Onsets';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_analysis/Onsets/OnsetFiles/NamOnsDur_s30_session_1.mat'}};
matlabbatch{4}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'RealignmentParms';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
                                                                     {'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_data/fMRI/3017030.06_TYR_S3001/func_WMAG/PAID_data/rp_3017030.06_TYR_S3001_31_onwards.txt'}
                                                                     {'/home/control/monfro/B_PhD/Tyro_Old/WMAG/WMAG_data/fMRI/3017030.06_TYR_S3001/func_WMAG/PAID_data/rp_3017030.06_TYR_S3001_31_onwards_deriv1.mat'}
                                                                     }';
matlabbatch{5}.spm.stats.fmri_spec.dir(1) = cfg_dep('Make Directory: Make Directory ''<UNDEFINED>''', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dir'));
matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{5}.spm.stats.fmri_spec.timing.RT = 2.07;
matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{5}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{5}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('File Selector (Batch Mode): Selected Files (swaM*)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{5}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{5}.spm.stats.fmri_spec.sess.multi(1) = cfg_dep('Named File Selector: Onsets(1) - Files', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{5}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep('Named File Selector: RealignmentParms(1) - Files', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg(2) = cfg_dep('Named File Selector: RealignmentParms(2) - Files', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{2}));
matlabbatch{5}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{5}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{5}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{5}.spm.stats.fmri_spec.volt = 1;
matlabbatch{5}.spm.stats.fmri_spec.global = 'None';
matlabbatch{5}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{5}.spm.stats.fmri_spec.mask = {''};
matlabbatch{5}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{6}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{6}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{6}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{7}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{7}.spm.stats.con.consess{1}.fcon.name = 'eye';
%%
matlabbatch{7}.spm.stats.con.consess{1}.fcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 0
                                                        0 1 0 0 0 0 0 0 0 0 0 0 0
                                                        0 0 1 0 0 0 0 0 0 0 0 0 0
                                                        0 0 0 1 0 0 0 0 0 0 0 0 0
                                                        0 0 0 0 1 0 0 0 0 0 0 0 0
                                                        0 0 0 0 0 1 0 0 0 0 0 0 0
                                                        0 0 0 0 0 0 1 0 0 0 0 0 0
                                                        0 0 0 0 0 0 0 1 0 0 0 0 0
                                                        0 0 0 0 0 0 0 0 1 0 0 0 0
                                                        0 0 0 0 0 0 0 0 0 1 0 0 0
                                                        0 0 0 0 0 0 0 0 0 0 1 0 0
                                                        0 0 0 0 0 0 0 0 0 0 0 1 0
                                                        0 0 0 0 0 0 0 0 0 0 0 0 1];
%%
matlabbatch{7}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{2}.tcon.name = 'IG > NX';
matlabbatch{7}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1];
matlabbatch{7}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{3}.tcon.name = 'UP > NX';
matlabbatch{7}.spm.stats.con.consess{3}.tcon.weights = [0 0 -1 1];
matlabbatch{7}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{4}.tcon.name = 'IG > UP';
matlabbatch{7}.spm.stats.con.consess{4}.tcon.weights = [0 1 0 -1];
matlabbatch{7}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{5}.tcon.name = 'UP > IG';
matlabbatch{7}.spm.stats.con.consess{5}.tcon.weights = [0 -1 0 1];
matlabbatch{7}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{6}.tcon.name = 'IG';
matlabbatch{7}.spm.stats.con.consess{6}.tcon.weights = [0 1];
matlabbatch{7}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{7}.tcon.name = 'UP';
matlabbatch{7}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 1];
matlabbatch{7}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.consess{8}.tcon.name = 'Motor';
matlabbatch{7}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{7}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{7}.spm.stats.con.delete = 0;
