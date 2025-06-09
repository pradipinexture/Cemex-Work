var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
var countryLanguageId = 'en_GB';

var articleStructureId = 1854942;
var articleTemplateId = '1854972';
var guestRoleId= 20105;
var articleClassName = 'com.liferay.journal.model.JournalArticle';
var fileEntryClassName = 'com.liferay.document.library.kernel.model.DLFileEntry'

var listOfEUCountries = [
    { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 1854975, documentMediaFolderId: 1854996, csvParentFodlerId: 1854994, productParentCatId: 1854873, productTypeVocId: 1854872,layoutUUID: "",code: "GB", thanksPage: "/en-GB/web/location-application-uk/location-thanks"}
];

var countryFolderId;
var documentMediaFolderId;
var csvParentFodlerId;
var currentCountry;
var productParentCatId;
var productTypeVocId;
var thanksPage;
var coutryLanguageId = themeDisplay.getLanguageId();

var currentCountryObj = listOfEUCountries.find(country => country.languageId === themeDisplay.getLanguageId());

if(currentCountryObj) {
   countryFolderId = currentCountryObj.wcmFolderId;
   documentMediaFolderId = currentCountryObj.documentMediaFolderId;
   currentCountry = currentCountryObj.code;
   csvParentFodlerId = currentCountryObj.csvParentFodlerId;
   productParentCatId = currentCountryObj.productParentCatId;
   productTypeVocId = currentCountryObj.productTypeVocId;
   thanksPage = currentCountryObj.thanksPage;
}
