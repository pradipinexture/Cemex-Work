import com.liferay.journal.model.JournalArticle
import com.liferay.journal.service.JournalArticleLocalServiceUtil
import com.liferay.portal.kernel.service.GroupLocalServiceUtil
import com.liferay.expando.kernel.model.ExpandoBridge
import org.dom4j.Element
import org.dom4j.io.SAXReader
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

// Configuration constants
UBERALL_ENDPOINT_KEYNAME = "Uberall Endpoint"
UBERALL_BUSINESS_ID_KEYNAME = "Uberall Business Id"
UBERALL_PRIVATE_KEYNAME = "Uberall Private Key"
UBERALL_DUPLICATE_UPDATE_KEYNAME = "Uberall Update Workflow"
CEMEX_LIFERAY_DOMAIN = "localhost:8080"

println "=== Starting Uberall Integration Script ==="
println "Configuration Constants:"
println "UBERALL_ENDPOINT_KEYNAME: ${UBERALL_ENDPOINT_KEYNAME}"
println "UBERALL_BUSINESS_ID_KEYNAME: ${UBERALL_BUSINESS_ID_KEYNAME}"
println "UBERALL_PRIVATE_KEYNAME: ${UBERALL_PRIVATE_KEYNAME}"
println "UBERALL_DUPLICATE_UPDATE_KEYNAME: ${UBERALL_DUPLICATE_UPDATE_KEYNAME}"
println "CEMEX_LIFERAY_DOMAIN: ${CEMEX_LIFERAY_DOMAIN}"

// Get workflow context variables
String className = (String)workflowContext.get("entryClassName")
long classPK = Long.parseLong(workflowContext.get("entryClassPK"))
long groupId = Long.parseLong(workflowContext.get("groupId"))

println "\nWorkflow Context Variables:"
println "className: ${className}"
println "classPK: ${classPK}"
println "groupId: ${groupId}"

// Get Expando bridge and retrieve configuration
println "\nRetrieving ExpandoBridge configuration..."
ExpandoBridge expandoBridge = GroupLocalServiceUtil.getGroup(groupId).getExpandoBridge()
UBERALL_ENDPOINT = (String) expandoBridge.getAttribute(UBERALL_ENDPOINT_KEYNAME, false)
UBERALL_BUSINESS_ID = (String) expandoBridge.getAttribute(UBERALL_BUSINESS_ID_KEYNAME, false)
UBERALL_PRIVATE_KEY = (String) expandoBridge.getAttribute(UBERALL_PRIVATE_KEYNAME, false)
UBERALL_DUPLICATE_UPDATE = (Boolean) expandoBridge.getAttribute(UBERALL_DUPLICATE_UPDATE_KEYNAME, false)

println "Retrieved Configuration:"
println "UBERALL_ENDPOINT: ${UBERALL_ENDPOINT}"
println "UBERALL_BUSINESS_ID: ${UBERALL_BUSINESS_ID}"
println "UBERALL_PRIVATE_KEY: ${UBERALL_PRIVATE_KEY?.take(10)}..."
println "UBERALL_DUPLICATE_UPDATE: ${UBERALL_DUPLICATE_UPDATE}"

// Validate configuration
if (UBERALL_ENDPOINT == null || UBERALL_BUSINESS_ID == null || UBERALL_PRIVATE_KEY == null) {
    println "ERROR: Missing Uberall configuration. Skipping execution."
    return
}

UBERALL_API_ENDPOINT = UBERALL_ENDPOINT + "?businessIds=" + UBERALL_BUSINESS_ID
CONTEXT_PATH = CEMEX_LIFERAY_DOMAIN + "/documents/d/location-application-uk/"

println "\nConstructed Endpoints:"
println "UBERALL_API_ENDPOINT: ${UBERALL_API_ENDPOINT}"
println "CONTEXT_PATH: ${CONTEXT_PATH}"

def callUberallApi(Map locationData, JournalArticle article) {
    try {
        def jsonBody = JsonOutput.toJson(locationData)
        println "\n=== API Call Details ==="
        println "Request Body: ${JsonOutput.prettyPrint(jsonBody)}"
        
        // Determine if it's an update (PATCH) or create (POST)
        def isUpdate = article.getVersion() != 1
        def methodType = isUpdate ? "PATCH" : "POST"
        def endpoint = UBERALL_API_ENDPOINT
        
        println "\nArticle Details:"
        println "Article Version: ${article.getVersion()}"
        println "Is Update: ${isUpdate}"
        println "Initial Method Type: ${methodType}"
        
        // If it's an update, try to get existing location ID
        if (isUpdate) {
            println "\nChecking for existing location..."
            def locationId = getUberallLocationByArticleId(article.getArticleId(), article.titleCurrentValue)
            println "Found Location ID: ${locationId}"
            if (locationId) {
                endpoint = "${UBERALL_ENDPOINT}/${locationId}"
            } else {
                methodType = "POST" // Fallback to POST if no existing location found
                println "No existing location found, falling back to POST"
            }
        }
        
        println "\nFinal API Configuration:"
        println "Using endpoint: ${endpoint}"
        println "Final method type: ${methodType}"
        
        def url = new URL(endpoint)
        def connection = url.openConnection()
        connection.setRequestMethod("POST")
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("privateKey", UBERALL_PRIVATE_KEY)
        connection.setRequestProperty("Cache-Control", "no-cache")
        
        if (methodType == "PATCH") {
            connection.setRequestProperty("X-HTTP-Method-Override", "PATCH")
        }
        
        println "\nSending request..."
        connection.setDoOutput(true)
        
        def outputStream = connection.getOutputStream()
        outputStream.write(jsonBody.getBytes("UTF-8"))
        outputStream.flush()
        outputStream.close()
        
        def responseCode = connection.getResponseCode()
        println "Response Code: ${responseCode}"
        
        def responseStream = responseCode >= 200 && responseCode < 300 ? 
            connection.getInputStream() : connection.getErrorStream()
        def response = responseStream.getText()
        println "Response Body: ${response}"
        
        if (responseCode >= 200 && responseCode < 300) {
            println "Successfully called Uberall API"
            return new JsonSlurper().parseText(response)
        } else if (responseCode == 409 && UBERALL_DUPLICATE_UPDATE) {
            println "\nHandling duplicate location..."
            def jsonResponse = new JsonSlurper().parseText(response)
            def duplicates = jsonResponse?.response?.duplicates
            
            println "Found duplicates: ${duplicates}"
            
            if (duplicates && duplicates.size() > 0) {
                def duplicateId = duplicates[0]
                endpoint = "${UBERALL_ENDPOINT}/${duplicateId}"
                println "Found duplicate ID: ${duplicateId}, retrying with PATCH"
                locationData.put("id", duplicateId)
                return callUberallApi(locationData, article)
            }
            throw new Exception("Duplicate found but no ID available")
        } else {
            throw new Exception("Failed to call Uberall API: ${responseCode} - ${response}")
        }
        
    } catch (Exception e) {
        println "\nERROR in callUberallApi:"
        println "Error message: ${e.message}"
        println "Stack trace:"
        e.printStackTrace()
        throw e
    }
}

def getUberallLocationByArticleId(String articleId, String articleName) {
    try {
        println "\n=== Searching for existing location ==="
        println "Article ID: ${articleId}"
        println "Article Name: ${articleName}"
        
        def urlString = "${UBERALL_ENDPOINT}?fieldMask=province&fieldMask=name&max=100000&selectAll=true"
        println "Search URL: ${urlString}"
        
        def connection = new URL(urlString).openConnection()
        connection.setRequestMethod('GET')
        connection.setRequestProperty('Content-Type', 'application/json')
        connection.setRequestProperty('privateKey', UBERALL_PRIVATE_KEY)
        
        def responseCode = connection.getResponseCode()
        println "Search response code: ${responseCode}"
        
        if (responseCode == 200) {
            def jsonResponse = new JsonSlurper().parseText(connection.inputStream.text)
            def locations = jsonResponse?.response?.locations
            println "Found ${locations?.size()} total locations"
            
            def foundLocation = locations?.find { location ->
                location.province == articleId || location.name == articleName
            }
            
            println "Found matching location: ${foundLocation?.id}"
            return foundLocation?.id
        }
        println "No matching location found"
        return null
    } catch (Exception e) {
        println "\nERROR in getUberallLocationByArticleId:"
        println "Error message: ${e.message}"
        println "Stack trace:"
        e.printStackTrace()
        return null
    }
}

if (className.equals("com.liferay.journal.model.JournalArticle")) {
    println "\n=== Processing Journal Article ==="
    try {
        JournalArticle article = JournalArticleLocalServiceUtil.getArticle(classPK)
        println "Retrieved article with ID: ${article.getArticleId()}"
        println "Article version: ${article.getVersion()}"
        println "Article title: ${article.titleCurrentValue}"
        

        def jsonBuilder = [
            businessId: UBERALL_BUSINESS_ID,
            status: "ACTIVE", 
            province: article.getArticleId(),
            country: "UK",
            openingHours: [],
            photos: []
        ]

        def openingdays = [
            Monday: 1, Tuesday: 2, Wednesday: 3, 
            Thursday: 4, Friday: 5, Saturday: 6, Sunday: 7
        ]

        if (article) {
            def elements = new SAXReader().read(new StringReader(article.getContent()))
                            .getRootElement()
                            .elements("dynamic-element")
            def isYextRestricted = elements.find { 
                it.attributeValue("field-reference") == "isYextRestrict" 
            }?.element("dynamic-content")?.textTrim == "true"

            if (isYextRestricted) {
               elements.each { element ->
                   def key = element.attributeValue("field-reference")
                   def valueContent = element.element("dynamic-content")
                   
                   if (valueContent) {
                       def value = valueContent.textTrim

                       switch(key) {
                           case "Geolocation":
                               def geo = new JsonSlurper().parseText(value)
                               jsonBuilder.lng = geo.lng
                               jsonBuilder.lat = geo.lat
                               break
                           case "LocationName":
                               jsonBuilder.name = value
                               break
                           case "Address2":
                               jsonBuilder.street = value
                               break
                           case "Address": 
                               jsonBuilder.streetNo = value
                               break
                           case "Postcode":
                               jsonBuilder.zip = value
                               break
                           case "TownCity":
                               jsonBuilder.city = value
                               break
                           case "PhoneNumber":
                               jsonBuilder.phone = "+44${value}"
                               break
                           case "isLocationClosed":
                               jsonBuilder.status = value == "true" ? "CLOSED" : "ACTIVE"
                               break
                       }
                   } else if (key == "OpeningHours") {
                       def dayName = element.elements("dynamic-element").find { 
                           it.attributeValue("field-reference") == "DayName" 
                       }?.element("dynamic-content")?.textTrim
                       
                       if (dayName) {
                           def dayHours = [dayOfWeek: openingdays[dayName]]
                           def isClosed = element.elements("dynamic-element").find { 
                               it.attributeValue("field-reference") == "isClosed" 
                           }?.element("dynamic-content")?.textTrim == "true"
                           
                           if (isClosed) { 
                               dayHours.closed = true
                           } else {
                               def timeSlots = element.elements("dynamic-element").findAll { 
                                   it.attributeValue("field-reference") == "Fieldset54865370" 
                               }
                               
                               timeSlots.take(2).eachWithIndex { slot, idx ->
                                   def openTime = slot.elements("dynamic-element").find { 
                                       it.attributeValue("field-reference") == "Open" 
                                   }?.element("dynamic-content")?.textTrim
                                   def closeTime = slot.elements("dynamic-element").find { 
                                       it.attributeValue("field-reference") == "Close" 
                                   }?.element("dynamic-content")?.textTrim
                                   
                                   if (openTime && closeTime) {
                                       dayHours["from${idx + 1}"] = openTime
                                       dayHours["to${idx + 1}"] = closeTime
                                   }
                               }
                           }
                           jsonBuilder.openingHours << dayHours
                       }
                    } else if (key == "PublisherImages") {
                        try {
                            def publisherType = element.elements("dynamic-element").find { 
                                it.attributeValue("field-reference") == "Publisher" 
                            }?.element("dynamic-content")?.textTrim

                            def fileData = element.elements("dynamic-element").find { 
                                it.attributeValue("field-reference") == "File" 
                            }?.element("dynamic-content")?.textTrim

                            if (fileData) {
                                def fileJson = new JsonSlurper().parseText(fileData)
                                def filePath = CONTEXT_PATH + fileJson.title?.toLowerCase()?.replaceAll(/[^a-z0-9\s-]/, "-")?.replaceAll(/\s+/, "-")?.replaceAll(/-+/, "-")?.replaceAll(/^-+|-+$/, "") ?: ""
                                
                                jsonBuilder.photos << [
                                    main: false,
                                    logo: false,
                                    type: publisherType?.contains("Google") ? "LANDSCAPE" : 
                                          publisherType?.contains("Facebook") ? "FACEBOOK_LANDSCAPE" : "MAIN",
                                    url: filePath
                                ]
                            }
                        } catch (e) {
                            println "Error processing publisher image: ${e.message}"
                        }
                    }
               }
               
               println "Sending data to Uberall:"
               println JsonOutput.prettyPrint(JsonOutput.toJson(jsonBuilder))
               
               try {
                   def result = callUberallApi(jsonBuilder, article)
                   println "Uberall API call successful. Result: ${result}"
               } catch (Exception apiError) {
                   println "Failed to send data to Uberall: ${apiError.message}"
                   apiError.printStackTrace()
               }
            } else {
                println "Yext restrictions not enabled, skipping processing"
            }
        }


    } catch (Exception e) {
        println "\nERROR in main processing block:"
        println "Error message: ${e.message}"
        println "Stack trace:"
        e.printStackTrace()
    }
}