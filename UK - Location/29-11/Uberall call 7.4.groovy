import com.liferay.journal.model.JournalArticle
import com.liferay.journal.service.JournalArticleLocalServiceUtil
import org.dom4j.Element
import org.dom4j.io.SAXReader
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

UBERALL_PRIVATE_KEY = "7a9fbf5be47f742c9540cd4682a926bffd2894603c86c320698530c9a4cf32ceefdf40942add9ec3ac7a3e92e08e950ea9548245cde5581feb6c0d312e54b653"
UBERALL_ENDPOINT = "https://sandbox.uberall.com/api/locations"
UBERALL_BUSINESS_ID = "2173914"
CONTEXT_PATH = "http://localhost:8080/documents/d/location-application-uk/"

def callUberallApi(Map locationData, JournalArticle article) {
    try {
        def jsonBody = JsonOutput.toJson(locationData)
        println "Request Body: ${JsonOutput.prettyPrint(jsonBody)}"
        
        // Determine if it's an update (PATCH) or create (POST)
        def isUpdate = article.getVersion() != 1
        def methodType = isUpdate ? "PATCH" : "POST"
        def endpoint = UBERALL_ENDPOINT
        
        // If it's an update, try to get existing location ID
        if (isUpdate) {
            def locationId = getUberallLocationByArticleId(article.getArticleId(), article.titleCurrentValue)
            if (locationId) {
                endpoint = "${UBERALL_ENDPOINT}/${locationId}"
            } else {
                methodType = "POST" // Fallback to POST if no existing location found
            }
        }
        
        println "Using endpoint: ${endpoint}"
        println "Method type: ${methodType}"
        
        def url = new URL(endpoint)
        def connection = url.openConnection()
        connection.setRequestMethod("POST")
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("privateKey", UBERALL_PRIVATE_KEY)
        connection.setRequestProperty("Cache-Control", "no-cache")
        
        if (methodType == "PATCH") {
            connection.setRequestProperty("X-HTTP-Method-Override", "PATCH")
        }
        
        connection.setDoOutput(true)
        
        def outputStream = connection.getOutputStream()
        outputStream.write(jsonBody.getBytes("UTF-8"))
        outputStream.flush()
        outputStream.close()
        
        def responseCode = connection.getResponseCode()
        def responseStream = responseCode >= 200 && responseCode < 300 ? 
            connection.getInputStream() : connection.getErrorStream()
        def response = responseStream.getText()
        
        if (responseCode >= 200 && responseCode < 300) {
            println "Successfully called Uberall API. Response: ${response}"
            return new JsonSlurper().parseText(response)
        } else if (responseCode == 409) { // Conflict - Handle duplicates
            def jsonResponse = new JsonSlurper().parseText(response)
            def duplicates = jsonResponse?.response?.duplicates
            
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
        println "Error calling Uberall API: ${e.message}"
        throw e
    }
}

def getUberallLocationByArticleId(String articleId, String articleName) {
    try {
        def urlString = "${UBERALL_ENDPOINT}?fieldMask=province&fieldMask=name&max=100000&selectAll=true"
        def connection = new URL(urlString).openConnection()
        connection.setRequestMethod('GET')
        connection.setRequestProperty('Content-Type', 'application/json')
        connection.setRequestProperty('privateKey', UBERALL_PRIVATE_KEY)
        
        def responseCode = connection.getResponseCode()
        if (responseCode == 200) {
            def jsonResponse = new JsonSlurper().parseText(connection.inputStream.text)
            def locations = jsonResponse?.response?.locations
            
            return locations?.find { location ->
                location.province == articleId || location.name == articleName
            }?.id
        }
        return null
    } catch (Exception e) {
        println "Error getting Uberall location: ${e.message}"
        return null
    }
}

try {
    long classPK = 53211
    JournalArticle article = JournalArticleLocalServiceUtil.getArticle(classPK)

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
    e.printStackTrace()
}