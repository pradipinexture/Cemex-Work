   $(".add-GMB").on("click", function () {
       resetGMBModal();
   });

    function resetGMBModal() {

       $("#filePublisher").val("");
       $("#fileDescription").val("");

      
       var fileInputtDemo = document.getElementById('GMBfile');
       var labelD = document.querySelector('label[for="fileGMB"]');

       fileInputtDemo.value = '';
       labelD.textContent = 'Image : ';
       
       $("#save-GMB-data").text(saveLabel);
   }

   resetGMBModal();

   var updateGMBId = null;

   function setDataInGMBModal(filePublisher, fileDescription,GMBfileData,update) {
       
       resetGMBModal();
      
       if (filePublisher && filePublisher !== '-') {
           $("#filePublisher").val(filePublisher); 
           $("#filePublisher").parent().addClass("focused");
       }
      
       
       if (fileDescription && fileDescription !== '-') {
           $("#fileDescription").val(fileDescription); 
           $("#fileDescription").parent().addClass("focused");
       }
      

       if (GMBfileData && GMBfileData !== '-') {

            var fileInput = document.getElementById('GMBfile');
            var label = document.querySelector('label[for="fileGMB"]');
            fileInput.value = '';
            label.textContent = 'Image : ' + GMBfileData;
           
       }

       if (update) {
           $("#save-GMB-data").text(updateLabel);
       }
   }

    $(document.body).on("click",".GMB-card-remove", function () {
        var GMBCard = $(this).closest(".col-md-4");
        GMBCard.remove();
        Toast.success("${(GMBCardRemoveMessage?has_content)?then(GMBCardRemoveMessage, 'GMB removed successfully')}");
   });



   $(document.body).on("click",".GMB-card-edit", function () {

       var GMBCard = $(this).closest(".GMB-card");

       var filePublisher = GMBCard.find(".file-Publisher").text().trim();

       var fileDescription = GMBCard.find(".file-Description").text().trim();
       
       var GMBfileData = GMBCard.find(".file-value").text().trim();
       
       var updateId = GMBCard.attr('id');

       GMBupdateIndexId = updateId;

       updateGMBId = updateId;

       setDataInGMBModal(
           filePublisher,
           fileDescription,
           GMBfileData,true
       );
       $("#bs-GMB-modal").addClass("open");
   });



   $("#save-GMB-data").on("click", function (e) {

      var operationType = $("#save-GMB-data").text();
     
      var filePublisher = $("#filePublisher").val() || "-";
     
      var fileDescription = $("#fileDescription").val() || "-";
    
      var labelDemo = document.querySelector('label[for="fileGMB"]');

      var fileNameGMB = labelDemo.textContent.split(' : ')[1].trim();

       if (!filePublisher || !fileDescription || !fileNameGMB) {
           Toast.danger("Please fill in all required fields.");
           return; // Exit the function if any required field is missing
       }
       
      if (operationType === "Save"){
         let GMBDIV = "<div class='col-md-4'>" +
               "<div class='GMB-card' id='GMB-card-id-" + (GMBCardId++) + "'>" +
               "<h2 class='file-Publisher'>" + filePublisher +
               "</h2><br>" +
               "<a class='GMB-card-edit'>" +
               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<a class='GMB-card-remove'>" +
               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
               "</a>" +
               "<h2 class='file-Description'>" + fileDescription +
               "</h2>" +
               "<p class='file-value'>" + fileNameGMB + "</p>" +
               "</div>" +
               "</div>";

        $('#GMB-card-container').append(GMBDIV);
        Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
        $("#bs-GMB-modal").removeClass("open");
       }else {
            if(updateGMBId) {

              var GMBCard = $('#' + updateGMBId);
              $("#"+updateGMBId+" p:last-child").text(fileNameGMB);

               GMBCard.find(".file-Publisher").text(filePublisher);

               GMBCard.find(".file-Description").text(fileDescription);
     
               var fileInput = document.getElementById('GMBfile');
            
               var labelData = document.querySelector('label[for="fileGMB"]');

               fileInput.value = '';
              
               labelData.textContent = 'Image : ' + fileNameGMB; 

               Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
               $("#bs-GMB-modal").removeClass("open");
           } else {
           }
       }
         resetGMBModal();
   });