out_b0 = '9.4'

insysfiles = [  'alanine.sys',
			    'aspartate.sys',
			    'choline_1-CH2_2-CH2.sys',
			    'choline_N(CH3)3_a.sys',
			    'choline_N(CH3)3_b.sys',
			    'creatine_N(CH3).sys',
			    'creatine_X.sys',
			    'd-glucose-alpha.sys',
			    'd-glucose-beta.sys',
			    'gaba.sys',
			    'glutamate.sys',
			    'glutamine.sys',
			    'glutathione_cysteine.sys',
			    'glutathione_glutamate.sys',
			    'glutathione_glycine.sys',
			    'glycine.sys',
			    'gpc_7-CH2_8-CH2.sys',
			    'gpc_glycerol.sys',
			    'gpc_N(CH3)3_a.sys',
			    'gpc_N(CH3)3_b.sys',
			    'lactate.sys',
			    'myoinositol.sys',
			    'naa_acetyl.sys',
			    'naa_aspartate.sys',
			    'naag_acetyl.sys',
			    'naag_aspartyl.sys',
			    'naag_glutamate.sys',
			    'pcho_N(CH3)3_a.sys',
			    'pcho_N(CH3)3_b.sys',
			    'pcho_X.sys',
			    'pcr_N(CH3).sys',
			    'pcr_X.sys',
			    'peth.sys',
			    'scyllo-inositol.sys',
			    'taurine.sys' ]

for sysfile in insysfiles:
	filename = '7T_' + sysfile
	file     = open(filename, 'r')
	outfilename  = out_b0 + 'T_' + sysfile
	outfile      = open(outfilename, 'w')
	print filename, outfilename
	for line in file:
		if 'Omega' in line:
			outfile.write('Omega  (1) : 400.2\n')
		else:
			outfile.write(line)
	file.close()
	outfile.close()