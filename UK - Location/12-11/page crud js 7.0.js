   <!-- page logic -->
   $(".add-page").on("click", function () {
       resetPageModal();
   });

    function resetPageModal() {
       $("#pagename").val("");
       $("#fileUrl").val("");
       $("#save-page").text(saveLabel);
   }


   resetPageModal();
   var updatePageId = null;
   function setDataInPageModal(name, value, update) {

       resetPageModal();
       if (name && name !== '-') {
           $("#pagename").val(name); 
           $("#pagename").parent().addClass("move-form-label");
       }
    
       if (value && value !== '-') {
           $("#fileUrl").val(value); 
           $("#fileUrl").parent().addClass("move-form-label");
       }

       if (update) {
           $("#save-page").text(updateLabel);
       }
   }



    $(document.body).on("click",".page-card-remove", function () {
        var pageCard = $(this).closest(".col-md-4");
        pageCard.remove();
        Toast.success("${(pageCardRemoveMessage?has_content)?then(pageCardRemoveMessage, 'Data removed successfully')}");
   });

   $(document.body).on("click",
   ".page-card-edit", function () {

       var pageCard = $(this).closest(".page-card");

       var pageName = pageCard.find(".page-name").text().trim();

       var pageValue = pageCard.find(".page-url").text().trim();

       var updateIdd = pageCard.attr('id');

       updatePageId = updateIdd;
       
       setDataInPageModal(
           pageName,
           pageValue,true
       );

       $("#bs-page-modal").addClass("open");
   });


   $("#save-page").on("click", function (e) {
       
       e.preventDefault(); 
        var operationType = $("#save-page").text();

       var pagename = $("#pagename").val() || "-";
       var fileUrl = $("#fileUrl").val() || "-";
       
       if (!pagename || !fileUrl) {
           Toast.danger("Please fill in all required fields.");
           return; // Exit the function if any required field is missing
       }
      
       if (operationType === "Save") {

       var pageCard = "<div class='col-md-4'>" +
                          "<div class='page-card' id='page-card-id-" + (pageCardId++) + "'>" +
                              "<h2 class='page-name'>" + pagename + "</h2>" +
                              "<a class='page-card-edit'>" +
                               "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
                               "</a>" +
                               "<a class='page-card-remove'>" +
                               "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
                               "</a>" +
                              "<p class='page-url'>" + fileUrl + "</p>" +
                          "</div>" +
                      "</div>";

       $('#page-card-container').append(pageCard);
       Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
       $("#bs-page-modal").removeClass("open");
       }else {
            if(updatePageId) {
              var pageCard = $('#' + updatePageId);   
              pageCard.find(".page-name").text(pagename);
              pageCard.find(".page-url").text(fileUrl);
              Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
              $("#bs-page-modal").removeClass("open");
           } else {
           }
       }
      resetPageModal();
   }); 