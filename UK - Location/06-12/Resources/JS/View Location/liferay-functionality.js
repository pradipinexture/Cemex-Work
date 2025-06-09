function generateRandomString(length) {
   const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
   let randomString = '';
   for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * charset.length);
      randomString += charset[randomIndex];
   }
   return randomString;
}

function getArticle(locationId) {
    return new Promise((resolve, reject) => {
        Liferay.Service('/journal.journalarticle/get-article', {
            groupId: countryGroupId,
            articleId: locationId
        }, (result) => {
            if (result) {
                resolve(result);
            } else {
                reject(new Error('Failed to get article'));
            }
        });
    });
}

function createWebContentObject(webContent, updatedXMLString, articleProductCategories) {
    return {
        userId: webContent.userId,
        groupId: webContent.groupId,
        folderId: webContent.folderId,
        articleId: webContent.articleId,
        version: webContent.version,
        titleMap: getMapLiferay(webContent.titleCurrentValue),
        descriptionMap: getMapLiferay(""),
        content: updatedXMLString,
        layoutUuid: "",
        serviceContext: { assetCategoryIds: articleProductCategories }
    };
}

async function updateArticle(existingWebContent=null, locationformData, articleId, articleName, articleProductCategories, isCSV=false, isOpenClose=false) {
    try {
        let webContent = existingWebContent;
        
        if (!webContent) {
            webContent = await getArticle(articleId);
        }
        
        if (!webContent) {
            throw new Error('Web content not found');
        }

        const result = await new Promise((resolve, reject) => {
            Liferay.Service(
                '/journal.journalarticle/update-article',
                createWebContentObject(webContent, locationformData, articleProductCategories),
                (result) => {
                    Toast.success(articleName + " " + locationUpdateSuccess);        
                    resolve(result);
                },
                reject
            );
        });

        return result;

    } catch (error) {
        console.error("Error occurred while updating the location:", error);
        
        if (isCSV) {
            Toast.error(articleName + "(ID:" + articleId + ") " + missingCreate);
            return await addArticle(locationformData, articleName, articleProductCategories);
        } else {
            Toast.error(articleName + " " + locationUpdateFailMessage);
            throw error;
        }
    }
}

async function addArticle(xmlData, articleName, articleProductCategories) {
   try {
       var article = await new Promise((resolve, reject) => {
           Liferay.Service(
               '/journal.journalarticle/add-article',
               {
                  externalReferenceCode: '',
                  groupId: countryGroupId,
                  folderId: countryFolderId,
                  titleMap: getMapLiferay(articleName),
                  descriptionMap: getMapLiferay(""),
                  content: xmlData,
                  layoutUuid: "",
                  ddmStructureId: articleStructureId,
                  ddmTemplateKey: articleTemplateId,
                  serviceContext: { assetCategoryIds: articleProductCategories }
              },
               resolve,
               reject
           );
       });

       if (article) {
           await addResourcesToAsset(article.resourcePrimKey, articleClassName);
           Toast.success(articleName + " " +locationCreatedMessage);
       } else {
           Toast.error(articleName + " " + locationFailMessage);
    
       }
   } catch (error) {
        Toast.error(articleName + " " + locationFailMessage);
   }
}


function getMapLiferay(eleValue) {
  return {[countryLanguageId]: eleValue}
}

async function uploadFileToLiferay(fileInputId, folderId, fileName=null, isAssignDefaultPermission=false) {
  try {
      var fileInput = document.getElementById(fileInputId);
      if (!fileInput) {
          console.error("File input with id "+fileInputId+" not found");
          return null;
      }

      var file = fileInput.files[0];
      if (!file) {
          Toast.error(fileRequireValidation);
          return null;
      }

      var formData = new FormData();
      formData.append('repositoryId', themeDisplay.getScopeGroupId());
      formData.append('folderId', folderId);
      formData.append('sourceFileName', fileName ? fileName : file.name);
      formData.append('mimeType', file.type);
      formData.append('title', file.name);
      formData.append('description', '');
      formData.append('changeLog', '');
      formData.append('file', file);

      var response = await fetch('/api/jsonws/dlapp/add-file-entry', {
          method: 'POST',
          body: formData,
          headers: {'X-CSRF-Token': Liferay.authToken}
      });
      if (!response.ok) {    
          console.error('HTTP error! status: '+response.status);
          return null;
      }

      var fileUploadResponse = await response.json();

      if(isAssignDefaultPermission) await addResourcesToAsset(fileUploadResponse.fileEntryId, fileEntryClassName);

      return fileUploadResponse;                
  } catch (error) {
      console.error(error.message);
      return null;
  }
}

async function addResourcesToAsset(resourceId, className) {
   try {
       await new Promise((resolve, reject) => {
           Liferay.Service(
               '/resourcepermission/set-individual-resource-permissions',
               {
                   groupId: countryGroupId,
                   companyId: themeDisplay.getCompanyId(),
                   name: className,
                   primKey: resourceId,
                   roleId: guestRoleId,
                   actionIds: ['VIEW']
               },
               resolve,
               reject
           );
       });
   } catch (error) {
       console.log("Error while setting permission to location : "+error)
   }
}

async function createLiferayFolder(name) {
    try {
        var formData = new FormData();
        formData.append('repositoryId', themeDisplay.getScopeGroupId());
        formData.append('parentFolderId', csvParentFodlerId);
        formData.append('name', name);
        formData.append('description', name);
        formData.append('externalReferenceCode', '');

        var response = await fetch('/api/jsonws/dlapp/add-folder', {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-Token': Liferay.authToken
            }
        });

        if (!response.ok) console.error("Folder has not assigned to that parent folder.")

        var folder = await response.json();
        return folder;
    } catch (error) {
        console.error('Error creating folder:', error);
        return null;
    }
}

async function fetchArticles() {
   return new Promise((resolve, reject) => {
      Liferay.Service(
         '/journal.journalarticle/get-articles-by-structure-id', {
            groupId: countryGroupId,
            ddmStructureId: articleStructureId,
            start: -1,
            end: -1,
            '-orderByComparator': ''
         },
         function (obj) {
            resolve(obj);
         },
         function (error) {
            reject(error);
         }
      );
   });
}

var productTypeCategories = [];

async function getAllProductCategories() {
    try {
        var response = await new Promise((resolve, reject) => {
            Liferay.Service(
                '/assetcategory/get-vocabulary-categories',
                {
                    parentCategoryId: productParentCatId,
                    vocabularyId: productTypeVocId,
                    start: -1,
                    end: -1,
                    "-orderByComparator": ""
                },
                (result) => resolve(result),
                (error) => reject(error)
            );
        });
        productTypeCategories = response;
        return response;
    } catch (error) {
        console.error("Error updating product dropdown options:", error);
        throw error;
    }
}

async function findCategoryId(productName) {    
    var category = productTypeCategories.find(
        cat => cat.titleCurrentValue.toLowerCase() === productName.toLowerCase()
    );
    return category ? category.categoryId : null;
}

async function getCategoryIdByName(productName) {
    try {
        if (!productTypeCategories || productTypeCategories.length === 0) {
            await getAllProductCategories();
        }

        var categoryId = await findCategoryId(productName);
        return categoryId;
    } catch (error) {
        console.error("Error getting category ID by name:", error);
        throw error;
    }
}

async function getWebcontentCategories(resourcePK) {
 return new Promise((resolve, reject) => {
   Liferay.Service(
     '/assetcategory/get-categories',
       {
           className: articleClassName,
           classPK: parseInt(resourcePK)
       },
       function(obj) {
         resolve(obj);
       }
   );
   });
}
