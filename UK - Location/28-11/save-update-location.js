var coutryLanguageId = themeDisplay.getLanguageId();
var xmlBuilder;

async function formDataToXMLString() {
   xmlBuilder = document.implementation.createDocument(null, null);

   var declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
   xmlBuilder.appendChild(declaration);

   var rootElement = xmlBuilder.createElement('root');
   rootElement.setAttribute('available-locales', '' + coutryLanguageId + '');
   rootElement.setAttribute('default-locale', '' + coutryLanguageId + '');
   rootElement.setAttribute('version', '' + "1.0" + '');
   xmlBuilder.appendChild(rootElement);

   for (var fieldId in locationFieldsIds) {
       var config = locationFieldsIds[fieldId];
       var instanceId = fieldId.toLowerCase();

       if (fieldId === 'OpeningHours') {
           await processOpeningHours(fieldId, config);
       } else if (fieldId === 'ContactDetail') {
           await processContactDetails(fieldId, config)
       } else if (fieldId === 'FileCard') {
           await processFileCards(fieldId, config)
       } else if (fieldId === 'PublisherImages') {
           await processPublisherImages(fieldId, config)
       } else if (fieldId === 'AddPage') {
           await processAddPages(fieldId, config)
       } else if (fieldId === 'ProductCard') {
           await processProductCards(fieldId, config)
       } else if (fieldId === 'isLocationClosed') {
       } else {
           await processSimpleField(fieldId, config);
       }
   }

   return new XMLSerializer().serializeToString(xmlBuilder);
}

document.getElementById('locationForm').addEventListener('submit', async (event) => {
   event.preventDefault();

   var articleIdFromUrl = new URLSearchParams(window.location.search).get('articleId');
   saveButtonOperation(true, (articleIdFromUrl ? true : false));

   if (!genericValidations()) {
       Toast.error(validateAllFormFields);
       saveButtonOperation(false, false);
       return;
   }

   try {
       var locationformData = await formDataToXMLString();
       var locationName = document.querySelector("#locationname").value;
       if (!articleIdFromUrl) {
           await addArticle(locationformData, locationName, Array.from(selectedCategoryIds));
           saveButtonOperation(false, false);
       } else {
           locationXMLDataUpdateTime = await updateArticle(locationXMLDataUpdateTime, locationformData, articleIdFromUrl, locationName, Array.from(selectedCategoryIds));
       }
   } catch (error) {
       console.error('Error processing form:', error);
       Toast.error(locationFailMessage);
   }
   saveButtonOperation(false, (articleIdFromUrl ? true : false))
});

function saveButtonOperation(isProcess, isUpdate) {
  var saveButton = document.getElementById('save');

  if(isProcess) {
     saveButton.disabled = true;
     saveButton.textContent = (isUpdate ? 'Updating' : 'Saving') + " Location...";
  }
   
  if(!isProcess) {
     saveButton.disabled = false;
     saveButton.textContent = (isUpdate ? 'Update' : 'Save') + " Location";
  }
}

async function getDynamicElement(name, fieldReference, type, indexType) {
   var dynamicElement = xmlBuilder.createElement('dynamic-element');
   dynamicElement.setAttribute('field-reference', fieldReference);
   dynamicElement.setAttribute('index-type', indexType);
   dynamicElement.setAttribute('instance-id', await generateRandomString(5));
   dynamicElement.setAttribute('name', name);
   dynamicElement.setAttribute('type', type);
   
   return dynamicElement;
}

async function createDynamicElement(name, fieldReference, type, value, appendToRoot) {
   var dynamicElement = xmlBuilder.createElement('dynamic-element');
   dynamicElement.setAttribute('field-reference', fieldReference);
   dynamicElement.setAttribute('index-type', 'keyword');
   dynamicElement.setAttribute('instance-id', await generateRandomString(5));
   dynamicElement.setAttribute('name', name);
   dynamicElement.setAttribute('type', type);
   
   var dynamicContent = xmlBuilder.createElement('dynamic-content');
   dynamicContent.setAttribute('language-id', '' + coutryLanguageId + '');

   var cdata = xmlBuilder.createCDATASection(value ?? '');
   dynamicContent.appendChild(cdata);
   dynamicElement.appendChild(dynamicContent);

   if (appendToRoot) {
       xmlBuilder.documentElement.appendChild(dynamicElement);
   }

   return dynamicElement;
}

async function processSimpleField(fieldId, config) {
   var field = document.querySelector(config.elementId);
   if (field) {
       var fieldValue;

       if(fieldId == "RichText") fieldValue = document.querySelector("#div_editor1 iframe").contentDocument.body.innerHTML;
       else if(fieldId == "LocationImage") fieldValue = document.querySelector("#fileInput").dataset.fileResponse;
       else if(fieldId == "isYextRestrict") fieldValue = field.checked;
       else if(fieldId == "Geolocation") fieldValue = '{"lat":"' + document.querySelector(config.latitude.elementId).value + '","lng":"' + document.querySelector(config.longitude.elementId).value + '"}';
       else fieldValue = field.value;

       if(!fieldValue) return;

       await createDynamicElement(config.xmlFieldName, fieldId, config.type, fieldValue, true);
   }
}

async function processOpeningHours(fieldId, config) {
   for (var day of days) {
       var containerId = day.toLowerCase() + config.elementId;
       var dayHoursContainer = document.querySelector('#' + containerId).children;
       let isClosed = false;
       var dayDynamicElementParent = await getDynamicElement(config.xmlFieldName, fieldId, config.type, '');

       await dayDynamicElementParent.appendChild(
           await createDynamicElement(config.nestedFields.dayName.xmlFieldName, "DayName", config.nestedFields.dayName.type, day, false)
       );
       
       if(dayHoursContainer.length == 1 && dayHoursContainer[0].value == "Closed") {
           isClosed = true;
           var startCloseParent = await getDynamicElement(config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.type, '');

           await startCloseParent.appendChild(
               await createDynamicElement(config.nestedFields.timeSlots.nestedFields.open.xmlFieldName, "Open", config.nestedFields.timeSlots.nestedFields.open.type, '', false)
           );
           await startCloseParent.appendChild(
               await createDynamicElement(config.nestedFields.timeSlots.nestedFields.close.xmlFieldName, "Close", config.nestedFields.timeSlots.nestedFields.close.type, '', false)
           );

           dayDynamicElementParent.appendChild(startCloseParent);
       } else {
           var inputs = document.querySelectorAll('#' + containerId + " input");
           for (var element of inputs) {
               var openCloseOP = element.value.split("-");
               
               if(openCloseOP.length != 2) continue;

               var startCloseParent = await getDynamicElement(config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.type, '');
               
               await startCloseParent.appendChild(
                   await createDynamicElement(config.nestedFields.timeSlots.nestedFields.open.xmlFieldName, "Open", config.nestedFields.timeSlots.nestedFields.open.type, openCloseOP[0].trim(), false)
               );
               
               await startCloseParent.appendChild(
                   await createDynamicElement(config.nestedFields.timeSlots.nestedFields.close.xmlFieldName, "Close", config.nestedFields.timeSlots.nestedFields.close.type, openCloseOP[1].trim(), false)
               );

               dayDynamicElementParent.appendChild(startCloseParent);
           }
       }
       
       await dayDynamicElementParent.appendChild(
           await createDynamicElement(config.nestedFields.isClosed.xmlFieldName, "isClosed", config.nestedFields.isClosed.type, isClosed, false)
       );

       xmlBuilder.documentElement.appendChild(dayDynamicElementParent);
   }
}

async function processContactDetails(fieldId, config) {
   var contactCards = document.querySelectorAll('[id^="contact-card-id-"]');
   for (var contact of contactCards) {
       var dynamicElement = await getDynamicElement(config.xmlFieldName, fieldId, config.type, '');
       
       var contactPhone = contact.querySelector('.contact-phone').textContent.trim();

       if(!contactPhone) continue;

       var nameField = await createDynamicElement(
           config.nestedFields.contactName.xmlFieldName,
           "ContactName",
           config.nestedFields.contactName.type,
           (contact.querySelector('.contact-name').textContent.trim() ?? "General"),
           false
       );
       
       var jobField = await createDynamicElement(
           config.nestedFields.jobPosition.xmlFieldName,
           "JobPosition",
           config.nestedFields.jobPosition.type,
           contact.querySelector('.contact-job').textContent.trim(),
           false
       );
       
       var emailField = await createDynamicElement(
           config.nestedFields.emailAddress.xmlFieldName,
           "EmailAddress",
           config.nestedFields.emailAddress.type,
           contact.querySelector('.contact-email a').textContent.trim(),
           false
       );
       
       var phoneField = await createDynamicElement(
           config.nestedFields.phoneNumber1.xmlFieldName,
           "PhoneNumber1",
           config.nestedFields.phoneNumber1.type,
           contactPhone,
           false
       );

       dynamicElement.appendChild(nameField);
       dynamicElement.appendChild(jobField);
       dynamicElement.appendChild(emailField);
       dynamicElement.appendChild(phoneField);

       xmlBuilder.documentElement.appendChild(dynamicElement);
   }
}

async function processFileCards(fieldName, config) {
   var fileCards = document.querySelectorAll('[id^="file-card-id-"]');
   for (var filed of fileCards) {
       var fileName = filed.querySelector('.file-name').textContent.trim();
       var fileValue = filed.querySelector('.file-value').dataset.fileResponse.trim();

       if(!fileName || !fileValue) continue;

       var dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.priceName.xmlFieldName, 'PriceName', config.nestedFields.priceName.type, fileName, false)
       );

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.locationPriceList.xmlFieldName, 'LocationPriceList', config.nestedFields.locationPriceList.type, fileValue, false)
       );

       xmlBuilder.documentElement.appendChild(dynamicElement);
   }
}

async function processPublisherImages(fieldName, config) {
   var publisherCards = document.querySelectorAll('[id^="GMB-card-id-"]');
   for (var filed of publisherCards) {
       var publisher = filed.querySelector('.file-Publisher').textContent.trim();
       var fileValue = filed.querySelector('.file-value').dataset.fileResponse.trim();
       var fileDescription = filed.querySelector('.file-Description').textContent.trim();

       if(!publisher || !fileValue) continue;

       var dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.publisher.xmlFieldName, 'Publisher', config.nestedFields.publisher.type, publisher, false)
       );

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.file.xmlFieldName, 'File', config.nestedFields.file.type, fileValue, false)
       );

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.description.xmlFieldName, 'Description', config.nestedFields.description.type, fileDescription, false)
       );

       xmlBuilder.documentElement.appendChild(dynamicElement);
   }
}

async function processAddPages(fieldName, config) {
   var pageCards = document.querySelectorAll('[id^="page-card-id-"]');
   for (var addPages of pageCards) {
       var dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');
       
       var pageName = addPages.querySelector('.page-name').textContent.trim();
       var pageLink = addPages.querySelector('.page-url').textContent.trim()

       if(!pageName || !pageLink) continue;

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.pageName.xmlFieldName, 'PageName', config.nestedFields.pageName.type, pageName, false)
       );

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.pageUrl.xmlFieldName, 'PageUrl', config.nestedFields.pageUrl.type, pageLink, false)
       );

       xmlBuilder.documentElement.appendChild(dynamicElement);
   }
}

async function processProductCards(fieldName, config) {
   var productCards = document.querySelectorAll('[id^="pro-link-card-id-"]');
   for (var addProducts of productCards) {
       var dynamicElement = await getDynamicElement(config.xmlFieldName, fieldName, config.type, '');
       var productName = addProducts.querySelector('.pro-link-name').textContent.trim();
       var productLink = addProducts.querySelector('.pro-link').textContent.trim();

       if(!productName || !productLink) continue;

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.name.xmlFieldName, 'Name', config.nestedFields.name.type, productName, false)
       );

       await dynamicElement.appendChild(
           await createDynamicElement(config.nestedFields.link.xmlFieldName, 'Link', config.nestedFields.link.type, productLink, false)
       );

       xmlBuilder.documentElement.appendChild(dynamicElement);
   }
}