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

// ===== CONFIGURATION =====
countryToProcess = "United Kingdom" // Country name from where we need to export the web contents (Cemex 7.0)

// Documents and Media upload configuration
groupId = 45807659L
folderId = 61956508L  
userId = 58951475L

def configurations = [
    "United Kingdom": [
        country: "United Kingdom", 
        groupId: 45807659, 
        structureKey: "169349", 
        localeId: "en_GB"
    ]
]

// ===== VARIABLES =====
structureFieldsMap = [:]
currentConfig = configurations[countryToProcess]
exportedContents = new ArrayList()

// ===== MAIN EXECUTION =====
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
    
    // Create final JSON structure
    def finalJson = createFinalJson()
    
    // Upload to Documents and Media
    uploadToDocumentsAndMedia(finalJson)
    
} catch (Exception e) {
    println "❌ Error during processing: " + e.getMessage()
    e.printStackTrace()
}

// ===== EXPORT FUNCTIONS =====
def processCompleteArticle(JournalArticle article) {
    try {
        // Process XML content
        def contentJson = processXml(article.content)
        
        // Create complete result with metadata
        JSONObject result = JSONFactoryUtil.createJSONObject()
        result.put("content", contentJson)
        
        // Add metadata
        result.put("articleId", article.getArticleId())
        result.put("title", article.getTitle(currentConfig.localeId))
        result.put("structureId", article.getDDMStructureKey())
        result.put("templateId", article.getDDMTemplateKey())
        
        // Add categories
        def assetEntry = com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil.fetchEntry(
            JournalArticle.class.name, article.resourcePrimKey)
        if (assetEntry != null) {
            def categories = assetEntry.getCategories().collect { it.getName() }
            result.put("categories", JSONFactoryUtil.createJSONArray(categories))
        } else {
            result.put("categories", JSONFactoryUtil.createJSONArray())
        }
        
        // Add additional metadata
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

// ===== JSON CREATION =====
def createFinalJson() {
    JSONObject finalResult = JSONFactoryUtil.createJSONObject()
    
    // Add metadata
    finalResult.put("exportDate", new Date().toString())
    finalResult.put("country", countryToProcess)
    finalResult.put("structureKey", currentConfig.structureKey)
    finalResult.put("totalArticles", exportedContents.size())
    finalResult.put("groupId", currentConfig.groupId)
    finalResult.put("localeId", currentConfig.localeId)
    
    // Add exported content
    JSONArray contentArray = JSONFactoryUtil.createJSONArray()
    exportedContents.each { content ->
        contentArray.put(content)
    }
    finalResult.put("articles", contentArray)
    
    println "📦 Created final JSON with ${exportedContents.size()} articles"
    
    return finalResult.toString(2) // Pretty print with 2-space indentation
}

// ===== UPLOAD TO DOCUMENTS AND MEDIA =====
def uploadToDocumentsAndMedia(String jsonContent) {
    try {
        println "📤 Uploading to Documents and Media..."
        
        // Create filename with timestamp
        def timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date())
        def fileName = "web_content_export_${countryToProcess.replaceAll(' ', '_')}_${timestamp}.json"
        
        // Convert content to bytes
        byte[] fileBytes = jsonContent.getBytes("UTF-8")
        String mimeType = "application/json"
        
        // Create service context
        ServiceContext serviceContext = new ServiceContext()
        serviceContext.setScopeGroupId(groupId)
        serviceContext.setUserId(userId)
        
        // Upload file
        def fileEntry = DLAppLocalServiceUtil.addFileEntry(
            userId,         // userId
            groupId,        // repositoryId
            folderId,       // folderId
            fileName,       // sourceFileName
            mimeType,       // mimeType
            fileName,       // title
            "Exported web content from ${countryToProcess} - Generated on ${new Date()}", // description
            "Automated export script", // changeLog
            fileBytes,      // bytes
            serviceContext  // serviceContext
        )
        
        // Success message
        println "✅ File uploaded successfully!"
        println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        println "📁 File ID: ${fileEntry.getFileEntryId()}"
        println "📄 File Name: ${fileEntry.getFileName()}"
        println "📊 File Size: ${formatFileSize(fileEntry.getSize())}"
        println "📂 Folder ID: ${fileEntry.getFolderId()}"
        println "🔗 Download URL: /documents/${fileEntry.getGroupId()}/${fileEntry.getFolderId()}/${fileName}"
        println "📅 Created: ${fileEntry.getCreateDate()}"
        println "📋 Articles Exported: ${exportedContents.size()}"
        println "🌍 Country: ${countryToProcess}"
        println "📊 Data Includes: Content, Metadata, Categories, Dates, User Info"
        println "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
    } catch (Exception e) {
        println "❌ Error uploading file: ${e.getMessage()}"
        e.printStackTrace()
        
        // Print the JSON content to console as fallback
        println "\n🔄 Fallback - JSON Content:"
        println "=" * 50
        println jsonContent
        println "=" * 50
    }
}

// ===== UTILITY FUNCTIONS =====
def formatFileSize(long bytes) {
    if (bytes < 1024) return "${bytes} B"
    if (bytes < 1024 * 1024) return "${Math.round(bytes / 1024.0)} KB"
    if (bytes < 1024 * 1024 * 1024) return "${Math.round(bytes / (1024.0 * 1024.0))} MB"
    return "${Math.round(bytes / (1024.0 * 1024.0 * 1024.0))} GB"
}




/*

🚀 Starting export for: United Kingdom
📊 Loading structure fields...
📋 Loaded 6 structure fields
📄 Fetching articles...
✨ Found 1185 articles to process
📦 Created final JSON with 1185 articles
📤 Uploading to Documents and Media...
✅ File uploaded successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 File ID: 61956647
📄 File Name: web_content_export_United_Kingdom_20250606_113231.json
📊 File Size: 4 MB
📂 Folder ID: 61956508
🔗 Download URL: /documents/45807659/61956508/web_content_export_United_Kingdom_20250606_113231.json
📅 Created: Fri Jun 06 11:32:31 GMT 2025
📋 Articles Exported: 1185
🌍 Country: United Kingdom
📊 Data Includes: Content, Metadata, Categories, Dates, User Info
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

*/