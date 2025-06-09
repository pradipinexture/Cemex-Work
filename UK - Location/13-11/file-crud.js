var fileCardId = 1; 
var updateFileId;

document.getElementById('save-file').addEventListener('click', async function (e) {
    var operationType = document.getElementById('save-file').textContent;
    
    var fileName = document.getElementById('filename').value || "-";
    var fileLabel = document.getElementById('file').previousElementSibling.textContent;

    if (!fileName || !fileLabel || fileLabel.includes("Choose a file:")) {
        console.log("Please fill in all required fields.");
        return;
    }

    if (operationType === "Save") {
      const result = await uploadFileToLiferay('file', documentMediaFolderId);
      if(!result) {
         apiErrorStep();
         return;
      }


        var fileDiv = "<div class='col-md-4'>" +
            "<div class='file-card' id='file-card-id-" + (fileCardId++) + "'>" +
            "<h2 class='file-name'>" + fileName +
            "</h2>" +
            "<a class='file-card-edit'>" +
            "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<a class='file-card-remove'>" +
            "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<p class='file-value' data-file-response='"+JSON.stringify(result)+"'>" + fileLabel + "</p>" +
            "</div>" +
            "</div>";

        document.getElementById('file-card-container').insertAdjacentHTML('beforeend', fileDiv);
        console.log(tosterMessageSaveSuccess);
        document.getElementById('bs-file-modal').classList.remove('open');
    } else {
        if(updateFileId) {
            var fileCard = document.getElementById(updateFileId);
            var upFileValue = document.querySelector('#' + updateFileId + ' p:last-child');
            var oldFileLabel = upFileValue.textContent;
            upFileValue.textContent = fileLabel;

            if(oldFileLabel.trim() != fileLabel.trim()) {
               const result = await uploadFileToLiferay('file', documentMediaFolderId);
               if(!result) {
                  apiErrorStep();
                  return;
               }
               upFileValue.dataset.fileResponse = JSON.stringify(result);
            }

            fileCard.querySelector('.file-name').textContent = fileName;

            console.log(tosterMessageUpdateSuccess);
            document.getElementById('bs-file-modal').classList.remove('open');
        }
    }
    resetFileModal();
});

function apiErrorStep() {
   console.log("File has not uploaded. Please try again by renaming the file.");
   document.getElementById('file').value = '';
   document.querySelector('label[for="file"]').textContent = 'Choose a file : ';
}

document.getElementById('file').addEventListener('change', function () {
    var fileName = this.files[0] ? this.files[0].name : 'Choose a file:';
    this.previousElementSibling.textContent = fileName;
});

function resetFileModal() {
    document.getElementById('filename').value = '';
    
    const fileInput = document.getElementById('file');
    const label = document.querySelector('label[for="file"]');
    
    fileInput.value = '';
    label.textContent = 'Choose a file : ';
    
    document.getElementById('save-file').textContent = saveLabel; // Assuming saveLabel is defined
}

function setDataInFileModal(name, value, update) {
    resetFileModal();
    
    if (name && name !== '-') {
        const filenameInput = document.getElementById('filename');
        filenameInput.value = name;
        filenameInput.parentElement.classList.add('move-form-label');
    }
    
    if (value && value !== '-') {
        const fileInput = document.getElementById('file');
        const label = document.querySelector('label[for="file"]');
        
        fileInput.value = '';
        label.textContent = '' + value;
    }
    
    if (update) {
        document.getElementById('save-file').textContent = updateLabel;
    }
}

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.file-card-edit')) {
        const fileCard = e.target.closest('.file-card');
        const fileName = fileCard.querySelector('.file-name').textContent.trim();
        const fileValue = fileCard.querySelector('.file-value').textContent.trim();
        const updateId = fileCard.id;

        updateFileId = updateId;
        
        setDataInFileModal(fileName, fileValue, true);
        
        document.getElementById('bs-file-modal').classList.add('open');
    }
});

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.file-card-remove')) {
        const fileCard = e.target.closest('.col-md-4');
        const fileValue = fileCard.querySelector('.file-value').textContent.trim();
        
        fileCard.remove();
        console.log(tosterMessageDeletedSuccess);
    }
});

document.querySelector('.add-file').addEventListener('click', resetFileModal);