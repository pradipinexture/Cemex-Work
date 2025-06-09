function resetCSVModal() {
    document.getElementById('filename').value = '';
    
    var fileInput = document.getElementById('file');
    var label = document.querySelector('label[for="file"]');

    fileInput.value = '';
    label.textContent = chooseFile +' : ';
}

function readFileAsText(file) {
    return new Promise((resolve, reject) => {
        if (!(file instanceof Blob)) {
            file = new Blob([file], { type: 'text/csv' });
        }
        var reader = new FileReader();
        reader.onload = event => resolve(event.target.result);
        reader.onerror = reject;
        reader.readAsText(file);
    });
}

document.getElementById('file').addEventListener('change', async function() {    
    var fileInput = document.getElementById("file");
    if (!fileInput) return null;

    var file = fileInput.files[0];
    if (!file) return null;

    document.querySelector('label[for="file"]').textContent = file.name;
});

var csvContent;

document.getElementById('save-csv-file').addEventListener('click', async (e) => {
    var folderName = document.getElementById('filename').value || '-';
    var fileLabel = document.querySelector('label[for="file"]');

     try {
        var userName = themeDisplay.getUserName();
        var folder = await createLiferayFolder((folderName+"_"+userName), csvParentFodlerId);
        if (!folder) {
            console.log(folderCreationFail);
            return;
        }

        var uploadedFile = await uploadFileToLiferay("file", folder.folderId);
        if (!uploadedFile) {
            console.log(uploadFileCreationFail);
            return;
        } 
        Toast.success(fileDataUploadSuccess);
        
        var fileInput = document.getElementById("file");
        if (!fileInput) {
            console.error("File input with id "+fileInputId+" not found");
            return null;
        }

        var file = fileInput.files[0];
        if (!file) {
            Toast.error(fileRequireValidation);
            return null;
        }  

        document.querySelector("#bs-file-modal").classList.remove("open")
        showLoader(true);

        csvContent = await readFileAsText(file);

        csvContent = csvContent.replace(/\n(?=ContactName_)/g, '<br>');
        csvContent = csvContent.replace(/\n(?=PriceName_)/g, '<br>');
        csvContent = csvContent.replace(/\n(?=Publisher_)/g, '<br>');
        csvContent = csvContent.replace(/\n(?=PageName_)/g, '<br>');
        csvContent = csvContent.replace(/\n(?=openTime_)/g, '<br>');
        csvContent = csvContent.replace(/\n(?=Name_)/g, '<br>');

        var lines = csvContent.split('\n').filter(line => line.trim() !== '');
        var headers = lines[0].trim().split(',');

        for(var csvLine = 1; csvLine < lines.length; csvLine++) {
            var generatedArticleResource = await processCSVData(lines[csvLine], headers);
            console.log(generatedArticleResource);

            if(generatedArticleResource.locationId && generatedArticleResource.locationId != "-") {
                await updateArticle(generatedArticleResource.xmlData, generatedArticleResource.locationId, generatedArticleResource.name, generatedArticleResource.articleProductCategories, true);
            } else {
                await addArticle(generatedArticleResource.xmlData, generatedArticleResource.name, generatedArticleResource.articleProductCategories);
            }
        }

        resetCSVModal()
        showLoader();
    } catch (error) {
        console.error('Error in processing:', error);
        showLoader();
    }
});

resetCSVModal();

async function processCSVData(line, headers) {
    var xmlBuilder = document.implementation.createDocument(null, null);
    var declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
    xmlBuilder.appendChild(declaration);

    var rootElement = xmlBuilder.createElement('root');
    rootElement.setAttribute('available-locales', coutryLanguageId);
    rootElement.setAttribute('default-locale', coutryLanguageId);
    rootElement.setAttribute('version', '1.0');
    xmlBuilder.appendChild(rootElement);
    
    var articleProductCategories  = [];
    if (!line.trim()) return;

    var columns = parseCSVLine(line);
    var locationName = '';
    var locationId = '';
    var geoData = {"lng":"","lat":""};
    for (let j = 0; j < headers.length; j++) {
        var header = headers[j].trim();
        var value = columns[j]?.trim() || '';

        if (!value || value === '-') continue;

        if (header === 'ContactDetail' || 
            header === 'FileCard' || 
            header === 'PublisherImages' || 
            header === 'AddPage' || 
            header === 'ProductCard') {
            await processNestedFields(header, value);
        } else if (header == 'Latitude' || header == 'Longitude') {
            (header == 'Latitude') ? geoData.lat = value : geoData.lng = value; 
        } else if (header === 'PlantType') {
            articleProductCategories = await Promise.all(
                value.split(',')
                    .map(item => item.trim())
                    .map(item => getCategoryIdByName(item))
            );
        } else if (header.endsWith('day')) {
            await processOpeningHours(header, value)
        } else {
            await processSimpleField(header, value);
        }
    }

    await createDynamicElement(locationFieldsIds["Geolocation"].xmlFieldName, "Geolocation", locationFieldsIds["Geolocation"].type, JSON.stringify(geoData), true);

    async function processOpeningHours(dayName, value) {
        var isClosed = false;
        var config = locationFieldsIds["OpeningHours"];
        var openingNested = config.nestedFields;
        var openingDynamicElement = await getDynamicElement(config.xmlFieldName, "OpeningHours", config.type, '');
        var dayNameElement = await createDynamicElement(openingNested.dayName.xmlFieldName, "DayName", openingNested.dayName.type, dayName, false);
        openingDynamicElement.appendChild(dayNameElement);
        
        if(value && value.trim() == "Closed") {
            isClosed = true;
            var openCloseParentElem = await generateOpenCloseElement(config)
            openingDynamicElement.appendChild(openCloseParentElem);
        } else {
            var lines = value.split('\n');
            for (var line of lines) {
                var matches = line.match(/openTime_(\d+)\s*:\s*(\d{2}:\d{2}),\s*closeTime_\1\s*:\s*(\d{2}:\d{2})/g);
                
                if (matches) {
                    // Process each match sequentially
                    for (var match of matches) {
                        var [periodNum, openTime, closeTime] = match.match(/(\d+)\s*:\s*(\d{2}:\d{2}).*?(\d{2}:\d{2})/).slice(1);
                        if(openTime && closeTime) { 
                            var openCloseParentElem = await generateOpenCloseElement(config, openTime, closeTime);
                            openingDynamicElement.appendChild(openCloseParentElem);
                        }
                    }
                }
            }
        }
        
        var isClosedElement = await createDynamicElement(openingNested.isClosed.xmlFieldName, "isClosed", openingNested.isClosed.type, isClosed, false);
        openingDynamicElement.appendChild(isClosedElement);
        xmlBuilder.documentElement.appendChild(openingDynamicElement);
    }

    async function generateOpenCloseElement(config, openTime="", closeTime="") {
        var opClsParentConfig = config.nestedFields.timeSlots;
        var opClsConfig  = opClsParentConfig.nestedFields;
        var opClsParentElement = await getDynamicElement(opClsParentConfig.xmlFieldName, "Fieldset54865370", opClsParentConfig.type, '');
        var openElement = await createDynamicElement(opClsConfig.open.xmlFieldName, "Open", opClsConfig.open.type, openTime, false);
        var closeElement = await createDynamicElement(opClsConfig.close.xmlFieldName, "Close", opClsConfig.close.type, closeTime, false);
        opClsParentElement.appendChild(openElement);
        opClsParentElement.appendChild(closeElement);
        return opClsParentElement;
    }

    async function processSimpleField(fieldId, value) {
        var config = locationFieldsIds[fieldId];
        if(fieldId == "LocationId") locationId = value;
        if(!value || value == "-"|| !config) return;
        if(fieldId == "LocationName") locationName = value;

        await createDynamicElement(config.xmlFieldName, fieldId, config.type, value, true);
    }

    async function processNestedFields(header, value) {
        var config = locationFieldsIds[header];

        var contacts = value.split('<br>');
        for (var contact of contacts) {
            var dynamicElement = await getDynamicElement(config.xmlFieldName, header, config.type, '');
            var details = contact.split(', ');
            
            for (var detail of details) {
                var [rawKey, val] = detail.split(' : ').map(str => str.trim());
                var key = rawKey.split('_')[0];

                if (!key || !val) continue;

                var fieldConfig = config["nestedFields"][key.charAt(0).toLowerCase() + key.slice(1)];
                if(config.type == "image") continue;

                var fieldGenXML = await createDynamicElement(fieldConfig.xmlFieldName, key, fieldConfig.type, val, false);
                dynamicElement.appendChild(fieldGenXML);
            }

            xmlBuilder.documentElement.appendChild(dynamicElement);
        }
    }

    async function getDynamicElement(name, fieldReference, type, indexType) {
        var dynamicElement = xmlBuilder.createElement('dynamic-element');
        dynamicElement.setAttribute('field-reference', fieldReference);
        dynamicElement.setAttribute('index-type', indexType);
        dynamicElement.setAttribute('instance-id', await getRandomString(5));
        dynamicElement.setAttribute('name', name);
        dynamicElement.setAttribute('type', type);
        
        return dynamicElement;
    }

    function convertCSVJsonToXMLJSON(str) {
        var replacedStr = str.replaceAll('\\', '\"');

        var cleanStr = replacedStr.startsWith('"') && replacedStr.endsWith('"') 
            ? replacedStr.slice(1, -1) 
            : replacedStr;
        return JSON.parse(cleanStr);
    }
    
    async function createDynamicElement(name, fieldReference, type, value, appendToRoot) {
        var dynamicElement = xmlBuilder.createElement('dynamic-element');
        dynamicElement.setAttribute('field-reference', fieldReference);
        dynamicElement.setAttribute('index-type', 'keyword');
        dynamicElement.setAttribute('instance-id', await getRandomString(5));
        dynamicElement.setAttribute('name', name);
        dynamicElement.setAttribute('type', type);
        
        if(type == 'document_library' || type == 'image') {
            value = JSON.stringify(convertCSVJsonToXMLJSON(value));
        }

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
     
    return { 
        locationId : locationId,
        name : locationName,
        xmlData: new XMLSerializer().serializeToString(xmlBuilder),
        articleProductCategories: articleProductCategories
    };
}

async function getRandomString(length) {
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

function parseCSVLine(line) {
    var columns = [];
    let currentColumn = '';
    let insideQuotes = false;

    for (let char of line) {
        if (char === '"') {
            insideQuotes = !insideQuotes;
        } else if (char === ',' && !insideQuotes) {
            columns.push(currentColumn.trim());
            currentColumn = '';
        } else {
            currentColumn += char;
        }
    }

    columns.push(currentColumn.trim());
    return columns;
}

