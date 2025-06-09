$('#download-selected').on('click', function () {
   getSelectedCheckBoxAndCSV();
   $('#download-options').hide();
});

$('#download-all').on('click', async function () {
   try {
      Toast.info(exportWait);
      $("#overlay").fadeIn(100);

      const articles = await fetchArticles();

      if (!articles || articles.length === 0) {
         Toast.danger(noLocations);
         return;
      }

      const promises = articles.map(async (article) => {
         return getWebcontentDataAsMap(article, null);
      });

      const locationData = await Promise.all(promises);

      let convertedLocationData = convertObjectTOCSVData(locationData);
      if (convertedLocationData) {
         downloadCSV(convertedLocationData, locationCSVName);
      }
      $("#overlay").fadeOut(100);
   } catch (error) {
      Toast.danger(exportError);
      console.error('Error fetching articles:', error);
      $("#overlay").fadeOut(100);
   }

   $('#csv-options').hide();

});

function getSelectedCheckBoxAndCSV() {

   if ($('.sub_chk:checked').length === 0) {
      Toast.danger(atleastOne);
      return;
   }

   $("#overlay").fadeIn(100);

   Toast.info(exportWait);
   var locationData = [];

   const promises = $(".sub_chk")
      .toArray()
      .filter((checkbox) => checkbox.checked)
      .map(async (checkbox) => {
         const value = $(checkbox).closest('tr').find('.location-id').text();
         return getWebcontentDataAsMap(null, value);
      });

   Promise.all(promises)
      .then((data) => {
         locationData = data;

         let convertedLocationData = convertObjectTOCSVData(locationData);
         if (convertedLocationData) {
            downloadCSV(convertedLocationData, locationCSVName)
         }
      })
      .catch((error) => {
         console.error(error);
         Toast.error(exportError);
         $("#overlay").fadeOut(100);
      });
}

var locationStructureFields = ["LocationId", "LocationTitle", "Address", "Address2", "TownCity", "Country", "Postcode", "PhoneNumber", "Monday_Separator", "Tuesday_Separator", "Wednesday_Separator", "Thursday_Separator", "Friday_Separator", "Saturday_Separator", "Sunday_Separator", "ProductCard", "ContactDetail", "Longitude", "Latitude", "isYextRestrict", "RichText", "PlantType", "CompanyName",
   "LocationImage", "FileCard", "AddPage", "PublisherImages", 'State', 'Region'
];

async function getWebcontentDataAsMap(providedWebContent, locationId) {
   try {
      var webContent = providedWebContent;
      if (!webContent) {
         webContent = await new Promise((resolve, reject) => {
            Liferay.Service('/journal.journalarticle/get-article', {
               groupId: countryGroupId,
               articleId: locationId
            }, function (webContent) {
               resolve(webContent);
            });
         });
      }

      var categories = await getWebcontentCategories(webContent.resourcePrimKey);
      var elementMap = new Map();

      if (categories && categories.length > 0) {
         elementMap.set("PlantType", [categories[0].titleCurrentValue + "(" + categories[0].categoryId + ")"]);
      }

      elementMap.set("LocationId", webContent.articleId);

      var xmlDoc = new DOMParser().parseFromString(webContent.content, 'application/xml');
      var dynamicElements = xmlDoc.getElementsByTagName('dynamic-element');

      for (var i = 0; i < dynamicElements.length; i++) {
         var dynamicElement = dynamicElements[i];
         var name = dynamicElement.getAttribute('name');

         if (!locationStructureFields.includes(name) && "GeolocationData" !== name) {
            continue;
         }

         var dynamicContent = dynamicElement.querySelector('dynamic-content');
         var value =  dynamicContent?.textContent ?? "";
         value = value.replaceAll("\n", "<br>")

         if (!elementMap.has(name))
            elementMap.set(name, []);

         if (!value) {
            elementMap.get(name).push('-');
            continue;
         }

         var nestedElements = dynamicElement.getElementsByTagName('dynamic-element');

         if (nestedElements.length > 0) {
            var cardNestedElements = dynamicElement.getElementsByTagName('dynamic-element');
            var nestedObjectGen = {};

            if (name.includes("_Separator")) {
               var closeEle = dynamicElement.querySelector('dynamic-element[name="isClosed' + name.replace("_Separator") + '"]');
               if (closeEle && closeEle.querySelector('dynamic-content').textContent == 'true') {
                  dayObject['isClosed'] = true;
                  elementMap.get(name).push(dayObject);
               } else {
                  for (let i = 0; i < dynamicElement.children.length; i++) {
                     let nestedElement = dynamicElement.children[i];
                     let nestedName = nestedElement.getAttribute('name');
                     let dayObject = {};

                     if (!nestedName.includes("isClosed")) {
                        for (let j = 0; j < nestedElement.children.length; j++) {
                           let typeOfDayElement = nestedElement.children[j];
                           let typeOfDayElementName = typeOfDayElement.getAttribute('name');
                           let dayElementValue = typeOfDayElement.querySelector('dynamic-content').textContent;

                           if (typeOfDayElementName.includes("Open")) {
                              if (dayElementValue) dayObject['openTime'] = dayElementValue;
                           } else {
                              if (dayElementValue) dayObject['closeTime'] = dayElementValue;
                           }
                        }
                        elementMap.get(name).push(dayObject);
                     }
                  }

               }


            } else {
               elementMap.get(name).push(dynamicElementToObjectList(cardNestedElements));
            }

         } else {

            if ("GeolocationData" === name) {
               var geoVal = JSON.parse(value);
               elementMap.set("Latitude", [geoVal.latitude]);
               elementMap.set("Longitude", [geoVal.longitude]);
            } else if ("LocationImage" === name) {
               if (value) {
                  var fileEntryId = dynamicContent.getAttribute('fileEntryId');
                  elementMap.get(name).push(value + "?fileEntryId=" + fileEntryId);
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

function convertObjectTOCSVData(locationData) {
   if (locationData.length === 0) {
      return null;
   }
   var csvContent = locationStructureFields.join(",") + '\n';

   locationData.forEach(location => {
      var csvRow = '';

      locationStructureFields.forEach(field => {
         var locationFieldValue = location.get(field);

         if (Array.isArray(locationFieldValue) && locationFieldValue.length !== 0) {
            if (field === "ContactDetail" || field === "FileCard" || field === "ProductCard" || field === "AddPage" || field === "PublisherImages" || field.includes("_Separator")) {
               if (locationFieldValue.length == 1 && locationFieldValue[0] == '-') {
                  if (field.includes("_Separator")) csvRow += '"' + 'Closed' + '",';
                  else csvRow += '"' + '-' + '",';
               } else {
                  var contactDetailData = locationFieldValue.map((contact, index) => {
                     return Object.entries(contact)
                        .map(([key, value]) => (key + "_" + (index + 1)) + " : " + ((value !== undefined) ? value : "-"))
                        .join(", ");
                  });
                  csvRow += '"' + contactDetailData.join("\n") + '",';
               }


            } else {
               if (locationFieldValue.length === 1 && field === "isYextRestrict") {
                  csvRow += '"' + (locationFieldValue[0] ? locationFieldValue[0] : "false") + '",';
               } else {
                  csvRow += '"' + locationFieldValue.join(",") + '",';
               }

            }
         } else {
            csvRow += '"' + (((locationFieldValue !== undefined) && (locationFieldValue !== null) && (locationFieldValue !== "")) ? locationFieldValue : "-") + '",';
         }
      });

      csvContent += csvRow.slice(0, -1) + '\n';
   });

   return csvContent;
}

function downloadCSV(csvData, fileName) {
   const csvFile = new Blob([csvData], {
      type: 'text/csv'
   });
   const downloadLink = document.createElement('a');
   downloadLink.href = window.URL.createObjectURL(csvFile);
   downloadLink.download = fileName;

   document.body.appendChild(downloadLink);
   downloadLink.click();
   document.body.removeChild(downloadLink);
   Toast.success(selectedDownloaded);
   $("#overlay").fadeOut(100);
}

async function getWebcontentCategories(resourcePK) {
   return new Promise((resolve, reject) => {
      Liferay.Service(
         '/assetcategory/get-categories', {
            className: 'com.liferay.journal.model.JournalArticle',
            classPK: parseInt(resourcePK)
         },
         function (obj) {
            resolve(obj);
         }
      );
   });
}