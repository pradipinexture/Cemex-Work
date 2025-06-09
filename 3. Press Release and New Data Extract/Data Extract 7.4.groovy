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

def countryToProcess = "United Kingdom" // Just Pass country name  from where we need to export the web contents (Cemex 7.0)

def configurations = [
    "United Kingdom": [
        country: "United Kingdom", 
        groupId: 45807659, 
        structureKey: "169349", 
        localeId: "en_GB"
    ]
]

structureFieldsMap = [:]
currentConfig = configurations[countryToProcess]
exportedContents = new ArrayList()

if (currentConfig == null) {
    println "Error: Configuration not found for country '${countryToProcess}'"
    println "Available countries: ${configurations.keySet()}. You can add new configuration for '${countryToProcess}' country."
    return
}

loadStructureFields()

def articles = JournalArticleLocalServiceUtil.getArticlesByStructureId(currentConfig.groupId, currentConfig.structureKey, -1, -1, null)

try {
    articles.each { article ->
        def locationJson = processXml(article.content)
        exportedContents.add(locationJson)
        println locationJson
    }
    
    //println exportedContents;
} catch (Exception e) {
    println("Error: " + e.getMessage())
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
        if(name == "body" || name == "summary") return
        //println name + " : "+type
        
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
    content = content.replace("<![CDATA[", "").replace("]]>", "").replace("<", "&lt;").replace(">", "&gt;")
    
    return content.trim()
}