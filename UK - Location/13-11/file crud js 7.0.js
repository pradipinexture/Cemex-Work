
   $(".add-file").on("click", function () {
       resetFileModal();
   });

    function resetFileModal() {

       $("#filename").val("");
         
       var fileInputt = document.getElementById('file');
       var label = document.querySelector('label[for="file"]');

       fileInputt.value = '';
       label.textContent = 'File : ';

       $("#save-file").text(saveLabel);
   }
   resetFileModal();

   var updateFileId = null;
   function setDataInFileModal(name, value, update) {
       resetFileModal();
      
       if (name && name !== '-') {
           $("#filename").val(name); 
           $("#filename").parent().addClass("move-form-label");
       }
      
       if (value && value !== '-') {
            var fileInput = document.getElementById('file');
            var label = document.querySelector('label[for="file"]');

            fileInput.value = '';
            label.textContent = 'File : ' + value;
       }
       if (update) {
           $("#save-file").text(updateLabel);
       }
   }


    $(document.body).on("click",".file-card-remove", function () {
        var fileCard = $(this).closest(".col-md-4");
        var fileValue = fileCard.find(".file-value").text().trim();
        console.log(fileValue);
        fileCard.remove();
        Toast.success("${(fileCardRemoveMessage?has_content)?then(fileCardRemoveMessage, 'File card removed successfully')}");
   });


   $(document.body).on("click",
   ".file-card-edit", function () {

       var fileCard = $(this).closest(".file-card");

       var fileName = fileCard.find(".file-name").text().trim();

       var fileValue = fileCard.find(".file-value").text().trim();

       var updateId = fileCard.attr('id');

       updateIndexId = updateId;

       updateFileId = updateId;

       setDataInFileModal(
           fileName,
           fileValue,true
       );

       $("#bs-file-modal").addClass("open");
   });

   $("#save-file").on("click", function (e) {

       var operationType = $("#save-file").text();
     
       var fileName = $("#filename").val() || "-";

       var fileValue = $("#filevalue").val() || "-";

       var label = document.querySelector('label[for="file"]');

      var fileNameData = label.textContent.split(' : ')[1].trim();
      
      
       // Null check for required fields
       if (!fileName || !fileValue || !fileNameData) {
           Toast.danger("Please fill in all required fields.");
           return; // Exit the function if any required field is missing
       }

       if (operationType === "Save") {
           let fileDiv = "<div class='col-md-4'>" +
               "<div class='file-card' id='file-card-id-" + (fileCardId++) + "'>" +
               "<h2 class='file-name'>" + fileName +
               "</h2>" +
               "<a class='file-card-edit'>" +
               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<a class='file-card-remove'>" +
               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<p class='file-value'>" + fileNameData + "</p>" +
               "</div>" +
               "</div>";
           $('#file-card-container').append(fileDiv);
           Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
           $("#bs-file-modal").removeClass("open");
       } else {
            if(updateFileId) {
              var fileCard = $('#' + updateFileId);
             
               
               $("#"+updateFileId+" p:last-child").text(fileNameData);

               fileCard.find(".file-name").text(fileName);

               var fileInput = document.getElementById('file');
               var label = document.querySelector('label[for="file"]');

               fileInput.value = '';
               label.textContent = 'File : ' + fileNameData; 

               Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
              $("#bs-file-modal").removeClass("open");
           } else {
           }
       }
       resetFileModal();
   });


      var resultList = [];
   document.getElementById('save-file').addEventListener('click', function(event) {
       
       uploadFile(function(error, response) {
          if (error) {
              console.error('Error:', error);
           } else {
              if(articleIdFromUrl != null) {        
               if(updateIndexId === null){
                  fileValues.push(response);
               }   
               
               var idNumber = null;
               if (updateIndexId) {
                   var idParts = updateIndexId.split('-');
                   if (idParts.length >= 4) {
                    idNumber = idParts[3];
                   }
               }
                   
               var itemToUpdate = fileValues.find(item => item.id == idNumber);  
               if (itemToUpdate) {
                   itemToUpdate.groupId = response.groupId;
                   itemToUpdate.folderId = response.folderId;
                   itemToUpdate.fileName = response.fileName;
                   itemToUpdate.uuid = response.uuid;
                   itemToUpdate.modifiedDate = response.modifiedDate;
                   updateIndexId = null;
                   }
               }else{
                   resultList.push(response);
               }
           }
       });
   });


   function uploadFile(callback, retry = false, newFileName = null) {
       var fileInput = document.getElementById('file');
       var file = fileInput.files[0];

       if (file) {
           var formData = new FormData();
           formData.append('repositoryId', themeDisplay.getScopeGroupId());
           formData.append('folderId', documentMediaFolderId);
           formData.append('sourceFileName', newFileName ? newFileName : file.name);
           formData.append('mimeType', file.type);
           formData.append('title', newFileName ? newFileName : file.name);
           formData.append('description', '');
           formData.append('changeLog', '');
           formData.append('file', file);

           var xhr = new XMLHttpRequest();
           xhr.open('POST', '/api/jsonws/dlapp/add-file-entry', true);
           xhr.setRequestHeader('Authorization', 'Basic bWFub2ouZ29oZWxAZXh0LmNlbWV4LmNvbTpDZW1leDEyMzQ1Ng==');

           xhr.onreadystatechange = function () {
               if (xhr.readyState === 4) {
                   if (xhr.status === 200) {
                       var uploadedFile = JSON.parse(xhr.responseText);
                       $("#file-error").text('');
                       callback(null, uploadedFile);
                   } else if (xhr.status === 500 && !retry) {
                       retryUploadFile(callback, file);
                   } else {
                       console.error('Error uploading file:', xhr.status, xhr.statusText);
                       callback('Error uploading file', null);
                   }
               }
           };
           xhr.send(formData);
       } else {
           Toast.danger("${(FileRequireValidation?has_content)?then(FileRequireValidation, 'Please select a file.')}");
           callback('No file selected', null);
       }
   }