var countryGroupId = parseInt(themeDisplay.getSiteGroupId());
var countryLanguageId = 'en_GB';

var articleStructureId = 33884;
var articleTemplateId = '33913';
var guestRoleId= 20102;
var articleClassName = 'com.liferay.journal.model.JournalArticle';
var fileEntryClassName = 'com.liferay.document.library.kernel.model.DLFileEntry'

var listOfEUCountries = [
    { name: 'United Kingdom', languageId: 'en_GB', wcmFolderId: 33917, documentMediaFolderId: 33920, csvParentFodlerId: 33922, productParentCatId: 33237, productTypeVocId: 33236,layoutUUID: "",code: "GB", thanksPage: "/web/cemex-uk/location-thanks"}
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