import com.liferay.journal.service.JournalArticleLocalServiceUtil
import com.liferay.portal.kernel.xml.SAXReaderUtil
import com.liferay.portal.kernel.xml.Document
import com.liferay.portal.kernel.xml.Element
import com.liferay.portal.kernel.json.JSONFactoryUtil
import com.liferay.portal.kernel.json.JSONObject
import com.liferay.portal.kernel.json.JSONArray
import com.liferay.dynamic.data.mapping.service.DDMStructureLocalServiceUtil
import com.liferay.journal.model.JournalArticle
import com.liferay.portal.kernel.util.PortalUtil
import com.liferay.portal.kernel.util.StringUtil
import com.liferay.document.library.kernel.service.DLAppLocalServiceUtil
import com.liferay.portal.kernel.service.ServiceContext
import com.liferay.portal.kernel.util.MimeTypesUtil
import com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil
import java.text.SimpleDateFormat
import java.util.Date

countryToProcess = "United Kingdom" // Country name from where we need to export the web contents (Cemex 7.0)

def configurations = [
    "United Kingdom": [
        country: "United Kingdom", 
        groupId: 45807659L,
        folderId: 108282896L,  
        structureKey: "169349", 
        localeId: "en_GB"
    ]
]

userId = 58951475L

structureFieldsMap = [:]
currentConfig = configurations[countryToProcess]
exportedContents = new ArrayList()

if (currentConfig == null) {
    println "Error: Configuration not found for country '${countryToProcess}'"
    println "Available countries: ${configurations.keySet()}. You can add new configuration for '${countryToProcess}' country."
    return
}

println "🚀 Starting export for: ${countryToProcess}"
println "📊 Loading structure fields..."

loadStructureFields()

println "📄 Fetching articles..."
def articles = JournalArticleLocalServiceUtil.getArticlesByStructureId(currentConfig.groupId, currentConfig.structureKey, -1, -1, null)

println "✨ Found ${articles.size()} articles to process"

try {
    articles.each { article ->
        def completeArticleData = processCompleteArticle(article)
        exportedContents.add(completeArticleData)
    }
    
    def finalJson = createFinalJson()
    
    uploadToDocumentsAndMedia(finalJson)
    
} catch (Exception e) {
    println "❌ Error during processing: " + e.getMessage()
    e.printStackTrace()
}

def processCompleteArticle(JournalArticle article) {
    try {
        def contentJson = processXml(article.content)
        
        JSONObject result = JSONFactoryUtil.createJSONObject()
        result.put("content", contentJson)
        
        result.put("articleId", article.getArticleId())
        result.put("title", article.getTitle(currentConfig.localeId))
        result.put("structureId", article.getDDMStructureKey())
        result.put("templateId", article.getDDMTemplateKey())
        
        def assetEntry = com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil.fetchEntry(
            JournalArticle.class.name, article.resourcePrimKey)
        if (assetEntry != null) {
            def categories = assetEntry.getCategories().collect { it.getName() }
            result.put("categories", JSONFactoryUtil.createJSONArray(categories))
        } else {
            result.put("categories", JSONFactoryUtil.createJSONArray())
        }

        result.put("version", article.getVersion())
        result.put("createDate", article.getCreateDate().toString())
        result.put("modifiedDate", article.getModifiedDate().toString())
        result.put("displayDate", article.getDisplayDate().toString())
        result.put("status", article.getStatus())
        result.put("userId", article.getUserId())
        result.put("userName", article.getUserName())
        
        return result
        
    } catch (Exception e) {
        println "❌ Error processing article ${article.getArticleId()}: ${e.getMessage()}"
        e.printStackTrace()
        return JSONFactoryUtil.createJSONObject()
    }
}
def loadStructureFields() {
    try {
        def structure = DDMStructureLocalServiceUtil.getStructure(
            currentConfig.groupId, 
            PortalUtil.getClassNameId(JournalArticle.class.getName()), 
            currentConfig.structureKey
        )
        
        JSONObject definitionJson = JSONFactoryUtil.createJSONObject(structure.definition)
        
        if (definitionJson.has("fields")) {
            JSONArray fields = definitionJson.getJSONArray("fields")
            
            for (int i = 0; i < fields.length(); i++) {
                JSONObject field = fields.getJSONObject(i)
                String fieldName = field.getString("name")
                
                String fieldLabel = ""
                
                if (field.has("label")) {
                    def label = field.getJSONObject("label")
                    if (label.has(currentConfig.localeId)) fieldLabel = label.getString(currentConfig.localeId)
                }
                
                if(!fieldLabel || fieldLabel.contains("Deprecated") || fieldLabel.contains("Depreacted")) continue
                structureFieldsMap.put(fieldName, fieldLabel)
            }
        }
        
        println "📋 Loaded ${structureFieldsMap.size()} structure fields"
        
    } catch (Exception e) {
        println "Error fetching structure fields: " + e.getMessage()
        e.printStackTrace()
    }
}

def processXml(String xmlContent) {
    try {
        Document document = SAXReaderUtil.read(xmlContent)
        Element rootElement = document.getRootElement()
        
        JSONObject result = processRootElement(rootElement)
        return result
    } catch (Exception e) {
        println("Error processing XML: " + e.getMessage())
        return JSONFactoryUtil.createJSONObject()
    }
}

def processRootElement(Element rootElement) {
    JSONObject result = JSONFactoryUtil.createJSONObject()
    
    Map<String, Integer> elementCounts = [:]
    
    rootElement.elements("dynamic-element").each { element ->
        String name = element.attributeValue("name")
        elementCounts[name] = (elementCounts[name] ?: 0) + 1
    }
    
    rootElement.elements("dynamic-element").each { element ->
        String name = element.attributeValue("name")
        String type = element.attributeValue("type")
        
        if (!structureFieldsMap.containsKey(name)) return
        
        name = structureFieldsMap.get(name);    

        boolean isRepeatable = elementCounts[name] > 1 || type == "selection_break"
        
        if (isRepeatable) {
            handleRepeatableElement(element, result, name)
        } else {
            handleSimpleElement(element, result, name)
        }
    }
    return result
}

def handleRepeatableElement(Element element, JSONObject result, String name) {
    JSONArray array
    if (result.has(name)) {
        array = result.getJSONArray(name)
    } else {
        array = JSONFactoryUtil.createJSONArray()
        result.put(name, array)
    }
    
    String type = element.attributeValue("type")
    
    if (type == "selection_break") {
        JSONObject item = JSONFactoryUtil.createJSONObject()
        boolean hasNonEmptyValue = false
        
        element.elements("dynamic-element").each { nestedElement ->
            String nestedName = nestedElement.attributeValue("name")
            Element contentElement = nestedElement.element("dynamic-content")
            if (contentElement != null) {
                String content = getElementContent(contentElement)
                if (content != null && !content.isEmpty()) {
                    item.put(nestedName, content)
                    hasNonEmptyValue = true
                }
            }
        }
 
        if (hasNonEmptyValue) array.put(item)
    } else {
        Element contentElement = element.element("dynamic-content")
        if (contentElement != null) {
            String content = getElementContent(contentElement)
            if (content != null && !content.isEmpty()) {
                array.put(content)
            }
        }
    }
 
    if (array.length() == 0) result.remove(name)
}

def handleSimpleElement(Element element, JSONObject result, String name) {
    Element contentElement = element.element("dynamic-content")
    if (contentElement != null) {
        result.put(name, getElementContent(contentElement))
    } else {
        result.put(name, "")
    }
}

def getElementContent(Element contentElement) {
    String content = contentElement.getText()
    content = content.replace("<![CDATA[", "").replace("]]>", "")
    
    return content.trim()
}

def createFinalJson() {
    JSONObject finalResult = JSONFactoryUtil.createJSONObject()

    finalResult.put("exportDate", new Date().toString())
    finalResult.put("country", countryToProcess)
    finalResult.put("structureKey", currentConfig.structureKey)
    finalResult.put("totalArticles", exportedContents.size())
    finalResult.put("groupId", currentConfig.groupId)
    finalResult.put("localeId", currentConfig.localeId)

    JSONArray contentArray = JSONFactoryUtil.createJSONArray()
    exportedContents.each { content ->
        contentArray.put(content)
    }
    finalResult.put("articles", contentArray)
    
    println "📦 Created final JSON with ${exportedContents.size()} articles"

    return finalResult.toString(2)
}

def uploadToDocumentsAndMedia(String jsonContent) {
    try {
        println "📤 Uploading to Documents and Media..."

        def timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date())
        def fileName = "web_content_export_${countryToProcess.replaceAll(' ', '_')}_${timestamp}.json"

        byte[] fileBytes = jsonContent.getBytes("UTF-8")
        String mimeType = "application/json"

        ServiceContext serviceContext = new ServiceContext()
        serviceContext.setScopeGroupId(currentConfig.groupId)
        serviceContext.setUserId(userId)

        def fileEntry = DLAppLocalServiceUtil.addFileEntry(
            userId,
            currentConfig.groupId,
            currentConfig.folderId,
            fileName,
            mimeType,
            fileName,
            "Exported web content from ${countryToProcess} - Generated on ${new Date()}",
            "Automated export script",
            fileBytes,
            serviceContext
        )

        println "✅ File uploaded successfully!"
        println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        println "📁 File ID: ${fileEntry.getFileEntryId()}"
        println "📄 File Name: ${fileEntry.getFileName()}"
        println "🔗 Liferay Portal Path: UK >> Documents and Media >> Home >> Press Release Import"
        println "📂 Folder ID: ${fileEntry.getFolderId()}"
        println "🔗 Download URL: /documents/${fileEntry.getGroupId()}/${fileEntry.getFolderId()}/${fileName}"
        println "📅 Created: ${fileEntry.getCreateDate()}"
        println "📋 Articles Exported: ${exportedContents.size()}"
        println "🌍 Country: ${countryToProcess}"
        println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
    } catch (Exception e) {
        println "❌ Error uploading file: ${e.getMessage()}"
    }
}