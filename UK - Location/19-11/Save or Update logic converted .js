const xmlBuilder = document.implementation.createDocument(null, null);
    
function formDataToXMLString() {
    const declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
    xmlBuilder.appendChild(declaration);

    var rootElement = xmlBuilder.createElement('root');
    rootElement.setAttribute('available-locales', '' + coutryLanguageId + '');
    rootElement.setAttribute('default-locale', '' + coutryLanguageId + '');
    xmlBuilder.appendChild(rootElement);

    for (var fieldId in locationFieldsIds) {
        var config = locationFieldsIds[fieldId];
        var instanceId = fieldId.toLowerCase();

        if (fieldId === 'OpeningHours') {
            processOpeningHours(config);
        } else if (fieldId === 'Country') {
            processCountryField(config, instanceId);
        } else if (fieldId === 'Geolocation') {
            processGeolocationField(config, instanceId);
        } else if (fieldId === 'ContactDetail') {
            processContactDetails(config);
        } else if (fieldId === 'FileCard') {
            processFileCards(config);
        } else if (fieldId === 'PublisherImages') {
            processPublisherImages(config);
        } else if (fieldId === 'AddPage') {
            processAddPages(config);
        } else if (fieldId === 'ProductCard') {
            processProductCards(config);
        } else if (fieldId === 'LocationImage') {
            processLocationImage(config);
        } else if (fieldId === 'RichText') {
            processRichText(config, instanceId);
        } else if (fieldId === 'isYextRestrict') {
            processYextRestrict(config, instanceId);
        } else {
            processSimpleField(fieldId, config, instanceId);
        }
    }

    return new XMLSerializer().serializeToString(xmlBuilder);
}

function processOpeningHours(config) {
    var days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    days.forEach(function(day, index) {
        var containerId = day.toLowerCase() + config.elementId;
        var dayHoursContainer = document.querySelector('#' + containerId).children;
        var dayDynamicElementParent = getDynamicElement(day + '_Separator', 'selection_break', 'keyword', day + '_Separator' + index);

        Array.from(dayHoursContainer).forEach(function(currentEle, timeIndex) {
            var fieldValue = currentEle.value;
            var startTime = '';
            var endTime = '';
            var isCloseString = '';

            if (fieldValue) {
                var dayDynamicElementChild = getDynamicElement('TimingSeparator' + day, 'selection_break', 'keyword', 'TimingSeparator' + day + timeIndex);

                if (fieldValue === 'Closed') {
                    isCloseString = 'true';
                } else if (fieldValue.includes(' - ')) {
                    var timeParts = fieldValue.split(' - ');
                    startTime = timeParts[0];
                    endTime = timeParts[1];
                }

                var startXML = createDynamicElement(config.nestedFields.open, 'text', startTime, day + 'Open' + timeIndex, false);
                var endXML = createDynamicElement(config.nestedFields.close, 'text', endTime, day + 'Close' + timeIndex, false);

                dayDynamicElementChild.appendChild(startXML);
                dayDynamicElementChild.appendChild(endXML);
                dayDynamicElementParent.appendChild(dayDynamicElementChild);

                if (!dayDynamicElementParent.querySelector('dynamic-element[name="isClosed' + day + '"]')) {
                    var closeXML = createDynamicElement(config.nestedFields.isClosed, 'boolean', isCloseString, 'isClosed' + day + timeIndex, false);
                    dayDynamicElementParent.appendChild(closeXML);
                }
            }
        });
        xmlBuilder.documentElement.appendChild(dayDynamicElementParent);
    });
}

function processCountryField(config, instanceId) {
    var countryField = document.querySelector(config.elementId);
    if (countryField) {
        var selectedCountryObj = countries.find(function(country) {
            return country.name === countryField.value;
        });
        if (selectedCountryObj) {
            createDynamicElement(config.xmlFieldName, 'text', countryField.value + ' - ' + selectedCountryObj.code, instanceId, true);
        }
    }
}

function processGeolocationField(config, instanceId) {
    var latitude = document.querySelector(config.latitude.elementId).value;
    var longitude = document.querySelector(config.longitude.elementId).value;
    var geoData = '{"latitude":"' + latitude + '","longitude":"' + longitude + '"}';
    createDynamicElement(config.xmlFieldName, 'ddm-geolocation', geoData, instanceId, true);
}

function processContactDetails(config) {
    var contactCards = document.querySelectorAll('[id^="contact-card-id-"]');
    contactCards.forEach(function(contact, index) {
        var contactInsId = 'contact-detail-' + index;
        var dynamicElement = getDynamicElement('ContactDetail', 'selection_break', 'keyword', contactInsId);

        var nameField = createDynamicElement(config.nestedFields.contactName, 'text', 
            contact.querySelector('.contact-name').textContent.trim(), contactInsId + '-name', false);
        var jobField = createDynamicElement(config.nestedFields.jobPosition, 'text', 
            contact.querySelector('.contact-job').textContent.trim(), contactInsId + '-job', false);
        var emailField = createDynamicElement(config.nestedFields.emailAddress, 'text', 
            contact.querySelector('.contact-email a').textContent.trim(), contactInsId + '-email', false);
        var phoneField = createDynamicElement(config.nestedFields.phoneNumber, 'text', 
            contact.querySelector('.contact-phone').textContent.trim(), contactInsId + '-phone', false);

        dynamicElement.appendChild(nameField);
        dynamicElement.appendChild(jobField);
        dynamicElement.appendChild(emailField);
        dynamicElement.appendChild(phoneField);

        xmlBuilder.documentElement.appendChild(dynamicElement);
    });
}

function processFileCards(config) {
    var fileCards = document.querySelectorAll('[id^="file-card-id-"]');
    fileCards.forEach(function(filed, index) {
        var contactInsId = 'card-detail-' + index;
        var dynamicElement = getDynamicElement('FileCard', 'selection_break', 'keyword', contactInsId);

        dynamicElement.appendChild(createDynamicElement(config.nestedFields.priceName, 'text', 
            filed.querySelector('.file-name').textContent.trim(), contactInsId + '-name', false));

        if (resultList && resultList.length > 0) {
            resultList.forEach(function(result, resultIndex) {
                if (resultIndex === index) {
                    var dyEle = createDynamicElementForFile(result, config.nestedFields.locationPriceList);
                    dynamicElement.appendChild(dyEle);
                }
            });
        }

        if (articleIdFromUrl != null && fileValues != null) {
            fileValues.forEach(function(result, resultIndex) {
                if (resultIndex === index) {
                    var dyEle = createDynamicElementForFile(result, config.nestedFields.locationPriceList);
                    dynamicElement.appendChild(dyEle);
                }
            });
        }

        xmlBuilder.documentElement.appendChild(dynamicElement);
    });
}

function processPublisherImages(config) {
    var publisherCards = document.querySelectorAll('[id^="GMB-card-id-"]');
    publisherCards.forEach(function(filed, index) {
        var contactInsId = 'GMBcard-detail-' + index;
        var dynamicElement = getDynamicElement('PublisherImages', 'selection_break', 'keyword', contactInsId);

        dynamicElement.appendChild(createDynamicElement(config.nestedFields.publisher, 'text', 
            filed.querySelector('.file-Publisher').textContent.trim(), contactInsId + '-name', false));

        if (GMBFileList && GMBFileList.length > 0) {
            GMBFileList.forEach(function(result, resultIndex) {
                if (resultIndex === index) {
                    var dyEle = createDynamicElementForGMBFile(result, config.nestedFields.file);
                    dynamicElement.appendChild(dyEle);
                }
            });
        }

        if (articleIdFromUrl != null && GMBfileValues != null) {
            GMBfileValues.forEach(function(result, resultIndex) {
                if (resultIndex === index) {
                    var dyEle = createDynamicElementForGMBFile(result, config.nestedFields.file);
                    dynamicElement.appendChild(dyEle);
                }
            });
        }

        dynamicElement.appendChild(createDynamicElement(config.nestedFields.description, 'text', 
            filed.querySelector('.file-Description').textContent.trim(), contactInsId + '-desc', false));

        xmlBuilder.documentElement.appendChild(dynamicElement);
    });
}

function processAddPages(config) {
    var pageCards = document.querySelectorAll('[id^="page-card-id-"]');
    pageCards.forEach(function(addPages, index) {
        var contactInsId = 'page-detail-' + index;
        var dynamicElement = getDynamicElement('AddPage', 'selection_break', 'keyword', contactInsId);

        dynamicElement.appendChild(createDynamicElement(config.nestedFields.pageName, 'text', 
            addPages.querySelector('.page-name').textContent.trim(), contactInsId + '-name', false));
        dynamicElement.appendChild(createDynamicElement(config.nestedFields.pageUrl, 'text', 
            addPages.querySelector('.page-url').textContent.trim(), contactInsId + '-url', false));

        xmlBuilder.documentElement.appendChild(dynamicElement);
    });
}

function processProductCards(config) {
    var productCards = document.querySelectorAll('[id^="pro-link-card-id-"]');
    productCards.forEach(function(addProducts, index) {
        var contactInsId = 'product-detail-' + index;
        var dynamicElement = getDynamicElement('ProductCard', 'selection_break', 'keyword', contactInsId);

        var productCateId = addProducts.querySelector('.pro-link-name').getAttribute('id');
        if (productCateId) {
            finalProductsCategories.push(productCateId);
        }

        dynamicElement.appendChild(createDynamicElement(config.nestedFields.name, 'text', 
            addProducts.querySelector('.pro-link-name').textContent.trim(), contactInsId + '-name', false));
        dynamicElement.appendChild(createDynamicElement(config.nestedFields.link, 'text', 
            addProducts.querySelector('.pro-link').textContent.trim(), contactInsId + '-link', false));

        xmlBuilder.documentElement.appendChild(dynamicElement);
    });
}

function processLocationImage(config) {
    var fileInput = document.getElementById('fileInput');
    var file = fileInput.files[0];

    if (articleIdFromUrl != null && imageGlobal != null) {
        xmlBuilder.documentElement.appendChild(imageGlobal);
    } else if (file && file.size) {
        var dyEle = createDynamicElementForImage(uploadedImage, config.xmlFieldName);
        xmlBuilder.documentElement.appendChild(dyEle);
    }
}

function processRichText(config, instanceId) {
    var iframe = document.querySelector(config.elementId + ' iframe');
    var richData = iframe ? iframe.contentWindow.document.body.innerHTML : '';
    createDynamicElement(config.xmlFieldName, 'text', richData, instanceId, true);
}

function processYextRestrict(config, instanceId) {
    var checkBox = document.querySelector(config.elementId);
    var isChecked = checkBox.checked;
    createDynamicElement(config.xmlFieldName, 'text', isChecked ? 'true' : '', instanceId, true);
}

function processSimpleField(fieldId, config, instanceId) {
    var field = document.querySelector(config.elementId);
    if (field) {
        createDynamicElement(config.xmlFieldName, 'text', field.value, instanceId, true);
    }
}

// Helper functions remain the same as in your original code
function getDynamicElement(name, type, indexType, instanceId) {
    var dynamicElement = xmlBuilder.createElement('dynamic-element');
    dynamicElement.setAttribute('name', name);
    dynamicElement.setAttribute('type', type);
    dynamicElement.setAttribute('index-type', indexType);
    dynamicElement.setAttribute('instance-id', instanceId);
    return dynamicElement;
}

function createDynamicElement(name, type, value, instanceId, appendToRoot) {
    var dynamicElement = xmlBuilder.createElement('dynamic-element');
    dynamicElement.setAttribute('name', name);
    dynamicElement.setAttribute('type', type);
    dynamicElement.setAttribute('index-type', 'keyword');
    dynamicElement.setAttribute('instance-id', instanceId);

    var dynamicContent = xmlBuilder.createElement('dynamic-content');
    dynamicContent.setAttribute('language-id', '' + coutryLanguageId + '');

    var cdata = xmlBuilder.createCDATASection(value || '');
    dynamicContent.appendChild(cdata);
    dynamicElement.appendChild(dynamicContent);

    if (appendToRoot) {
        xmlBuilder.documentElement.appendChild(dynamicElement);
    }

    return dynamicElement;
}

function createDynamicElementForFile(documentResponse, xmlFieldName) {
    var filePath = '/documents/' + documentResponse.groupId + '/' + 
                   documentResponse.folderId + '/' + 
                   documentResponse.fileName + '/' + 
                   documentResponse.uuid + '?t=' + 
                   documentResponse.modifiedDate;

    return createDynamicElement(xmlFieldName, 'document_library', filePath, documentResponse.uuid, false);
}

function createDynamicElementForGMBFile(documentResponse, xmlFieldName) {
    var filePath = '/documents/' + documentResponse.groupId + '/' + 
                   documentResponse.folderId + '/' + 
                   documentResponse.fileName + '/' + 
                   documentResponse.uuid + '?t=' + 
                   documentResponse.modifiedDate;

    return createDynamicElement(xmlFieldName, 'document_library', filePath, documentResponse.uuid, false);
}

function createDynamicElementForImage(documentResponse, xmlFieldName) {
    var dynamicElement = xmlBuilder.createElement('dynamic-element');
    dynamicElement.setAttribute('name', xmlFieldName);
    dynamicElement.setAttribute('type', 'image');
    dynamicElement.setAttribute('index-type', 'text');
    dynamicElement.setAttribute('instance-id', 'sffadsfgdsadf');

    var dynamicContent = xmlBuilder.createElement('dynamic-content');
    dynamicContent.setAttribute('language-id', coutryLanguageId);
    dynamicContent.setAttribute('alt', documentResponse.fileName);
    dynamicContent.setAttribute('name', documentResponse.fileName);
    dynamicContent.setAttribute('title', documentResponse.fileName);
    dynamicContent.setAttribute('type', '