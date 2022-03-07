% 'dcm_init_info' is a function from the package: 'DICOM Toolbox'
%
%  -- dcm_info = dcm_init_info ()
%      TODO: Put function description here

function dcm_info = dcm_init_info()

    % Load DICOM package
    pkg load dicom;

    dcm_info.PatientName = 'Doe^John';
    dcm_info.PatientID = '123456';
    dcm_info.PatientSex = 'M';
    dcm_info.StudyInstanceUID = dicomuid();
    dcm_info.FrameOfReferenceUID = dicomuid();
    dcm_info.SeriesInstanceUID = dicomuid();
    dcm_info.MediaStorageSOPInstanceUID = dicomuid();

    dcm_info.StudyID = NaN;
    dcm_info.StudyDescription = NaN;
    dcm_info.SeriesNumber = NaN;
    dcm_info.MediaStorageSOPClassUID = NaN;
    dcm_info.TransferSyntaxUID = NaN;
    dcm_info.SOPClassUID = NaN;
    dcm_info.Modality = NaN;
    dcm_info.BitsStored = NaN;
    dcm_info.BitsAllocated = NaN;
    dcm_info.HighBit = NaN;
    dcm_info.SamplesPerPixel = NaN;
    dcm_info.Rows = NaN;
    dcm_info.Columns = NaN;
    dcm_info.InstanceNumber = NaN;
    dcm_info.ImagePositionPatient = NaN;
    dcm_info.ImageOrientationPatient = NaN;
    dcm_info.ImageType = NaN;
    dcm_info.PixelSpacing = NaN;
    dcm_info.PhotometricInterpretation = NaN;
    dcm_info.PixelRepresentation = NaN;
    dcm_info.WindowCenter = NaN;
    dcm_info.WindowWidth = NaN;

endfunction;
