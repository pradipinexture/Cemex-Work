document.getElementById('download-selected').addEventListener('click', async function () {
    showLoader(true)
    try {
        var locationRows = getSelectedRows();

        if (locationRows.length === 0) {
            Toast.error(atleastOne);
            showLoader();
            return;
        }

        var jsonLocations = await Promise.all(locationRows.map(loc => getWebcontentDataAsMap(null, loc.id)));
        console.log(jsonLocations);
        var convertedLocationData = await convertObjectTOCSVData(jsonLocations);

        if (convertedLocationData) {await downloadCSV(convertedLocationData, locationCSVName)}
        showLoader();
    } catch (error) {
        console.error('Error downloading locations:', error);
        Toast.error('Failed to download locations');
        showLoader()
    }
});

document.getElementById('download-all').addEventListener('click', async function () {
    try {
        showLoader(true);
        Toast.info(exportWait);

        var articles = await fetchArticles();

        if (!articles || articles.length === 0) {
            Toast.error(noLocations);
            showLoader();
            return;
        }

        var jsonLocations = await Promise.all(
            articles.map(loc => getWebcontentDataAsMap(loc, loc.id))
        );

        console.log(jsonLocations);
        var convertedLocationData = await convertObjectTOCSVData(jsonLocations);

        if (convertedLocationData) {
            await downloadCSV(convertedLocationData, locationCSVName);
        }
        showLoader()
    } catch (error) {
        Toast.error(exportError);
        console.error('Error fetching articles:', error);
        showLoader(true);
    }

    
});

var locationStructureFields = ["LocationId", "LocationName", "Address", "Address2", "TownCity", "Country", "Postcode", "PhoneNumber", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "ProductCard", "ContactDetail", "Longitude", "Latitude", "isYextRestrict", "RichText", "PlantType", "CompanyName", "LocationImage", "FileCard", "AddPage", "PublisherImages", 'State', 'Region', 'isLocationClosed'];

async function getWebcontentDataAsMap(providedWebContent, locationId) {
    try {
        let webContent = providedWebContent;
        if (!webContent) {
            webContent = await new Promise((resolve, reject) => {
                Liferay.Service('/journal.journalarticle/get-article', {
                    groupId: countryGroupId,
                    articleId: locationId
                }, function(result, error) {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(result);
                    }
                });
            });
        }

        var categories = await getWebcontentCategories(webContent.resourcePrimKey);
        var elementMap = new Map();

        if (categories && categories.length > 0) {
            var categoryStrings = categories.map(category => category.titleCurrentValue);
            elementMap.set("PlantType", [categoryStrings.join(", ")]);
        }

        elementMap.set("LocationId", webContent.articleId);

        var xmlDoc = new DOMParser().parseFromString(webContent.content, 'application/xml');
        var rootElement = xmlDoc.querySelector('root');
        var dynamicElements = rootElement.children;

        for (var dynamicElement of dynamicElements) {
            var fieldRefValue = dynamicElement.getAttribute('name');
            var name = dynamicElement.getAttribute('field-reference');

            var dynamicContent = dynamicElement.querySelector('dynamic-content');
            let value = dynamicContent?.textContent || '';
            value = value.replace(/\n/g, "<br>");

            if (!elementMap.has(name)) elementMap.set(name, []);

            if (!value) {
                elementMap.get(name).push('-');
                continue;
            }

            var nestedElements = dynamicElement.getElementsByTagName('dynamic-element');
            
            if (nestedElements.length > 0) {
                if (name == "OpeningHours") {
                    var dayObj = {};
                    var dayValue = getElementValueByName(dynamicElement, locationFieldsIds[name].nestedFields.dayName.fieldName);
                    var opFieldNest = locationFieldsIds[name].nestedFields;
                    if (getElementValueByName(dynamicElement, locationFieldsIds[name].nestedFields.isClosed.fieldName) == "true") {
                        dayObj["isClosed"] = "true";
                    } else {
                        let openCloseCount = 1;
                        for (var op of nestedElements) {
                            var opName = op.getAttribute('field-reference');
                            if (opName != opFieldNest.timeSlots.fieldName) continue;

                            var dayOpenTime = getElementValueByName(op, opFieldNest.timeSlots.nestedFields.open.fieldName);
                            var dayCloseTime = getElementValueByName(op, opFieldNest.timeSlots.nestedFields.close.fieldName);
                            
                            if(!dayOpenTime || !dayCloseTime) continue;

                            dayObj["openTime" + openCloseCount] = dayOpenTime;
                            dayObj["closeTime" + openCloseCount++] = dayCloseTime;
                        }
                    }
                    elementMap.set(dayValue, [dayObj]);
                } else {
                    var nestedObjectList = dynamicElementToObjectList(nestedElements, name);
                    elementMap.get(name).push(nestedObjectList);
                }
            } else {
                if (name == "Geolocation") {
                    var mapCordi = JSON.parse(value);
                    elementMap.set("Latitude", [mapCordi.lat]);
                    elementMap.set("Longitude", [mapCordi.lng]);
                } else if (name == "LocationImage") {
                    elementMap.get(name).push(xmlJsonToString(value));
                } else {
                    elementMap.get(name).push(value);
                }
            }
        }
        return elementMap;
    } catch (error) {
        throw error;
    }
}

async function convertObjectTOCSVData(locationData) {
    if (locationData.length === 0) return null;

    var escapeField = function(value) {
        if (typeof value === 'string') return '"' + value.replace(/"/g, '""') + '"';
        return value;
    };

    var handleJsonField = function(value) {
        if (typeof value === 'object' && value !== null) return escapeField(JSON.stringify(value));
        return value;
    };

    var csvContent = [locationStructureFields.join(",")];
    
    var rows = await Promise.all(locationData.map(async function(location) {
        var fieldValues = await Promise.all(locationStructureFields.map(async function(field) {
            let fieldValue = location.get(field);
            if ((!fieldValue && field.endsWith("day")) || (fieldValue?.length > 0 && typeof fieldValue[0] === 'object' && !Object.keys(fieldValue[0]).length)) {
                return escapeField("Closed");
            }
            if(!fieldValue) return escapeField("-");

            if (Array.isArray(fieldValue) && fieldValue.length > 0) {
                if (field.endsWith("day")) {
                    if (fieldValue[0].isClosed == "true") {
                        return escapeField("Closed");
                    } else {
                        var timeEntries = Object.entries(fieldValue[0])
                            .map(function(entry) {
                                return entry[0].replace(/(\D+)(\d+)/, '$1_$2') + ' : ' + entry[1];
                            })
                            .reduce(function(acc, curr, i) {
                                return acc + (i % 2 === 0 ? (i === 0 ? "" : "\n") + curr : ", " + curr);
                            }, "");
                        return escapeField(timeEntries);
                    }
                } else if (!(fieldValue[0] instanceof Object)) {
                    return escapeField(fieldValue.join('", "'));
                } else {
                    var objString = fieldValue.map(function(item, i) {
                        return Object.keys(item).map(function(key) {
                            return key + '_' + (i + 1) + ' : ' + handleJsonField(item[key]);
                        }).join(',  ');
                    }).join('\n');
                    return escapeField(objString);
                }
            }

            fieldValue = handleJsonField(fieldValue);
            return fieldValue || escapeField("-");
        }));
        
        return fieldValues.join(',');
    }));
    
    csvContent.push(...rows);
    return csvContent.join("\n");
}

async function downloadCSV(csvData, fileName) {
    return new Promise((resolve, reject) => {
        try {
            var blob = new Blob([csvData], { type: 'text/csv' });
            var downloadLink = document.createElement('a');
            downloadLink.href = URL.createObjectURL(blob);
            downloadLink.download = fileName;

            document.body.appendChild(downloadLink);
            downloadLink.click();
            document.body.removeChild(downloadLink);
            Toast.success(selectedDownloaded);
            resolve();
        } catch (error) {
            reject(error);
        }
    });
}

function getElementValueByName(dynamicElement, key) {
    return dynamicElement.querySelector('dynamic-element[field-reference="' + key + '"]')?.querySelector('dynamic-content')?.textContent;
}


function xmlJsonToString(jsonString) {
    if(jsonString == "{}") return "-";
    const jsonObj = JSON.parse(jsonString);

    let csvSafeJson = JSON.stringify(jsonObj)
        .replace(/"/g, '\\"')
        .replace(/^(.+)$/, '"$1"');
    
    return csvSafeJson;
}

function dynamicElementToObjectList(cardNestedElements, name) {
    var nestedElementsObj = {};

    for (var nestedElement of cardNestedElements) {
        var nestedName = nestedElement.getAttribute('field-reference');
        var nestedType = nestedElement.getAttribute('type')
        var nestedContent = nestedElement.querySelector('dynamic-content');
        var nestedValue = nestedContent?.textContent;
        
        if(nestedType == "document_library") {
            nestedValue = xmlJsonToString(nestedValue);
        }

        nestedElementsObj[nestedName] = nestedValue;
    }
    return nestedElementsObj;
}