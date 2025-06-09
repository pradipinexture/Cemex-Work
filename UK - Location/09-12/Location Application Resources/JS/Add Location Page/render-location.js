
var urlParams = new URLSearchParams(window.location.search);
var articleIdFromUrl = urlParams.get('articleId');
var locationXMLDataUpdateTime;

   var submitButton = document.getElementById("save");
   var modelHeading = document.getElementById("myModalLabel");

  function findFieldConfigByFieldRef(fieldRef) {return locationFieldsIds[fieldRef] || Object.entries(locationFieldsIds).find(([key, config]) => key === fieldRef)?.[1];}

  async function processArticle() {
       if (!articleIdFromUrl) return;

       submitButton.innerText = updateLocationLabel;
       modelHeading.innerText = updateLocationLabel;

       try {
           var webContent = await new Promise((resolve, reject) => {
               Liferay.Service(
                   '/journal.journalarticle/get-article',
                   {
                       groupId: countryGroupId,
                       articleId: articleIdFromUrl
                   },
                   resolve,
                   reject
               );
           });

           var parser = new DOMParser();
           locationXMLDataUpdateTime = webContent;
           var locationXmlDoc = parser.parseFromString(webContent.content, 'application/xml');

           var rootElement = locationXmlDoc.querySelector('root');
           if (!rootElement) return;

           (async () => {
             var categories = await getWebcontentCategories(webContent.resourcePrimKey);
             console.log(categories);
             if (categories && categories.length !== 0) {
                 categories.forEach(function (cat) {
                     selectCategory(cat.categoryId);
                 });
             }
           })();

           var dynamicElements = rootElement.children;

           for (var element of dynamicElements) {
               var fieldReference = element.getAttribute('field-reference');
               var name = element.getAttribute('name');
               var type = element.getAttribute('type');

               let fieldConfig = findFieldConfigByFieldRef(fieldReference);
               if (!fieldConfig) continue;

               var content = element.querySelector('dynamic-content');
               var contentValue = content?.textContent || '';

               if (!contentValue && type !== 'fieldset') continue;

               var elementId = fieldConfig.elementId;
               if (!elementId) continue;

               switch (type) {
                   case 'fieldset':
                       if (fieldReference === 'OpeningHours') await processOpeningHours(element, fieldConfig);
                       else if (fieldReference === 'ContactDetail') await processContactDetail(element, fieldConfig);
                       else if (fieldReference === 'ProductCard') await processAllProductCards(element, fieldConfig);
                       else if (fieldReference === 'PublisherImages') await processAllPublisherImages(element, fieldConfig);
                       else if (fieldReference === 'FileCard') await processAllFileCards(element, fieldConfig);
                       else if (fieldReference === 'AddPage') await processAllAddPages(element, fieldConfig);
                       break;

                   case 'text':
                       await processSimpleField(contentValue, fieldConfig);
                       break;
                   case 'rich_text':
                       if (fieldReference === 'RichText') processRichText(contentValue, fieldConfig);
                       break;
                   case 'geolocation':
                       await processGeolocation(contentValue, fieldConfig);
                       break;
                   case 'image':
                       if (fieldReference === 'LocationImage') await processLocationImage(contentValue, fieldConfig);
                       break;
                   case 'checkbox':
                       if (fieldReference === 'isYextRestrict') document.querySelector(elementId).checked = (contentValue === 'true');
                       break;
               }
           }

       } catch (error) {
           console.error('Error processing article:', error);
       }
   }

    async function processOpeningHours(dayElement, fieldConfig) {
        var dayName = dayElement.querySelector('[field-reference="' + fieldConfig.nestedFields.dayName.fieldName + '"] dynamic-content')?.textContent;
        var isClosed = dayElement.querySelector('[field-reference="' + fieldConfig.nestedFields.isClosed.fieldName + '"] dynamic-content')?.textContent === 'true';
        
        var timeContainer = document.querySelector("#" + dayName.toLowerCase() + fieldConfig.elementId);
        
        if (isClosed) {
            timeContainer.innerHTML = ('<input type="text" placeholder="—:— - —:—" value="' + "Closed" + '"> ');
        } 
        else {
            var strtEndEleString = '';
            dayElement.querySelectorAll('dynamic-element[field-reference="' + fieldConfig.nestedFields.timeSlots.fieldName + '"]').forEach((elem)=>{
                var startTime = elem.querySelector('dynamic-element[field-reference="' + fieldConfig.nestedFields.timeSlots.nestedFields.open.fieldName + '"]')?.textContent;
                var closeTime = elem.querySelector('dynamic-element[field-reference="' + fieldConfig.nestedFields.timeSlots.nestedFields.close.fieldName + '"]')?.textContent;
                
                if (startTime && closeTime) strtEndEleString += '<input type="text" placeholder="—:— - —:—" value="' + startTime.trim() + ' - ' + closeTime.trim() + '"> ';
            })
            timeContainer.innerHTML = strtEndEleString;
        }
    }

    async function processContactDetail(contactElement, fieldConfig) {
        var contactContainer = document.querySelector(fieldConfig.elementId);
        var contactName = contactElement.querySelector('[field-reference="' + fieldConfig.nestedFields.contactName.fieldName + '"] dynamic-content')?.textContent || '';
        var jobPosition = contactElement.querySelector('[field-reference="' + fieldConfig.nestedFields.jobPosition.fieldName + '"] dynamic-content')?.textContent || '';
        var emailAddress = contactElement.querySelector('[field-reference="' + fieldConfig.nestedFields.emailAddress.fieldName + '"] dynamic-content')?.textContent || '';
        var phoneNumber = contactElement.querySelector('[field-reference="' + fieldConfig.nestedFields.phoneNumber1.fieldName + '"] dynamic-content')?.textContent || '';
        if(!contactName || !phoneNumber) return;
        contactContainer.insertAdjacentHTML('beforeend', generateContactElement(contactName, jobPosition, emailAddress, phoneNumber));
    }

    async function processAllProductCards(productElement, fieldConfig) {
        var nameElement = productElement.querySelector('[field-reference="' + fieldConfig.nestedFields.name.fieldName + '"] dynamic-content');
        var linkElement = productElement.querySelector('[field-reference="' + fieldConfig.nestedFields.link.fieldName + '"] dynamic-content');
        
        var productName = nameElement?.textContent || '';
        var productLink = linkElement?.textContent || '';
        if(!productName || !productLink) return;
        await generateProductHTMLAndAppend(productName, "test", productLink);
    }

    async function processAllPublisherImages(element, fieldConfig) {
        var container = document.querySelector(fieldConfig.elementId);

        var publisher = element.querySelector('[field-reference="' + fieldConfig.nestedFields.publisher.fieldName + '"] dynamic-content')?.textContent;
        var fileData = element.querySelector('[field-reference="' + fieldConfig.nestedFields.file.fieldName + '"] dynamic-content')?.textContent;
        var description = element.querySelector('[field-reference="' + fieldConfig.nestedFields.description.fieldName + '"] dynamic-content')?.textContent;

        if (publisher && convertStringtoJson(fileData)) container.insertAdjacentHTML('beforeend', generateGMBDiv(publisher, JSON.parse(fileData), description));
    }

    async function processAllFileCards(element, fieldConfig) {
        var container = document.querySelector(fieldConfig.elementId);

        var priceName = element.querySelector('[field-reference="' + fieldConfig.nestedFields.priceName.fieldName + '"] dynamic-content')?.textContent;
        var fileData = element.querySelector('[field-reference="' + fieldConfig.nestedFields.locationPriceList.fieldName + '"] dynamic-content')?.textContent;

        if (priceName && convertStringtoJson(fileData)) container.insertAdjacentHTML('beforeend', generateFileCard(priceName, convertStringtoJson(fileData)));
    }

    async function processAllAddPages(element, fieldConfig) {
        var container = document.querySelector(fieldConfig.elementId);
        var pageName = element.querySelector('[field-reference="' + fieldConfig.nestedFields.pageName.fieldName + '"] dynamic-content')?.textContent;
        var pageUrl = element.querySelector('[field-reference="' + fieldConfig.nestedFields.pageUrl.fieldName + '"] dynamic-content')?.textContent;

        if (pageName && pageUrl) container.insertAdjacentHTML('beforeend', generatePageElement(pageName, pageUrl));
    }
   async function processLocationImage(contentValue, fieldConfig) {
       if (!contentValue) return;

       var imageData = convertStringtoJson(contentValue);
	if(!imageData) return 
       var imageElement = document.querySelector(fieldConfig.elementId);
       imageElement.style.backgroundImage = "url(" + "'/documents/"+countryGroupId+"/"+documentMediaFolderId+"/"+imageData.name+"?imagePreview=1'" + ")";
       document.querySelector("#fileInput").dataset.fileResponse = contentValue;
       imageElement.style.display = 'block';
   }

   async function processGeolocation(contentValue, fieldConfig) {
       if (!contentValue) return;

       var geolocationData = convertStringtoJson(contentValue);
       if(!geolocationData) return;
       document.querySelector(locationFieldsIds.Geolocation.latitude.elementId).value = geolocationData.lat;
       document.querySelector(locationFieldsIds.Geolocation.longitude.elementId).value = geolocationData.lng;
       await updateMap();
   }

    function processRichText(contentValue, fieldConfig) {
        const checkIframe = setInterval(() => {
            const editorIframe = document.querySelector(fieldConfig.elementId + ' iframe');
            if (editorIframe?.contentDocument) {
                editorIframe.contentDocument.body.innerHTML = contentValue;
                clearInterval(checkIframe);
            }
        }, 100);
    }

   async function processSimpleField(contentValue, fieldConfig) {
       var element = document.querySelector(fieldConfig.elementId);
       if (element) {
           if (fieldConfig === locationFieldsIds.Country) {
               var parts = contentValue.split(' - ');
               element.value = parts.length === 2 ? parts[0].trim() : contentValue;
           } else {
               element.value = contentValue;
           }
       }
   }

   processArticle().catch(error => {
       console.error('Error in main process:', error);
   });
   
   function convertStringtoJson(jsonString){
      try{
         return JSON.parse(jsonString)
      }catch(e){
         return null;
      }
   }
