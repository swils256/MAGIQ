function runPCNN3D(datpath)
    BrSize=[350,550]; % brain size range for mouse (mm3). If you use 10x data, this should be 10x too
    %BrSize=[1200,4400]; % brain size range for RAT (mm3)
    StrucRadius=5; % use =3 for low resolution

    %% run PCNN
    [nii] = load_untouch_nii(datpath);
    mtx=size(nii.img);
    voxdim=nii.hdr.dime.pixdim(2:4);
    [I_border, ~, optG] = PCNN3D(nii.img, StrucRadius, voxdim, BrSize);
    V=zeros(mtx);
    for n=1:mtx(3)
        V(:,:,n)=I_border{optG}{n};
    end

    %% save data
    disp(['Saving mask at ',datpath(1:end-7),'_mask.nii.gz....'])
    nii.img=V;
    save_untouch_nii(nii,[datpath(1:end-7),'_mask.nii.gz'])
end
