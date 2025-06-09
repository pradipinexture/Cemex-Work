    $(document).ready(function() {
      $('#locationForm').submit(function() {
        if(!genericValidations()) {
           Toast.danger("${(ValidateAllFields?has_content)?then(ValidateAllFields, 'Please fill required and valid information in this form')}");
            return false;
       }
       const urlParams = new URLSearchParams(window.location.search);
       const articleIdFromUrl = urlParams.get('articleId');

       $("#save").prop('disabled', true).text( ((articleIdFromUrl) ? "Updating" : "Saving")+ " Location...");

       var locationformData = formDataTOXMLString();
        if (articleIdFromUrl == null) {
            addArticle(locationformData);
       } else {
           updateArticle(locationformData)
       }
       return true;
       });
   });


       function addArticle(xmlData) {

        const currentDate = new Date();
        var locationTitle = $(".LocationTitle").val();

        var allCategoriesToPush = [...Array.from(selectedCategoryIds), ...finalProductsCategories]

        Liferay.Service(    
            '/journal.journalarticle/add-article',{
                groupId: countryGroupId,
                folderId: countryFolderId,
                classNameId: 0,
                classPK: 0,
                articleId: '',
                autoArticleId: true,
                titleMap: { ["" + coutryLanguageId + ""]: locationTitle},
                descriptionMap: {["" + coutryLanguageId + ""]: ""},
                content: xmlData,
                ddmStructureKey: articleStructureId,
                ddmTemplateKey: articleTemplateId,
                layoutUuid: layoutUUID,
                displayDateMonth: currentDate.getMonth(),
                displayDateDay: currentDate.getDate(),
                displayDateYear: currentDate.getFullYear(),
                displayDateHour: 00,
                displayDateMinute: 00,
                expirationDateMonth: currentDate.getMonth(),
                expirationDateDay: currentDate.getDate(),
                expirationDateYear: currentDate.getFullYear() + 1,
                expirationDateHour: currentDate.getHours(),
                expirationDateMinute: currentDate.getMinutes(),
                neverExpire: true,
                reviewDateMonth: currentDate.getMonth(),
                reviewDateDay: currentDate.getDate(),
                reviewDateYear: currentDate.getFullYear(),
                reviewDateHour: currentDate.getHours(),
                reviewDateMinute: currentDate.getMinutes(),
                neverReview: true,
                indexable: true,
                articleURL: '',
                serviceContext: {assetCategoryIds: allCategoriesToPush
           }
       },function (obj) {
           if (obj) {
               addResourcesToArticle(obj);
               Toast.success("${(LocationCreatedMessage?has_content)?then(LocationCreatedMessage, 'Requested location is created successfully')}");
               window.location.href = thankYouPageURL;
           } else {
               Toast.danger("${(LocationFailMessage?has_content)?then(LocationFailMessage, 'Requested location is not created.')}");
               $("#save").prop('disabled', false).text("Save Location");
           }
       },
            function (error) {
            $("#save").prop('disabled', false).text("Save Location");
               Toast.danger("${(LocationFailMessage?has_content)?then(LocationFailMessage, 'Requested location is not created.')}");    }
        );
   }

    function updateArticle(locationformData){

        var allCategoriesToPush = [...Array.from(selectedCategoryIds), ...finalProductsCategories]

       Liferay.Service('/journal.journalarticle/update-article',
       {
                userId: webData.getUserId,
                groupId: webData.groupId,
                folderId: webData.folderId,
                articleId: articleIdFromUrl,
                version: webData.version,
                titleMap: "{ "+coutryLanguageId+": \"" + webData.titleCurrentValue + "\" }",
                descriptionMap: "{ "+coutryLanguageId+": \"" + webData.descriptionCurrentValue + "\" }",
                content: locationformData, 
                layoutUuid: webData.layoutUuid,
                serviceContext: {assetCategoryIds: allCategoriesToPush}
       },
       function (obj) {
           Toast.success("${(LocationUpdateSuccess?has_content)?then(LocationUpdateSuccess, 'Location is updated successfully')}");
           window.location.href = thankYouPageURL;
       }
        );
   }


    function addResourcesToArticle(article) {
        Liferay.Service(
        '/resourcepermission/set-individual-resource-permissions',{
           groupId: countryGroupId,
           companyId: countryCompanyId,
           name: 'com.liferay.journal.model.JournalArticle',
           primKey: article.resourcePrimKey,
           roleId: guestRoleId,
           actionIds: ["VIEW"]
       },
       function (obj) {
           console.log("Permission added on the WCM");
       },
       function (error) {
           $("#save").prop('disabled', false).text("Update Location");
           Toast.danger("${'Requested location is not updated.'}");    
       }
     );
   }

   function setGuestPermissionsForFileEntry(fileEntryId) {
        Liferay.Service(
        '/resourcepermission/set-individual-resource-permissions',{
           groupId: countryGroupId,
           companyId: countryCompanyId,
           name: 'com.liferay.document.library.kernel.model.DLFileEntry',
           primKey: fileEntryId,
           roleId: guestRoleId,
           actionIds: ["VIEW"]
       },
       function (obj) {
           console.log("Permission added on the WCM");
       }
     );
   }



