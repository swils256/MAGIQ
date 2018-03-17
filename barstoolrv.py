# ---- System Libraries ---- #
import sys
import os
import datetime
import time
import glob
import platform
import subprocess

from PyQt5 import QtCore, QtGui, QtWidgets, uic
import subprocess as subproc

import multiprocessing as mp

from collections import defaultdict

from itertools import groupby

# ---- Math Libraries ---- #
import scipy as sp
import scipy.signal as spsg

import numpy as np
import math
from pyfftw.interfaces import scipy_fftpack as fftw

# ---- Plotting Libraries ---- #
import matplotlib as mpl;
mpl.use("Qt5Agg")
from matplotlib.backends.backend_qt5agg import (
	FigureCanvasQTAgg as FigureCanvas,
	NavigationToolbar2QT as NavigationToolbar)
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.colors as colors
import matplotlib.gridspec as gridspec

# ---- Image Libraries ---- #
import nibabel as nib
from autozoom import *

# ---- Data Classes ---- #
from dataclasses import *

# ---- Spectroscopy Calculations ---- #
import metabcalcs as mc

# ---- Matlab ---- #
import matlab.engine

qtCreatorFile = "barstoolrv/ui/BARSTOOLRV.ui"
Ui_MainWindow, QtBaseClass = uic.loadUiType(qtCreatorFile)

class MyApp(QtWidgets.QWidget, Ui_MainWindow):
	def __init__(self):
		QtWidgets.QWidget.__init__(self)
		Ui_MainWindow.__init__(self)
		self.setupUi(self)

		# Bind buttons to methods in each tab
		self.setBindings('Sum Amplitudes')
		self.setBindings('Brain Extraction and Segmentation')
		self.setBindings('Set Parameters')

	def tree(self): return defaultdict(self.tree)

	def setBindings(self, tab):
		if tab == 'Sum Amplitudes':
			
			self.setWorkingDirectoryButton.clicked.connect(self.setWorkingDirectory)
			self.setWorkingDirectoryButton.setEnabled(True)

			self.loadOutputsButton.clicked.connect(self.loadOutputs)
			self.loadOutputsButton.setEnabled(False)

			self.confirmIDsButton.clicked.connect(self.confirmIDs)
			self.confirmIDsButton.setEnabled(False)

			self.confirmSaveFileButton.clicked.connect(self.confirmSaveFileName)
			self.confirmSaveFileButton.setEnabled(False)

			self.calculateButton.clicked.connect(self.calculate)
			self.calculateButton.setEnabled(False)

		elif tab == 'Brain Extraction and Segmentation':

			self.FDFIMAGELIST_INDEX = 0

			self.selectFDFImagesButton.clicked.connect(self.loadMouseDirs)
			self.selectFDFImagesButton.setEnabled(False)

			self.fdf2niftiButton.clicked.connect(self.fdf2nifti)
			self.fdf2niftiButton.setEnabled(False)

			self.runVoxAlignButton.clicked.connect(self.runVoxAlign)
			self.runVoxAlignButton.setEnabled(False)

			self.runPCNNButton.clicked.connect(self.runPCNN)
			self.runPCNNButton.setEnabled(False)

			self.runSegButton.clicked.connect(self.runSeg)
			self.runSegButton.setEnabled(False)

		# elif tab == 'Set Parameters':

		# 	self.loadMetabParamsButton.clicked.connect(self.loadMetabParams)
			
		# 	self.saveMetabParamsButton.clicked.connect(self.saveMetabParams)
		# 	self.saveMetabParamsButton.setEnabled(False)

		# 	self.confirmParamsButton.clicked.connect(self.verifyParams)

	# ---- Methods for 'Sum Amplitudes' Tab ---- #
	def setWorkingDirectory(self):

		self.workingDirectory = str(QtWidgets.QFileDialog.getExistingDirectory(self, 'Set Working Directory', os.path.expanduser('~')))
		if self.workingDirectory == '':
			self.workingDirectory = os.path.expanduser('~')

		self.consoleOutputText.append('Working directory set to:')
		self.consoleOutputText.append(' >> ' + str(self.workingDirectory))
		self.consoleOutputText.append('')

		self.setWorkingDirectoryButton.setEnabled(False)
		self.loadOutputsButton.setEnabled(True)
		self.selectFDFImagesButton.setEnabled(True)
		self.loadOutputsButton_quant.setEnabled(True)

	def loadOutputs(self):

		self.consoleOutputText.append('===== CALCULATE AMPLITUDES AND CRLBS =====')

		self.fileList = QtWidgets.QFileDialog.getOpenFileNames(self, 'Open Output File', self.workingDirectory, 'fitMAN Suppressed Output Files (*_sup.out)')[0]
		self.outputs = []

		if len(self.fileList) > 0:
			
			self.consoleOutputText.append('The following output files were loaded:')
			for (i, file) in enumerate(self.fileList):
				self.fileList[i] = str(file)
				self.consoleOutputText.append(' >> ' + str(file))
				self.studyIDsTextEdit.appendPlainText(str(file).replace('.out','').split('/')[-1])
			self.consoleOutputText.append('')

			self.loadOutputsButton.setEnabled(False)
			self.confirmIDsButton.setEnabled(True)

		else:
			
			self.consoleOutputText.append('No output files selected ... try again.')
			self.consoleOutputText.append('')
			self.loadOutputsButton.setEnabled(True)

	def confirmIDs(self):

		self.IDsList = self.studyIDsTextEdit.toPlainText().split('\n')
		for (i, ID) in enumerate(self.IDsList):
			self.IDsList[i] = str(ID)

		if len(self.IDsList) != len(self.fileList):
			self.consoleOutputText.append('Number of study IDs do not equal number of files ... specify the IDs again.')
			self.consoleOutputText.append('')
		else:
			self.consoleOutputText.append('The following IDs were selected:')
			self.consoleOutputText.append(' >> ' + str(self.IDsList))
			self.consoleOutputText.append('')
			self.confirmIDsButton.setEnabled(False)
			self.confirmSaveFileButton.setEnabled(True)
			self.saveFileLineEdit.setText(self.workingDirectory + '/' + '_____.csv')

	def confirmSaveFileName(self):
		self.saveFileName = self.saveFileLineEdit.text()
		self.calculateButton.setEnabled(True)
		self.consoleOutputText.append('Calculations will be saved to: ' + str(self.saveFileName))
		self.consoleOutputText.append('')

	def calculate(self):
		saveFile = open(self.saveFileName, 'w')
		for (i, file) in enumerate(self.fileList):

			# Load output file
			self.outputs.append(OutputFile(file))

			# Get metabolite list from output file
			ID = self.IDsList[i]
			metabs = self.outputs[i].metabolites_list

			# For each metabolite calculate sum amps
			amps = []
			for metab in metabs: amps.append(self.outputs[i].metabolites[metab].sumAmp())

			# For each metabolite calculate crlbs
			crlbs = []
			for metab in metabs: 
				print metab, np.mean(self.outputs[i].metabolites[metab].crlb)
				crlbs.append(np.mean(self.outputs[i].metabolites[metab].crlb))

			# Write heading to file if we're at the first line
			if i == 0:
				saveFile.write('ID,')
				print 'ID',
				for metab in metabs: 
					saveFile.write(str(self.outputs[i].metabolites[metab].name)+',')
					print self.outputs[i].metabolites[metab].name,
				for metab in metabs: 
					saveFile.write(str(self.outputs[i].metabolites[metab].name)+',')
					print self.outputs[i].metabolites[metab].name,
				saveFile.write('\n')
				print ''

			# Write ID and amplitudes to file
			saveFile.write(ID+',')
			saveFile.write(str(amps).replace(' ', '').replace('[', '').replace(']',''))
			saveFile.write(',')
			saveFile.write(str(crlbs).replace(' ', '').replace('[', '').replace(']',''))
			print ID, str(amps).replace(' ', '').replace('[', '').replace(']','')
			print ID, str(crlbs).replace(' ', '').replace('[', '').replace(']','')
			saveFile.write('\n')
			print ''

		saveFile.close()

		# Reset interface
		self.setWorkingDirectoryButton.setEnabled(True)
		self.loadOutputsButton.setEnabled(True)
		self.confirmIDsButton.setEnabled(False)
		self.confirmSaveFileButton.setEnabled(False)
		self.calculateButton.setEnabled(False)

		self.studyIDsTextEdit.clear()
		self.saveFileLineEdit.clear()

	# ---- Methods for 'Brain Extraction' Tab ---- #
	def loadMouseDirs(self):
		
		self.consoleOutputText.append('===== BRAIN EXTRACTION =====')

		file_dialog = QtWidgets.QFileDialog(directory=self.workingDirectory, filter='Image Files (*.img)')
		file_dialog.setFileMode(QtWidgets.QFileDialog.DirectoryOnly)
		file_dialog.setOption(QtWidgets.QFileDialog.DontUseNativeDialog, True)
		file_view = file_dialog.findChild(QtWidgets.QListView, 'listView')

		# to make it possible to select multiple directories:
		if file_view:
			file_view.setSelectionMode(QtWidgets.QAbstractItemView.MultiSelection)
		f_tree_view = file_dialog.findChild(QtWidgets.QTreeView)
		
		if f_tree_view:
			f_tree_view.setSelectionMode(QtWidgets.QAbstractItemView.MultiSelection)

		if file_dialog.exec_():
			paths = file_dialog.selectedFiles()

			self.mouseDirs = paths #QtWidgets.QFileDialog.getOpenFileNames(self, 'Open FDF Image File', self.workingDirectory, 'Image Files (*.img)')[0]
		
			self.consoleOutputText.append('The following image files were loaded:')
			for (i, mouse) in enumerate(self.mouseDirs):
				self.mouseDirs[i] = str(mouse)
				self.consoleOutputText.append(' >> ' + str(mouse))
			self.consoleOutputText.append('')

			self.selectFDFImagesButton.setEnabled(False)
			self.fdf2niftiButton.setEnabled(True)

		else:
			
			self.consoleOutputText.append('No image files selected ... try again.')
			self.consoleOutputText.append('')

			self.selectFDFImagesButton.setEnabled(True)

	def fdf2nifti(self):

		self.consoleOutputText.append('===== fdf2nifti =====')
		self.fdf_imgs = []
		for mouse in self.mouseDirs:
			fdf_img   = FDF2D(mouse + '/fse2D.img', (int(self.matXLineEdit.text()), int(self.matYLineEdit.text()), int(self.matZLineEdit.text())))
			self.fdf_imgs.append(fdf_img)
			nifti_img = nib.Nifti1Image(fdf_img.fseimg, fdf_img.affine)
			nifti_img.to_filename(mouse + '/fse2d.nii.gz')
			self.consoleOutputText.append(' >> ' + str(mouse))
		self.consoleOutputText.append('')

		self.fdf2niftiButton.setEnabled(False)
		self.runVoxAlignButton.setEnabled(True)

	def runVoxAlign(self):
		self.consoleOutputText.append('===== alignvoxel_varian =====')
		for i, mouse in enumerate(self.mouseDirs):
			fdf_img = self.fdf_imgs[i]
			try:
				voxel = VarianVoxel(mouse + '/sup.fid', fdf_img.size, fdf_img.X_VARIAN, fdf_img.Y_VARIAN, fdf_img.Z_VARIAN, fdf_img.fseimg_ijk, fdf_img.fseimg_xyz_kdt)
				print 'Loading ', mouse + '/sup.fid ...'
			except Exception as e:
				voxel = VarianVoxel(mouse + '/unsup.fid', fdf_img.size, fdf_img.X_VARIAN, fdf_img.Y_VARIAN, fdf_img.Z_VARIAN, fdf_img.fseimg_ijk, fdf_img.fseimg_xyz_kdt)
				print 'Loading ', mouse + '/unsup.fid ...'
			nifti_img = nib.Nifti1Image(voxel.voximg, fdf_img.affine)
			nifti_img.to_filename(mouse + '/mrsvoxel.nii.gz')
			self.consoleOutputText.append(' >> ' + str(mouse))
		print ''
		self.consoleOutputText.append('')

		self.runVoxAlignButton.setEnabled(False)
		self.runPCNNButton.setEnabled(True)

	def runPCNN(self):
		self.consoleOutputText.append('==== PCNN 3D ====')
		
		# Start Matlab Engine
		print 'Starting Matlab Engine ...'
		cwd = os.popen('pwd').read().split('\n')[0]
		eng = matlab.engine.start_matlab()
		eng.cd(cwd + '/barstoolrv')
		matlab_wd = eng.pwd(); print matlab_wd

		failed_mice = []
		successful_mice = []
		
		for i, mouse in enumerate(self.mouseDirs):
			self.consoleOutputText.append(' >> ' + str(mouse))

			print 'Processing ', mouse, '...'
			fse2d_nifti = mouse + '/fse2d.nii.gz'
			fse2d_mask  = mouse + '/fse2d_mask.nii.gz'
			fse2d_brain = mouse + '/fse2d_brain.nii.gz'

			try:
				eng.runPCNN3D(fse2d_nifti, nargout=0)
				self.consoleOutputText.append('    runPCNN3D(' + str(mouse) + ')')

				eng.clear('all', nargout=0)
				eng.close('all', nargout=0)

				command = ['fslmaths', fse2d_nifti]
				command.append('-mas ' + fse2d_mask)
				command.append(fse2d_brain)
				print str(command).replace('[','').replace(']','').replace(',','').replace("'", '')
				os.system(str(command).replace('[','').replace(']','').replace(',','').replace("'", ''))
				self.consoleOutputText.append('    ' + str(command).replace('[','').replace(']','').replace(',','').replace("'", ''))

				successful_mice.append(mouse)
			except Exception as e:
				print e
				failed_mice.append(mouse)

		print ''
		self.consoleOutputText.append('')
		self.consoleOutputText.append('The following files could not be processed successfully:')
		for mouse in failed_mice:
			self.consoleOutputText.append(' >> ' + str(mouse))
		self.consoleOutputText.append('')

		# Stop Matlab Engine
		print 'Stopping Matlab Engine ...'
		eng.quit()

		self.runPCNNButton.setEnabled(False)
		self.runSegButton.setEnabled(True)
		self.mouseDirs = successful_mice # remove files that could not be processed successfully

	def runSeg(self):
		self.consoleOutputText.append('==== CSF EXTRACT ====')
		for i, mouse in enumerate(self.mouseDirs):
			self.consoleOutputText.append(' >> ' + str(mouse))
			print 'Processing ', mouse, '...'

			brain = nib.load(mouse + '/fse2d_brain.nii.gz')
			mask  = nib.load(mouse + '/fse2d_mask.nii.gz')

			brain_img = brain.get_data()
			mask_img  = mask.get_data()

			brain_img_vec = np.reshape(brain_img, np.size(brain_img)).astype(int)
			mask_img_vec  = np.reshape(mask_img,  np.size(mask_img )).astype(int)

			brain_img_vec_masked = brain_img_vec[mask_img_vec.astype(bool)]
			brain_kde = sp.stats.gaussian_kde(brain_img_vec_masked)

			for i, elem in enumerate(sp.linspace(np.min(brain_img_vec), np.max(brain_img_vec), 1000)):
				if brain_kde.integrate_box_1d(np.min(brain_img_vec), elem) > float(self.csfThreshLineEdit.text()):
					print '  | ', i, elem
					csf_thresh = elem
					break

			plt.figure()
			plt.plot(sp.linspace(np.min(brain_img_vec), np.max(brain_img_vec), 1000), brain_kde(sp.linspace(np.min(brain_img_vec), np.max(brain_img_vec), 1000)))
			plt.plot(csf_thresh, brain_kde(csf_thresh), '.')
			plt.title('Gaussian Kernel Density Estimate of PDF')
			plt.xlim(0, np.max(brain_img_vec))
			plt.xlabel('Image Intensity')
			plt.ylabel('Probability')
			plt.legend(['PDF', 'Threshold: '+str(int(csf_thresh))])
			plt.savefig(mouse + '/fse2d_brain_gkde.pdf')

			brain_csf_mask = brain_img >= int(csf_thresh)
			brain_csf_mask = brain_csf_mask.astype(int)
			brain_csf_mask_file = nib.Nifti1Image(brain_csf_mask, brain.get_qform())
			brain_csf_mask_file.to_filename(mouse + '/fse2d_csf_mask.nii.gz')

		print ''
		self.runSegButton.setEnabled(False)
		self.selectFDFImagesButton.setEnabled(True)

# ---- Launch Application ---- #
if __name__ == "__main__":
	app = QtWidgets.QApplication(sys.argv)
	window = MyApp()
	window.show()
	sys.exit(app.exec_())