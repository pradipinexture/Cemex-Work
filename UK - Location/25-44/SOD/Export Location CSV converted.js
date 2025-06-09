document.getElementById('download-selected').addEventListener('click', function () {
    getSelectedCheckBoxAndCSV();
    document.getElementById('download-options').style.display = 'none';
});

document.getElementById('download-all').addEventListener('click', async function () {
    try {
        Toast.info(exportWait);
        document.getElementById('overlay').style.display = 'block';

        const articles = await fetchArticles();

        if (!articles || articles.length === 0) {
            Toast.danger(noLocations);
            return;
        }

        const promises = articles.map(async (article) => {
            return getWebcontentDataAsMap(article, null);
        });

        const locationData = await Promise.all(promises);

        const convertedLocationData = convertObjectTOCSVData(locationData);
        if (convertedLocationData) {
            downloadCSV(convertedLocationData, locationCSVName);
        }
        document.getElementById('overlay').style.display = 'none';
    } catch (error) {
        Toast.danger(exportError);
        console.error('Error fetching articles:', error);
        document.getElementById('overlay').style.display = 'none';
    }

    document.getElementById('csv-options').style.display = 'none';
});

function getSelectedCheckBoxAndCSV() {
    const checkboxes = document.querySelectorAll('.sub_chk:checked');
    if (checkboxes.length === 0) {
        Toast.danger(atleastOne);
        return;
    }

    document.getElementById('overlay').style.display = 'block';
    Toast.info(exportWait);
    const locationData = [];

    const promises = Array.from(checkboxes).map(async (checkbox) => {
        const value = checkbox.closest('tr').querySelector('.location-id').textContent.trim();
        return getWebcontentDataAsMap(null, value);
    });

    Promise.all(promises)
        .then((data) => {
            locationData.push(...data);
            const convertedLocationData = convertObjectTOCSVData(locationData);
            if (convertedLocationData) {
                downloadCSV(convertedLocationData, locationCSVName);
            }
        })
        .catch((error) => {
            console.error(error);
            Toast.error(exportError);
            document.getElementById('overlay').style.display = 'none';
        });
}

async function getWebcontentDataAsMap(providedWebContent, locationId) {
    try {
        let webContent = providedWebContent;
        if (!webContent) {
            webContent = await new Promise((resolve, reject) => {
                Liferay.Service('/journal.journalarticle/get-article', {
                    groupId: countryGroupId,
                    articleId: locationId
                }, resolve);
            });
        }

        const categories = await getWebcontentCategories(webContent.resourcePrimKey);
        const elementMap = new Map();

        if (categories && categories.length > 0) {
            const categoryStrings = categories.map(function(category) {
                return category.titleCurrentValue;
            });

            elementMap.set("PlantType", [categoryStrings.join(", ")]);
        }

        elementMap.set("LocationId", webContent.articleId);

        const xmlDoc = new DOMParser().parseFromString(webContent.content, 'application/xml');
        const dynamicElements = xmlDoc.getElementsByTagName('dynamic-element');

        for (let dynamicElement of dynamicElements) {
            const name = dynamicElement.getAttribute('name');

            if (!locationStructureFields.includes(name) && name !== "GeolocationData") {
                continue;
            }

            const dynamicContent = dynamicElement.querySelector('dynamic-content');
            let value = dynamicContent?.textContent || '';
            value = value.replace(/\n/g, "<br>");

            if (!elementMap.has(name)) elementMap.set(name, []);

            if (!value) {
                elementMap.get(name).push('-');
                continue;
            }

            const nestedElements = dynamicElement.getElementsByTagName('dynamic-element');
            if (nestedElements.length > 0) {
                if (name.includes("_Separator")) {
                    const dayObject = {};
                    const isClosedElement = dynamicElement.querySelector(`[name="isClosed${name.replace("_Separator", "")}"]`);
                    if (isClosedElement && isClosedElement.querySelector('dynamic-content').textContent === 'true') {
                        dayObject['isClosed'] = true;
                        elementMap.get(name).push(dayObject);
                    } else {
                        for (let nestedElement of nestedElements) {
                            const nestedName = nestedElement.getAttribute('name');
                            const dayData = {};
                            if (!nestedName.includes("isClosed")) {
                                for (let typeOfDayElement of nestedElement.children) {
                                    const typeOfDayElementName = typeOfDayElement.getAttribute('name');
                                    const dayElementValue = typeOfDayElement.querySelector('dynamic-content').textContent;

                                    if (typeOfDayElementName.includes("Open")) {
                                        if (dayElementValue) dayData['openTime'] = dayElementValue;
                                    } else {
                                        if (dayElementValue) dayData['closeTime'] = dayElementValue;
                                    }
                                }
                                elementMap.get(name).push(dayData);
                            }
                        }
                    }
                } else {
                    const nestedObjectList = Array.from(nestedElements).map(el => dynamicElementToObjectList(el));
                    elementMap.get(name).push(nestedObjectList);
                }
            } else {
                if (name === "GeolocationData") {
                    const geoVal = JSON.parse(value);
                    elementMap.set("Latitude", [geoVal.latitude]);
                    elementMap.set("Longitude", [geoVal.longitude]);
                } else if (name === "LocationImage") {
                    if (value) {
                        const fileEntryId = dynamicContent.getAttribute('fileEntryId');
                        elementMap.get(name).push(`${value}?fileEntryId=${fileEntryId}`);
                    }
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

var locationStructureFields = ["LocationId", "LocationTitle", "Address", "Address2", "TownCity", "Country", "Postcode", "PhoneNumber", "Monday_Separator", "Tuesday_Separator", "Wednesday_Separator", "Thursday_Separator", "Friday_Separator", "Saturday_Separator", "Sunday_Separator", "ProductCard", "ContactDetail", "Longitude", "Latitude", "isYextRestrict", "RichText", "PlantType", "CompanyName",
   "LocationImage", "FileCard", "AddPage", "PublisherImages", 'State', 'Region'
];


function convertObjectTOCSVData(locationData) {
    if (locationData.length === 0) return null;

    const csvContent = [locationStructureFields.join(",")];

    locationData.forEach(location => {
        const csvRow = locationStructureFields.map(field => {
            const fieldValue = location.get(field);
            if (Array.isArray(fieldValue) && fieldValue.length > 0) {
                if (field.includes("_Separator")) {
                    return fieldValue[0] === '-' ? 'Closed' : JSON.stringify(fieldValue);
                } else {
                    return fieldValue.join(", ");
                }
            }
            return fieldValue || "-";
        }).join(",");
        csvContent.push(csvRow);
    });

    return csvContent.join("\n");
}

function downloadCSV(csvData, fileName) {
    const blob = new Blob([csvData], { type: 'text/csv' });
    const downloadLink = document.createElement('a');
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = fileName;

    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
    Toast.success(selectedDownloaded);
    document.getElementById('overlay').style.display = 'none';
}

async function getWebcontentCategories(resourcePK) {
    return new Promise((resolve, reject) => {
        Liferay.Service('/assetcategory/get-categories', {
            className: 'com.liferay.journal.model.JournalArticle',
            classPK: parseInt(resourcePK)
        }, resolve);
    });
}
