
   <!-------------------Contact Cards------------------->
    $(".add-contact").on("click", function () {
         resetContactModel();
         modelOpeningSave()
   });

    function resetContactModel() {
        $("#contactname").val("");
        $("#emailaddress").val("");
        $("#phonenumbermodal").val("");
        $("#job-position").val("")
        $("#save-contact").text("Save");
   }

    resetContactModel();
    
    function setDataInContactModel(name, email, phone, job, update, updateId) {
        resetContactModel();
    
        if(name && name != '-') {
           $("#contactname").val(name); 
           $("#contactname").parent().addClass("focused");
       }
        if (email && email != '-') {
           $("#emailaddress").val(email); 
           $("#emailaddress").parent().addClass("focused");
       }

        if (job && job != '-') {
           $("#job-position").val(job); 
           $("#job-position").parent().addClass("focused");
       }
        
        $("#phonenumbermodal").val(phone);
        if (update) {
            $("#save-contact").text(updateLabel);
            $(".update-id").val(updateId);
       }
   }

    $(document.body).on("click",
   ".contact-card-remove", function () {
        var contactCard = $(this).closest(".col-md-4");
        contactCard.remove();
        Toast.success("${(contactCardRemoveMessage?has_content)?then(contactCardRemoveMessage, 'Contact removed successfully')}");
   });

    $(document.body).on("click",".card-edit", function () {
        var contactCard = $(this).closest(".contact-card");
        var contactname = contactCard
            .find(".contact-name")
            .contents()
            .filter(function () {
                return this.nodeType === Node.TEXT_NODE;
       }).text().trim();

        var contactjob = contactCard.find(".contact-job").text().trim();
        var contactemail = contactCard.find(".contact-email a").text().trim();
        var contactphone = contactCard.find(".contact-phone").text().trim();
        var updateId = contactCard.attr('id');

        setDataInContactModel(
            contactname,
            contactemail,
            contactphone,
            contactjob,
       true,
            updateId
        );
        $("#bs-contact-modal").addClass("open");
   });

    $("#save-contact").on("click", function (e) {
    
       var operationType = $("#save-contact").text();

        var contactName = $("#contactname").val() || "-";
        var jobPosition = $("#job-position").val() || "-";
        var emailAddress = $("#emailaddress").val() || "-";
        var phoneNumber = $("#phonenumbermodal").val();

        var phoneInputtt = initializeIntlTelInput(preferredCountries, countryCodeValueModal, 'phonenumbermodal',"phonenumbermodal-error");

       if (phoneNumber === '' || !validatePhoneNumber(phoneInputtt,"phonenumbermodal-error") && validateEmailAddress(emailAddress)) {
            Toast.danger("${(allValidationMessage?has_content)?then(allValidationMessage, 'All fields must be filled out with valid data in the contact form')}");
            return;
       }
   	
        if (operationType === "Save") {
            let contactDiv = "<div class='col-md-4'>" +
                "<div class='contact-card' id='contact-card-id-" + (contactCardId++) + "'>" +
                "<h2 class='contact-name'>" + contactName +
                "</h2>" +
                "<a class='card-edit'>" +
                "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
                "</a>" +
                "<a class='contact-card-remove'>" +
                "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
                "</a>" +
                "<p class='contact-job'>" + jobPosition + "</p>" +
                "<p class='contact-email'><a href='mailto:" + emailAddress + "'>" + emailAddress + "</a></p>" +
                "<p class='contact-phone'>" + phoneNumber + "</p>" +
                "</div>" +
                "</div>";
            $('#contact-card-container').append(contactDiv);
            Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
          $("#bs-contact-modal").removeClass("open");
       } else {
            var contactCard = $('#' + $(".update-id").val());
            contactCard.find(".contact-name").text(contactName);
            contactCard.find(".contact-job").text(jobPosition);
            contactCard.find(".contact-email a").text(emailAddress);
            contactCard.find(".contact-phone").text(phoneNumber);
            Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
            $("#bs-contact-modal").removeClass("open");
       }
        resetContactModel();
   });
