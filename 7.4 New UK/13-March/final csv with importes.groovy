import com.liferay.journal.model.JournalArticle
import com.liferay.journal.service.JournalArticleLocalServiceUtil
import com.liferay.portal.kernel.service.GroupLocalServiceUtil
import com.liferay.expando.kernel.model.ExpandoBridge
import org.dom4j.Element
import org.dom4j.io.SAXReader
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import com.liferay.portal.kernel.workflow.WorkflowStatusManagerUtil;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import java.net.URLEncoder;

println "Script execution started"

UBERALL_ENDPOINT_KEYNAME = "Uberall Endpoint"
UBERALL_BUSINESS_ID_KEYNAME = "Uberall Business Id"
UBERALL_PRIVATE_KEYNAME = "Uberall Private Key"
UBERALL_DUPLICATE_UPDATE_KEYNAME = "Uberall Update Workflow"

String className = (String)workflowContext.get("entryClassName")
long classPK = Long.parseLong(workflowContext.get("entryClassPK"))
groupId = Long.parseLong(workflowContext.get("groupId"))

println "Processing: className=${className}, classPK=${classPK}, groupId=${groupId}"

ExpandoBridge expandoBridge = GroupLocalServiceUtil.getGroup(groupId).getExpandoBridge()
UBERALL_ENDPOINT = (String) expandoBridge.getAttribute(UBERALL_ENDPOINT_KEYNAME, false)
UBERALL_BUSINESS_ID = (String) expandoBridge.getAttribute(UBERALL_BUSINESS_ID_KEYNAME, false)
UBERALL_PRIVATE_KEY = (String) expandoBridge.getAttribute(UBERALL_PRIVATE_KEYNAME, false)
UBERALL_DUPLICATE_UPDATE = (Boolean) expandoBridge.getAttribute(UBERALL_DUPLICATE_UPDATE_KEYNAME, false)

println "Configuration: Endpoint=${UBERALL_ENDPOINT}, BusinessID=${UBERALL_BUSINESS_ID}, DuplicateUpdate=${UBERALL_DUPLICATE_UPDATE}"

if (UBERALL_ENDPOINT == null || UBERALL_BUSINESS_ID == null || UBERALL_PRIVATE_KEY == null) {
	println "ERROR: Missing Uberall configuration. Skipping execution."
	return
}

UBERALL_API_ENDPOINT = UBERALL_ENDPOINT + "?businessIds=" + UBERALL_BUSINESS_ID

UBERALL_API_CALL = 0;

def callUberallApi(Map locationData, JournalArticle article) {
	try {
		if(UBERALL_API_CALL >= 2) return null;
		
		def isUpdate = article.getVersion() != 1
		boolean hasLocationId = locationData.containsKey("id") && locationData.id != null
		def methodType = isUpdate ? "PATCH" : "POST"
		if(hasLocationId) methodType = "PATCH"
		def endpoint = UBERALL_API_ENDPOINT

		println "API call: method=${methodType}, endpoint=${endpoint}, isUpdate=${isUpdate}, hasLocationId=${hasLocationId}"

		if (isUpdate) {
			def foundLocation = getUberallLocationByArticleId(article.getArticleId(), article.titleCurrentValue)
			println foundLocation
			println foundLocation?.id
			println foundLocation?.businessId
			if (foundLocation?.id) {
				locationData.put("businessId", foundLocation?.businessId)
				endpoint = "${UBERALL_ENDPOINT}/${foundLocation?.id}"
			} else {
				methodType = "POST"
			}
		}
		
		def jsonBody = JsonOutput.toJson(locationData);
		println "jsonBody : "+jsonBody
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
		UBERALL_API_CALL++;
		
		println "API Response code: ${responseCode}"
		
		if (responseCode >= 200 && responseCode < 300) {
			println ("API Response: "+response);
			return new JsonSlurper().parseText(response)
		} else if (responseCode == 409 && UBERALL_DUPLICATE_UPDATE) {
			def jsonResponse = new JsonSlurper().parseText(response)
			def duplicates = jsonResponse?.response?.duplicates

			println "Duplicate detected: ${duplicates}"

			if (duplicates && duplicates.size() > 0) {
				def duplicateId = duplicates[0]
				UBERALL_API_ENDPOINT = "${UBERALL_ENDPOINT}/${duplicateId}"
				def existingLocation = getBusinessIdFromLocation(duplicateId);
				if(existingLocation != null) {
					def businessId = existingLocation?.response?.location?.businessId
					println businessId
					locationData.put("businessId", businessId)
					println "Using existing businessId: ${existingLocation}"
				}
				locationData.put("id", duplicateId)
				println "Retrying with duplicate ID: ${duplicateId}"
				return callUberallApi(locationData, article)
			}
			throw new Exception("Duplicate found but no ID available")
		} else {
			throw new Exception("Failed to call Uberall API: ${responseCode} - ${response}")
		}

	} catch (Exception e) {
		println "ERROR: ${e.message}"
		println "Stack trace: ${e.stackTrace.join('\n')}"
		throw e
	}
}

def getBusinessIdFromLocation(def locationId) {
    try {
        def getLocEndpoint = "${UBERALL_ENDPOINT}/${locationId}"
        println "Getting business ID for location: ${locationId}, endpoint: ${getLocEndpoint}"
        
        def url = new URL(getLocEndpoint)
        def connection = url.openConnection()
        connection.setRequestMethod("GET")
        connection.setRequestProperty("privateKey", UBERALL_PRIVATE_KEY)
        
        def responseCode = connection.getResponseCode()
        println "Business ID lookup response code: ${responseCode}"
        
        if (responseCode >= 200 && responseCode < 300) {
            def responseStream = connection.getInputStream()
            def response = responseStream.getText()
            println "Location Response: ${response}"
            
            return new JsonSlurper().parseText(response)
        } else {
            println "Failed to get business ID, response code: ${responseCode}"
            return null
        }
    } catch (Exception e) {
        println "Error getting business ID: ${e.message}"
        return null
    }
}

def getUberallLocationByArticleId(String articleId, String articleName) {
	try {
		def urlString = "${UBERALL_ENDPOINT}?fieldMask=province&fieldMask=name&fieldMask=businessId&max=100000&selectAll=true"
		println "Looking up location by articleId: ${articleId}, name: ${articleName}, URL: ${urlString}"
		
		def connection = new URL(urlString).openConnection()
		connection.setRequestMethod('GET')
		connection.setRequestProperty('Content-Type', 'application/json')
		connection.setRequestProperty('privateKey', UBERALL_PRIVATE_KEY)

		def responseCode = connection.getResponseCode()
		println "Location lookup response code: ${responseCode}"

		if (responseCode == 200) {
			def jsonResponse = new JsonSlurper().parseText(connection.inputStream.text)
			def locations = jsonResponse?.response?.locations



			def foundLocation = locations?.find { location ->
				location.province == articleId || location.name == articleName
			}

			return foundLocation
		}
		return null
	} catch (Exception e) {
		println "ERROR in uberall location search: ${e.message}"
		println "Stack trace: ${e.stackTrace.join('\n')}"
		return null
	}
}

println "Checking if class is JournalArticle: ${className.equals('com.liferay.journal.model.JournalArticle')}"

if (className.equals("com.liferay.journal.model.JournalArticle")) {
	try {
		JournalArticle article = JournalArticleLocalServiceUtil.getArticle(classPK)
		println "Retrieved article: ${article.getArticleId()}, title: ${article.titleCurrentValue}, version: ${article.getVersion()}"
		
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

			def isCSVLocation = elements.find {
				it.attributeValue("field-reference") == "isCSVLocation"
			}?.element("dynamic-content")?.textTrim == "true"

			println "Article flags: isYextRestricted=${isYextRestricted}, isCSVLocation=${isCSVLocation}"

			if (isYextRestricted && isCSVLocation) {
			   WorkflowStatusManagerUtil.updateStatus(WorkflowConstants.getLabelStatus("approved"), workflowContext);
			   println "Workflow status updated to approved"

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
							   println "Geolocation: lng=${geo.lng}, lat=${geo.lat}"
							   break
						   case "LocationName":
							   jsonBuilder.name = value
							   println "LocationName: ${value}"
							   break
						   case "Address2":
							   jsonBuilder.street = value
							   println "Street: ${value}"
							   break
						   case "Address":
							   jsonBuilder.streetNo = value
							   println "Street Number: ${value}"
							   break
						   case "Postcode":
							   jsonBuilder.zip = value
							   println "Zip: ${value}"
							   break
						   case "TownCity":
							   jsonBuilder.city = value
							   println "City: ${value}"
							   break
						   case "PhoneNumber":
							   jsonBuilder.phone = "+44${value}"
							   println "Phone: +44${value}"
							   break
						   case "isLocationClosed":
							   jsonBuilder.status = value == "true" ? "CLOSED" : "ACTIVE"
							   println "Location status: ${jsonBuilder.status}"
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

						   println "Processing hours for ${dayName}, isClosed=${isClosed}"

						   if (isClosed) {
							   dayHours.closed = true
						   } else {
							   def timeSlots = element.elements("dynamic-element").findAll {
								   it.attributeValue("field-reference") == "Fieldset54865370"
							   }

							   println "Found ${timeSlots.size()} time slots for ${dayName}"

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
									   println "${dayName} slot ${idx+1}: ${openTime} - ${closeTime}"
								   }
							   }
						   }
						   jsonBuilder.openingHours << dayHours
					   }
					}
			   }

			   try {
				   println "Sending data to Uberall for location: ${jsonBuilder.name}"
				   def result = callUberallApi(jsonBuilder, article)
				   println "${jsonBuilder.name} Location has been uploaded to Uberall."
				   println "Result: ${result}"
			   } catch (Exception apiError) {
				   println "Failed to send data to Uberall: ${apiError.message}"
				   println "Stack trace: ${apiError.stackTrace.join('\n')}"
			   }
			} else {
				println "Yext restrictions or isCSVLocation not enabled, skipping processing"
			}
		}
	} catch (Exception e) {
		println "ERROR in main processing: ${e.message}"
		println "Stack trace: ${e.stackTrace.join('\n')}"
	}
}

println "Script execution completed"