    const xmlBuilder = document.implementation.createDocument(null, null);
    
    function formDataTOXMLString() {

        const currentDate = new Date();

        const declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
        xmlBuilder.appendChild(declaration);

        const rootElement = xmlBuilder.createElement('root');
        rootElement.setAttribute('available-locales',"" + coutryLanguageId + "");
        rootElement.setAttribute('default-locale',"" + coutryLanguageId + "");
        xmlBuilder.appendChild(rootElement);

        for (const idName of idSubstrings) {
       
           const instanceId = String(idName).toLowerCase();;

              if(idName.includes("Time")){

                  days.forEach((day, index) => {
                 
                  var dayHoursContainer=$("#"+day.toLowerCase()+"-time-container").children();
                   
                   const dayDynamicElementParent = getynamicElement(day+"_Separator","selection_break","keyword", day+"_Separator"+index)

                   dayHoursContainer.each(function (index,currentEle) {
                      var fieldValue = currentEle.value;
                      var startTime = '';
                      var endTime = '';
                      var isCloseString = '';                   
                      
                      if(fieldValue) {

                       var dayDynamicElementChild = getynamicElement("TimingSeparator"+day,"selection_break","keyword","TimingSeparator"+day+index);
                       
                       if(fieldValue === "Closed") {
                           isCloseString = "true";                        
                       } else if(fieldValue.includes(" - ")) {
                           startTime = fieldValue.split(" - ")[0];
                           endTime = fieldValue.split(" - ")[1];
                       }
       
                        var startXML = createDynamicElement(day+"Open","text", startTime, day+"Open"+index, false);
                        var endXML = createDynamicElement(day+"Close","text", endTime, day+"Close"+index, false);

                        dayDynamicElementChild.append(startXML);
                        dayDynamicElementChild.append(endXML);
                        dayDynamicElementParent.append(dayDynamicElementChild);

                           if(!dayDynamicElementParent.querySelector('dynamic-element[name="isClosed'+day+'"]')) {
                               var closeXML = createDynamicElement("isClosed"+day,"boolean",isCloseString,"isClosed"+day+index, false);
                               dayDynamicElementParent.append(closeXML);
                           }
                        
                       }
                       
                   });
                   
                   xmlBuilder.documentElement.appendChild(dayDynamicElementParent);
               });
           } else if (idName.includes("Country")) {
                var countryField = $("." + idName);
                const selectedCountryObj = countries.find(country => country.name === countryField.val());
                if (selectedCountryObj) {
                   createDynamicElement(idName,"text", (countryField.val() + " - " + selectedCountryObj.code), instanceId, true);
               }
           } else if (idName.includes("GeolocationData")) {
                var latitude = $("#latitude").val();
                var longitude = $("#longitude").val();

                createDynamicElement(idName,"ddm-geolocation","{\"latitude\":\"" + latitude + "\",\"longitude\":\"" + longitude + "\"}", instanceId, true);
           } else if (idName.includes("Products")) {

                $('#tags-container [class^="product"]').toArray().forEach((product, index) => {
                   createDynamicElement("Products","text", $(product).text().replace("x",""), ("product" + index), true);
               });
           } else if (idName.includes("ContactDetail")) {

                $('[id^="contact-card-id-"]').toArray().forEach((contact, index) => {
                    const contactInsId = ("contact-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"ContactDetail");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                    dynamicElement.appendChild(createDynamicElement("ContactName","text", $(contact).find(".contact-name").text().trim(), contactInsId + "-name"), false);
                    dynamicElement.appendChild(createDynamicElement("JobPosition","text", $(contact).find(".contact-job").text().trim(), contactInsId + "-job"), false);
                    dynamicElement.appendChild(createDynamicElement("EmailAddress","text", $(contact).find(".contact-email a").text().trim(), contactInsId + "-email"), false);
                    dynamicElement.appendChild(createDynamicElement("PhoneNumber1","text", $(contact).find(".contact-phone").text().trim(), contactInsId + "-phone"), false);

                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("FileCard")) {

                $('[id^="file-card-id-"]').toArray().forEach((filed, index) => {

                    var fileInput = document.getElementById('file');
                    var file = fileInput.files[0];

                    const contactInsId = ("card-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"FileCard");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                    dynamicElement.appendChild(createDynamicElement("PriceName","text", $(filed).find(".file-name").text().trim(), contactInsId + "-name"), false);

                    if (resultList && resultList.length > 0) {
                        resultList.forEach((result, resultIndex) => {
                           if (resultIndex === index) {
                                  var dyEle = createDynamicElementForFile(result);
                                  dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   } 
                  
                   if (articleIdFromUrl != null && fileValues != null) {
                      fileValues.forEach((result, resultIndex) => {
                          if (resultIndex === index) {
                              var dyEle = createDynamicElementForFile(result);
                              dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   }
                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           }else if (idName.includes("PublisherImages")) {

                $('[id^="GMB-card-id-"]').toArray().forEach((filed, index) => {

                    var fileInput = document.getElementById('file');
                   
                    var file = fileInput.files[0];

                    const contactInsId = ("GMBcard-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"PublisherImages");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                    dynamicElement.appendChild(createDynamicElement("Publisher","text", $(filed).find(".file-Publisher").text().trim(), contactInsId + "-name"), false);

                    if (GMBFileList && GMBFileList.length > 0) {
                        GMBFileList.forEach((result, resultIndex) => {
                           if (resultIndex === index) {
                                     var dyEle = createDynamicElementForGMBFile(result);
                                     dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   } 
                  
                  if (articleIdFromUrl != null && GMBfileValues != null) {
                      GMBfileValues.forEach((result, resultIndex) => {
                          if (resultIndex === index) {                         
                              var dyEle = createDynamicElementForGMBFile(result);
                              dynamicElement.appendChild(dyEle, false);
                           }
                       });
                   }

                  dynamicElement.appendChild(createDynamicElement("Description","text", $(filed).find(".file-Description").text().trim(), contactInsId + "-name"), false);

                  xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("AddPage")) {
               
                $('[id^="page-card-id-"]').toArray().forEach((addPages, index) => {
                
                    const contactInsId = ("page-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"AddPage");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                   dynamicElement.appendChild(createDynamicElement("PageName","text", $(addPages).find(".page-name").text().trim(), contactInsId + "-name"), false);
                   dynamicElement.appendChild(createDynamicElement("PageUrl","text", $(addPages).find(".page-url").text().trim(), contactInsId + "-job"), false);

                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("ProductCard")) {
               
                $('[id^="pro-link-card-id-"]').toArray().forEach((addProducts, index) => {
                    const contactInsId = ("product-detail-" + index);
                    const dynamicElement = xmlBuilder.createElement('dynamic-element');

                    dynamicElement.setAttribute('name',"ProductCard");
                    dynamicElement.setAttribute('type',"selection_break");
                    dynamicElement.setAttribute('index-type', 'keyword');
                    dynamicElement.setAttribute('instance-id', contactInsId);

                   var productCateId = $(addProducts).find(".pro-link-name").attr("id");

                   if(productCateId) finalProductsCategories.push(productCateId)

                   dynamicElement.appendChild(createDynamicElement("Name","text", $(addProducts).find(".pro-link-name").text().trim(), contactInsId + "-name"), false);
                   dynamicElement.appendChild(createDynamicElement("Link","text", $(addProducts).find(".pro-link").text().trim(), contactInsId + "-link"), false);

                    xmlBuilder.documentElement.appendChild(dynamicElement);
               });
           } else if (idName.includes("LocationImage")) {
                var fileInput = document.getElementById('fileInput');
                var file = fileInput.files[0];

                if (articleIdFromUrl != null && imageGlobal != null) {
                    xmlBuilder.documentElement.appendChild(imageGlobal);
               } else {
                    if (file && file.size) {
                        var dyEle = createDynamicElementForImage(uploadedImage);
                        xmlBuilder.documentElement.appendChild(dyEle);
                   }
               }
           }else if (idName.includes("RichText")){
   	     var richData = $("#div_editor1 iframe").contents().find("body").html();
   	     createDynamicElement(idName,"text", richData, instanceId, true);
           } else if (idName.includes("isYextRestrict")){
   		 
   			var checkBox = document.getElementById("yextSy");
   			var isChecked = checkBox.checked;
   			if (isChecked) {
   				createDynamicElement(idName,"text",true, instanceId, true);
               } else {
   				createDynamicElement(idName,"text",'', instanceId, true);
               }
           } else {
                var fieldValue = $("." + idName).val();
                createDynamicElement(idName,"text", fieldValue, instanceId, true);
           }
       }

        const xmlContent = new XMLSerializer().serializeToString(xmlBuilder);
        return xmlContent;
   }

    function getynamicElement(name, type, indexType, instanceId) {
        const dynamicElement = xmlBuilder.createElement('dynamic-element');

        dynamicElement.setAttribute('name', name);
        dynamicElement.setAttribute('type', type);
        dynamicElement.setAttribute('index-type',  indexType);
        dynamicElement.setAttribute('instance-id', instanceId);

        return dynamicElement;
   }

    function createDynamicElement(name, type, value, instanceId, appendInXML) {
        const dynamicElement = xmlBuilder.createElement('dynamic-element');

        dynamicElement.setAttribute('name', name);
        dynamicElement.setAttribute('type', type);
        dynamicElement.setAttribute('index-type', 'keyword');
        dynamicElement.setAttribute('instance-id', instanceId);

        const dynamicContent = xmlBuilder.createElement('dynamic-content');
        dynamicContent.setAttribute('language-id',"" + coutryLanguageId + "");

        const cdata = xmlBuilder.createCDATASection(value);
        dynamicContent.appendChild(cdata);

        dynamicElement.appendChild(dynamicContent);
        if (appendInXML) {
            xmlBuilder.documentElement.appendChild(dynamicElement);
       }

        return dynamicElement;
   }

    function createDynamicElementForImage(documentResponse) {
        const dynamicElement = xmlBuilder.createElement('dynamic-element');

        dynamicElement.setAttribute('name', 'LocationImage');
        dynamicElement.setAttribute('type', 'image');
        dynamicElement.setAttribute('index-type', 'text');
        dynamicElement.setAttribute('instance-id', 'sffadsfgdsadf');

        const dynamicContent = xmlBuilder.createElement('dynamic-content');
        dynamicContent.setAttribute('language-id', coutryLanguageId);
        dynamicContent.setAttribute('alt', documentResponse.fileName);
        dynamicContent.setAttribute('name', documentResponse.fileName);
        dynamicContent.setAttribute('title', documentResponse.fileName);
        dynamicContent.setAttribute('type', 'document');
        dynamicContent.setAttribute('fileEntryId', documentResponse.fileEntryId);

        var imagePath = "/documents/" + documentResponse.groupId + "/" + documentResponse.folderId + "/" + documentResponse.fileName;

        const cdata = xmlBuilder.createCDATASection(imagePath);
        dynamicContent.appendChild(cdata);

        dynamicElement.appendChild(dynamicContent);

        return dynamicElement;
   }

   function createDynamicElementForFile(documentResponse) {
       const dynamicElement = xmlBuilder.createElement('dynamic-element');

       dynamicElement.setAttribute('name', 'LocationPriceList');
       dynamicElement.setAttribute('instance-id', documentResponse.uuid);
       dynamicElement.setAttribute('type', 'document_library');
       dynamicElement.setAttribute('index-type', 'keyword');

       const dynamicContent = xmlBuilder.createElement('dynamic-content');
       dynamicContent.setAttribute('language-id',"" + coutryLanguageId + "");

       var filePath = "/documents/" + documentResponse.groupId + "/" + documentResponse.folderId + "/" + documentResponse.fileName + "/" +documentResponse.uuid + "?t=" +documentResponse.modifiedDate;

       const cdata = xmlBuilder.createCDATASection(filePath);
       dynamicContent.appendChild(cdata);
       dynamicElement.appendChild(dynamicContent);

       return dynamicElement;
   }

    function createDynamicElementForGMBFile(documentResponse) {
       const dynamicElement = xmlBuilder.createElement('dynamic-element');

       dynamicElement.setAttribute('name', 'File');
       dynamicElement.setAttribute('instance-id', documentResponse.uuid);
       dynamicElement.setAttribute('type', 'document_library');
       dynamicElement.setAttribute('index-type', 'keyword');

       const dynamicContent = xmlBuilder.createElement('dynamic-content');
       dynamicContent.setAttribute('language-id',"" + coutryLanguageId + "");

       var filePath = "/documents/" + documentResponse.groupId + "/" + documentResponse.folderId + "/" + documentResponse.fileName + "/" +documentResponse.uuid + "?t=" +documentResponse.modifiedDate;

       const cdata = xmlBuilder.createCDATASection(filePath);
       dynamicContent.appendChild(cdata);

       dynamicElement.appendChild(dynamicContent);

       return dynamicElement;
   }
   