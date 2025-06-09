var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
var countryLanguageId = themeDisplay.getLanguageId();

var articleStructureId = 38304;
var articleTemplateId = '38405';
var guestRoleId= 20123;
var articleClassName = 'com.liferay.journal.model.JournalArticle';
var fileEntryClassName = 'com.liferay.document.library.kernel.model.DLFileEntry'

var listOfEUCountries = [
    { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 39338, documentMediaFolderId: 43560, csvParentFodlerId: 46690, productParentCatId: 41361, productTypeVocId: 41357,layoutUUID: "",code: "GB", thanksPage: "/en-GB/web/location-application-uk/location-thanks"}
];

var countryFolderId;
var documentMediaFolderId;
var csvParentFodlerId;
var currentCountry = "GB";
var productParentCatId;
var productTypeVocId;
var thanksPage;

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
