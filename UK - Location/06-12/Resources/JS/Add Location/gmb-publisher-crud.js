var GMBCardId = 1;
var GMBupdateIndexId;

document.getElementById('GMBfile').addEventListener('change', function() {
    var fileName = this.files[0] ? this.files[0].name : 'Choose a file : ';
    this.previousElementSibling.textContent = fileName;
});

function resetGMBModal() {
    document.getElementById('filePublisher').value = '';
    document.getElementById('fileDescription').value = '';
    
    const fileInput = document.getElementById('GMBfile');
    const label = document.querySelector('label[for="fileGMB"]');
    
    fileInput.value = '';
    label.textContent = chooseFile+' : ';

    document.getElementById('save-GMB-data').textContent = saveLabel;
}

function setDataInGMBModal(filePublisher, fileDescription, GMBfileData, update) {
    resetGMBModal();
    
    if (filePublisher && filePublisher !== '-') {
        const publisherInput = document.getElementById('filePublisher');
        publisherInput.value = filePublisher;
        publisherInput.parentElement.classList.add('focused');
    }
    
    if (fileDescription && fileDescription !== '-') {
        const descriptionInput = document.getElementById('fileDescription');
        descriptionInput.value = fileDescription;
        descriptionInput.parentElement.classList.add('focused');
    }
    
    if (GMBfileData && GMBfileData !== '-') {
        const fileInput = document.getElementById('GMBfile');
        const label = document.querySelector('label[for="fileGMB"]');
        fileInput.value = '';
        label.textContent =  GMBfileData;
    }
    
    if (update) {
        document.getElementById('save-GMB-data').textContent = updateLabel;
    }
}

function apiPublisherErrorStep() {
   Toast.error(fileNotUploadedRenameIt);
   document.getElementById('GMBfile').value = '';
   document.querySelector('label[for="fileGMB"]').textContent = chooseFile+' : ';
}

document.getElementById('save-GMB-data').addEventListener('click', async function(e) {
    const operationType = this.textContent;
    
    const filePublisher = document.getElementById('filePublisher').value || '-';
    const fileDescription = document.getElementById('fileDescription').value || '-';
    const fileGMBLabel = document.getElementById('GMBfile').previousElementSibling.textContent;

    if (!filePublisher || filePublisher == "-" || !fileDescription || fileDescription == "-"  || !fileGMBLabel || fileGMBLabel.includes('Choose a file : ')) {
        Toast.error(fillRequiredField);
        return;
    }

    if (operationType === "Save") {
        const result = await uploadFileToLiferay('GMBfile', documentMediaFolderId);
        if(!result) {
           apiPublisherErrorStep();
           return;
        }

        var GMBDIV = generateGMBDiv(filePublisher, result, fileDescription);

        document.getElementById('GMB-card-container').insertAdjacentHTML('beforeend', GMBDIV);
        Toast.success(tosterMessageSaveSuccess);
        document.getElementById('bs-GMB-modal').classList.remove('open');
    } else {
        if (GMBupdateIndexId) {
            const GMBCard = document.getElementById(GMBupdateIndexId);
            const upFileValue = document.querySelector('#' + GMBupdateIndexId + ' p:last-child');
            const oldFileLabel = upFileValue.textContent;
            upFileValue.textContent = fileGMBLabel;

            if(oldFileLabel.trim() != fileGMBLabel.trim()) {
               const result = await uploadFileToLiferay('GMBfile', documentMediaFolderId, null, true);
               if(!result) {
                  apiErrorStep();
                  return;
               }
               upFileValue.dataset.publisherResponse = JSON.stringify(result);
            }
            
            GMBCard.querySelector('.file-Publisher').textContent = filePublisher;
            GMBCard.querySelector('.file-Description').textContent = fileDescription;

            Toast.success(tosterMessageUpdateSuccess);
            document.getElementById('bs-GMB-modal').classList.remove('open');
        }
    }
    resetGMBModal();
});

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.GMB-card-remove')) {
        const GMBCard = e.target.closest('.col-md-4');
        GMBCard.remove();
        Toast.success(tosterMessageDeletedSuccess);
    }
    
    if (e.target.closest('.GMB-card-edit')) {
        const GMBCard = e.target.closest('.GMB-card');
        const filePublisher = GMBCard.querySelector('.file-Publisher').textContent.trim();
        const fileDescription = GMBCard.querySelector('.file-Description').textContent.trim();
        const GMBfileData = GMBCard.querySelector('.file-value').textContent.trim();
        const updateId = GMBCard.id;

        GMBupdateIndexId = updateId;

        setDataInGMBModal(
            filePublisher,
            fileDescription,
            GMBfileData,
            true
        );
        document.getElementById('bs-GMB-modal').classList.add('open');
    }
});

document.querySelector('.add-GMB').addEventListener('click', resetGMBModal);
