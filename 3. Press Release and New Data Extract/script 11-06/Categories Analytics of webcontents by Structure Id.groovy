import com.liferay.journal.service.JournalArticleLocalServiceUtil
import com.liferay.journal.model.JournalArticle
import com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil

// ===== CONFIGURATION =====
def countryToProcess = "United Kingdom"

def configurations = [
    "United Kingdom": [
        country: "United Kingdom", 
        groupId: 45807659, 
        structureKey: "169349", 
        localeId: "en_GB"
    ]
]

// ===== VARIABLES =====
def currentConfig = configurations[countryToProcess]
def categoryStats = [:]
def articlesWithCategories = 0
def articlesWithoutCategories = 0
def articleCategoryDetails = []

// ===== VALIDATION =====
if (currentConfig == null) {
    println "Error: Configuration not found for country '${countryToProcess}'"
    println "Available countries: ${configurations.keySet()}"
    return
}

println "🔍 Analyzing categories for: ${countryToProcess}"
println "📊 Group ID: ${currentConfig.groupId}"
println "🏗️  Structure Key: ${currentConfig.structureKey}"
println "=" * 60

// ===== GET ARTICLES =====
def articles = JournalArticleLocalServiceUtil.getArticlesByStructureId(
    currentConfig.groupId, 
    currentConfig.structureKey, 
    -1, -1, null
)

println "📄 Found ${articles.size()} articles to analyze\n"

// ===== ANALYZE CATEGORIES =====
articles.each { article ->
    def assetEntry = AssetEntryLocalServiceUtil.fetchEntry(
        JournalArticle.class.name, 
        article.resourcePrimKey
    )
    
    def articleData = [
        articleId: article.getArticleId(),
        title: article.getTitle(currentConfig.localeId),
        categories: []
    ]
    
    if (assetEntry != null) {
        def categories = assetEntry.getCategories().collect { it.getName() }
        articleData.categories = categories
        
        if (categories.size() > 0) {
            articlesWithCategories++
            categories.each { categoryName ->
                categoryStats[categoryName] = (categoryStats[categoryName] ?: 0) + 1
            }
        } else {
            articlesWithoutCategories++
        }
    } else {
        articlesWithoutCategories++
    }
    
    articleCategoryDetails.add(articleData)
}

// ===== DISPLAY RESULTS =====
println "📊 CATEGORY ANALYSIS RESULTS"
println "=" * 60
println "📈 Total Articles Analyzed: ${articles.size()}"
println "✅ Articles with Categories: ${articlesWithCategories}"
println "❌ Articles without Categories: ${articlesWithoutCategories}"
println "🏷️  Total Unique Categories Found: ${categoryStats.size()}"

if (categoryStats.size() > 0) {
    println "\n🔥 CATEGORY USAGE STATISTICS"
    println "=" * 60
    
    // Sort categories by usage count (descending)
    def sortedCategories = categoryStats.sort { -it.value }
    
    sortedCategories.each { categoryName, count ->
        def percentage = Math.round((count / articles.size()) * 100)
        println sprintf("%-30s | %3d articles (%2d%%)", categoryName, count, percentage)
    }
    
    println "\n🏆 TOP 10 MOST USED CATEGORIES"
    println "=" * 60
    sortedCategories.take(10).eachWithIndex { entry, index ->
        println "${index + 1}. ${entry.key} - ${entry.value} articles"
    }
    
    if (articlesWithoutCategories > 0) {
        println "\n❗ ARTICLES WITHOUT CATEGORIES"
        println "=" * 60
        articleCategoryDetails.findAll { it.categories.size() == 0 }.each { article ->
            println "• ${article.articleId} - ${article.title}"
        }
    }
    
    println "\n📋 DETAILED ARTICLE-CATEGORY MAPPING"
    println "=" * 60
    articleCategoryDetails.findAll { it.categories.size() > 0 }.each { article ->
        println "📄 ${article.articleId} - ${article.title}"
        println "   🏷️  Categories: ${article.categories.join(', ')}"
        println ""
    }
    
} else {
    println "\n⚠️  NO CATEGORIES FOUND"
    println "All articles are uncategorized or have no asset entries."
}

println "\n✅ Category analysis completed!"
println "=" * 60

/*


🔍 Analyzing categories for: United Kingdom
📊 Group ID: 45807659
🏗️  Structure Key: 169349
============================================================
📄 Found 1185 articles to analyze

📊 CATEGORY ANALYSIS RESULTS
============================================================
📈 Total Articles Analyzed: 1185
✅ Articles with Categories: 1185
❌ Articles without Categories: 0
🏷️  Total Unique Categories Found: 27

🔥 CATEGORY USAGE STATISTICS
============================================================
MEDIA-PressReleases            | 884 articles (75%)
Story                          | 671 articles (57%)
Press Release                  | 481 articles (41%)
2021                           |  62 articles ( 5%)
2020                           |  57 articles ( 5%)
2019                           |  41 articles ( 3%)
2009                           |  30 articles ( 3%)
2010                           |  29 articles ( 2%)
Projects Blog                  |  28 articles ( 2%)
2012                           |  27 articles ( 2%)
2008                           |  27 articles ( 2%)
2007                           |  27 articles ( 2%)
2013                           |  25 articles ( 2%)
2014                           |  23 articles ( 2%)
2022                           |  23 articles ( 2%)
2015                           |  21 articles ( 2%)
2016                           |  20 articles ( 2%)
2017                           |  19 articles ( 2%)
2011                           |  19 articles ( 2%)
Main Carousel                  |  18 articles ( 2%)
2018                           |  16 articles ( 1%)
2006                           |  13 articles ( 1%)
Home                           |  13 articles ( 1%)
2005                           |   2 articles ( 0%)
Voidfill                       |   1 articles ( 0%)
High Strength                  |   1 articles ( 0%)
Thermal Insulating             |   1 articles ( 0%)

🏆 TOP 10 MOST USED CATEGORIES
============================================================
1. MEDIA-PressReleases - 884 articles
2. Story - 671 articles
3. Press Release - 481 articles
4. 2021 - 62 articles
5. 2020 - 57 articles
6. 2019 - 41 articles
7. 2009 - 30 articles
8. 2010 - 29 articles
9. Projects Blog - 28 articles
10. 2012 - 27 articles

📋 DETAILED ARTICLE-CATEGORY MAPPING
============================================================
📄 45853248 - Liverpool Mayor Officially Opens New Liverpool Docklands Asphalt Plant
   🏷️  Categories: Press Release, 2018

📄 45853262 - CEMEX UK announces new Pedestrian safety campaign
   🏷️  Categories: Press Release, 2018

📄 45853270 - A great reception - the unique concrete desk
   🏷️  Categories: Press Release, 2017

📄 45853277 - UK celebrates 1000th hectares of restored land
   🏷️  Categories: Press Release, 2017

📄 45853284 - It’s rocking, the new CEMEX brand, neogem
   🏷️  Categories: Press Release, 2017

📄 45853291 - The first jumbo train carrying building materials leaves Cardiff
   🏷️  Categories: Press Release, 2017

📄 45853298 - On the road, the latest high performance concrete mixer
   🏷️  Categories: Press Release, 2017

📄 45853305 - Environmental Savings for construction, by barge
   🏷️  Categories: Press Release, 2017

📄 45853312 - Rare bee-eater chicks hatch after 24-hour guard in Nottinghamshire quarry
   🏷️  Categories: Press Release, 2017

📄 45853319 - 15cms makes all the difference ... to the lower N3 truck drivers
   🏷️  Categories: Press Release, 2017

📄 45853326 - Bird islands created out of surplus from CEMEX cement plant
   🏷️  Categories: Press Release, 2017

📄 45853333 - Quarry Garden Wins Hat Trick of Awards including Best in Show at RHS Chatsworth
   🏷️  Categories: Press Release, 2017

📄 45853340 - In National Bike Week new CEMEX low entry cab trucks take to the road
   🏷️  Categories: Press Release, 2017

📄 45853347 - On track, CEMEX creates one of its biggest rail crossing
   🏷️  Categories: Press Release, 2017

📄 45853354 - Swift Tower, new home erected at CEMEX asphalt plant
   🏷️  Categories: Press Release, 2017

📄 45853361 - Mental health, top of the agenda in CEMEX’s new Health Essentials
   🏷️  Categories: Press Release, 2017

📄 45853368 - Cabinet Secretary for Education shows support for new Welsh Baccalaureate challenge
   🏷️  Categories: Press Release, 2017

📄 45853375 - Thousands to make a change for healthier, safer sites
   🏷️  Categories: Press Release, 2017

📄 45853382 - CEMEX UK, the ‘waste eaters’
   🏷️  Categories: Press Release, 2017

📄 45853389 - Latest bio-monitoring scheme used in UK for 1st time reveals rare species in CEMEX site
   🏷️  Categories: Press Release, 2017

📄 45853396 - CEMEX supports charity, River and Sea Sense, to take water safety message national
   🏷️  Categories: Press Release, 2017

📄 45853404 - Home time for the cattle grazing on CEMEX sites
   🏷️  Categories: Press Release, 2016

📄 45853411 - Hot of the ‘press’ ....... new CEMEX ReadyBrick Facing range
   🏷️  Categories: Press Release, 2016

📄 45853418 - Driving to success - CEMEX Logistics Apprentices graduate
   🏷️  Categories: Press Release, 2016

📄 45853425 - CEMEX UK transports more than ever by rail saving truck journeys
   🏷️  Categories: Press Release, 2016

📄 45853432 - Lightweight concrete, CEMEX&#39;s new Porofoam range
   🏷️  Categories: Press Release, 2016

📄 45853439 - New quarry at Cromwell to open up new market for CEMEX UK
   🏷️  Categories: Press Release, 2016

📄 45853446 - New CEMEX quarry of strategic importance for the South East market
   🏷️  Categories: Press Release, 2016

📄 45853453 - The ‘Haute couture’ of bricks and mortars
   🏷️  Categories: Press Release, 2016

📄 45853460 - It’s all in the curves ..... the latest development in the London Underground track
   🏷️  Categories: Press Release, 2016

📄 45853467 - CEMEX expands Valuemix business to south coast
   🏷️  Categories: Press Release, 2016

📄 45853474 - Local lads start new Valuemix business in Poole
   🏷️  Categories: Press Release, 2016

📄 45853481 - New concrete plant opens in Moreton Valence
   🏷️  Categories: Press Release, 2016

📄 45853488 - Ravens at Rugby’s very own Tower
   🏷️  Categories: Press Release, 2016

📄 45853495 - The latest ‘pop-up’ in Warrington – a new rail depot
   🏷️  Categories: Press Release, 2016

📄 45853502 - Time to build hotels
   🏷️  Categories: Press Release, 2016

📄 45853509 - Manchester business achieves outstanding transport accreditation
   🏷️  Categories: Press Release, 2016

📄 45853516 - CEMEX UK is walking off the wobble!
   🏷️  Categories: Press Release, 2016

📄 45853530 - Concrete and Masonry Pavilion at Ecobuild 2016
   🏷️  Categories: Press Release, 2016

📄 45853537 - Great strides in haulier contractors’ standards in 2015 and more to come in 2016
   🏷️  Categories: Press Release, 2016

📄 45853580 - New CEMEX Flooring Plant Could Help Government Achieve New Housing Target
   🏷️  Categories: Press Release, 2015

📄 45853587 - CEMEX UK awarded industry’s highest H&amp;S award
   🏷️  Categories: Press Release, 2015

📄 45853594 - CEMEX UK Is Shortlisted for the Construction News Specialists Awards 2016
   🏷️  Categories: Press Release, 2015

📄 45853601 - CEMEX UK wins prestigious CILT award for protecting vulnerable road users
   🏷️  Categories: Press Release, 2015

📄 45853608 - CEMEX launch Supaflo-C at the UK Construction Week Show in Birmingham
   🏷️  Categories: Press Release, 2015

📄 45853615 - CEMEX Launch Permaflow - Permeable Concrete at UK Construction Week
   🏷️  Categories: Press Release, 2015

📄 45853622 - CEMEX and Suez Open New Facility Which Turns Waste Into High-Specification Fuel
   🏷️  Categories: Press Release, 2015

📄 45853629 - New Leeds concrete plant for supervisor, Andy
   🏷️  Categories: Press Release, 2015

📄 45853636 - Ready, steady, walk … CEMEX UK colleagues start 2015 Pedometer Challenge
   🏷️  Categories: Press Release, 2015

📄 45853643 - It’s clear to see...CEMEX, the first to operate the new Econic tipper
   🏷️  Categories: Press Release, 2015

📄 45853650 - Special New Truck To Help Keith Plant Millions Of Seeds
   🏷️  Categories: Press Release, 2015

📄 45853657 - CEMEX UK Launches New IUCN Book In Conservation Book Series
   🏷️  Categories: Press Release, 2015

📄 45853664 - CEMEX UK wins top award at Construction News Specialist Awards
   🏷️  Categories: Press Release, 2015

📄 45853671 - Grey and White is Greener in house building
   🏷️  Categories: Press Release, 2015

📄 45853678 - In with the new….. CEMEX 2015 trainees
   🏷️  Categories: Press Release, 2015

📄 45853693 - Production starts at CEMEX South Ferriby plant
   🏷️  Categories: Press Release, 2014

📄 45853700 - CEMEX is helping to build a Greater Britain
   🏷️  Categories: Press Release, 2014

📄 45853707 - Investing in talent for the future
   🏷️  Categories: Press Release, 2014

📄 45853714 - Doing the Twite Thing at Dove Holes Quarry by creating a flower-rich meadow which provides seeds
   🏷️  Categories: Press Release, 2014

📄 45853721 - Stepping-in is a gift, the theme of this year’s CEMEX H &amp; S days
   🏷️  Categories: Press Release, 2014

📄 45853728 - Its Operation Turtle Dove as CEMEX UK and RSPB work together to reverse the decline of this bird
   🏷️  Categories: Press Release, 2014

📄 45853742 - CEMEX UK launches stunning conservation book, Sublime Nature
   🏷️  Categories: Press Release, 2014

📄 45853749 - CEMEX UK Leads The UK Rankings In The World Concrete 500 List Of Social Networkers
   🏷️  Categories: Press Release, 2014

📄 45853756 - Stopped By The Cockles, A New Plant In Dagenham
   🏷️  Categories: Press Release, 2014

📄 45853763 - CEMEX Dove Holes Delivers Its 2 Millionth Tonne Of The Year
   🏷️  Categories: Press Release, 2014

📄 45853770 - CEMEX UK wins leading logistics industry award
   🏷️  Categories: Press Release, 2014

📄 45853777 - Two CEMEX Readymixers and 600 miles
   🏷️  Categories: Press Release, 2014

📄 45853784 - CEMEX Quarry Operator receives one of the 1st UK Gold Cards
   🏷️  Categories: Press Release, 2014

📄 45853791 - Unique Construction and Sport Partnership in Prestwich, Greater Manchester
   🏷️  Categories: Press Release, 2014

📄 45853798 - CEMEX UK colleagues start walking 210 million steps
   🏷️  Categories: Press Release, 2014

📄 45853805 - CEMEX UK achieves the ultimate FORS, the Gold standard nationwide
   🏷️  Categories: Press Release, 2014

📄 45853812 - Slabtrack, a “first” on UK rails
   🏷️  Categories: Press Release, 2014

📄 45853819 - CEMEX UK launches a new brand, Valuemix
   🏷️  Categories: Press Release, 2014

📄 45853826 - New Brick on the Block - Readybrick
   🏷️  Categories: Press Release, 2014

📄 45853833 - The art of storytelling, the latest technique in the battle to achieve Zero incidents
   🏷️  Categories: Press Release, 2014

📄 45853840 - CEMEX UK shortlisted at Construction News Specialists Awards for Health &amp; Safety Excellence
   🏷️  Categories: Press Release, 2014

📄 45853847 - Save our Cockney Sparrows
   🏷️  Categories: Press Release, 2014

📄 45853855 - Cyclist safety, a key part of the logistics agenda
   🏷️  Categories: Press Release, 2013

📄 45853862 - Tilbury reaches 1 million tonnes
   🏷️  Categories: Press Release, 2013

📄 45853869 - The CEMEX sleeper that isn’t snoozing
   🏷️  Categories: Press Release, 2013

📄 45853876 - The elephant that is definitely in the room and … made of cement
   🏷️  Categories: Press Release, 2013

📄 45853883 - CEMEX UK lights up its readymixers
   🏷️  Categories: Press Release, 2013

📄 45853890 - CEMEX Aggregates ‘shove off’ to Middleton Lakes
   🏷️  Categories: Press Release, 2013

📄 45853897 - Readymix Southern is a Mining and Quarries Winner!
   🏷️  Categories: Press Release, 2013

📄 45853904 - Gold Health and Safety Award Achieved by CEMEX Rail
   🏷️  Categories: Press Release, 2013

📄 45853911 - New MORR Technology Trophy Awarded to CEMEX Logistics
   🏷️  Categories: Press Release, 2013

📄 45853918 - CEMEX UK Wins 12 Major Health and Safety Awards
   🏷️  Categories: Press Release, 2013

📄 45853925 - Saving energy commitment from CEMEX UK
   🏷️  Categories: Press Release, 2013

📄 45853932 - CEMEX UK awarded industry’s highest H &amp; S award
   🏷️  Categories: Press Release, 2013

📄 45853939 - A Woman Of Importance Kingsmeads Prehistoric Queen
   🏷️  Categories: Press Release, 2013

📄 45853946 - CEMEX Shortlisted For Construction News Award
   🏷️  Categories: Press Release, 2013

📄 45853953 - CEMEX Shortlisted For H&amp;S Construction News Award
   🏷️  Categories: Press Release, 2013

📄 45853960 - Patience and Ryburn move to Branton
   🏷️  Categories: Press Release, 2013

📄 45853967 - From The Sands of The Sahara to The Sands of CEMEX Quarries
   🏷️  Categories: Press Release, 2013

📄 45853974 - Latest Tyre Introduction Gives CEMEX Significant CO2 Savings
   🏷️  Categories: Press Release, 2013

📄 45853981 - CEMEX UK achieves FORS gold
   🏷️  Categories: Press Release, 2013

📄 45853988 - Southern England&#39;s First Housing Development
   🏷️  Categories: Press Release, 2013

📄 45853995 - Home Grown by CEMEX UK
   🏷️  Categories: Press Release, 2013

📄 45854002 - Perfect solution for Birmingham bus terminal
   🏷️  Categories: Press Release, 2013

📄 45854009 - CEMEX UK Scoops Construction News Supply Chain Excellence Award
   🏷️  Categories: Press Release, 2013

📄 45854018 - All of a Flutter at CEMEX’S Rugby Amphitheatre
   🏷️  Categories: Press Release, 2013

📄 45854027 - CEMEX UK Launches 20th Book In Conservation Book Series
   🏷️  Categories: Press Release, 2013

📄 45855008 - Leith Asphalt breakfast club helps to shed the pounds!
   🏷️  Categories: Story

📄 45855029 - Readymix Cluster 7 Lend a Hand Picking Litter
   🏷️  Categories: Story

📄 45856736 - Peregrine falcons return to Wick
   🏷️  Categories: Press Release, 2005

📄 45856745 - Bags of opportunity
   🏷️  Categories: Press Release, 2005

📄 45856755 - RCC, the solution for today’s highways and by-ways
   🏷️  Categories: Press Release, 2012

📄 45856769 - New Microtech concrete, perfect for building a greater Britain
   🏷️  Categories: Press Release, 2012

📄 45856776 - What is the carbon footprint of your contract?
   🏷️  Categories: Press Release, 2012

📄 45856783 - CEMEX UK and RSPB cement their relationship for a further 5 years
   🏷️  Categories: Press Release, 2012

📄 45856790 - Collaboration is key at CEMEX Aggregates conference
   🏷️  Categories: Press Release, 2012

📄 45856797 - CEMEX Paving Solutions Ltd, a new name for today’s market
   🏷️  Categories: Press Release, 2012

📄 45856804 - A raft of support for wildlife at the new CEMEX nature reserve
   🏷️  Categories: Press Release, 2012

📄 45856811 - New CEMEX tyre strategy gives economic and sustainability savings
   🏷️  Categories: Press Release, 2012

📄 45856818 - Local Avon team win major H & S award
   🏷️  Categories: Press Release, 2012

📄 45856825 - Not the end of the line for CEMEX quarry loco
   🏷️  Categories: Press Release, 2012

📄 45856832 - CEMEX UK launches new bedding mortar
   🏷️  Categories: Press Release, 2012

📄 45856839 - Helping to Build a Greater Britain, introduced by Team CEMEX,   a new  marketing campaign
   🏷️  Categories: Press Release, 2012

📄 45856846 - Quarries continue to be a 'home of choice' for birds of prey
   🏷️  Categories: Press Release, 2012

📄 45856853 - CEMEX UK reports great strides to excellence in its Sustainable Development Update
   🏷️  Categories: Press Release, 2012

📄 45856860 - Partnership Site Biodiversity Advisor appointed
   🏷️  Categories: Press Release, 2012

📄 45856867 - High conservation priority bird at northern CEMEX quarry
   🏷️  Categories: Press Release, 2012

📄 45856874 - CEMEX UK wins major award during Mexico Week
   🏷️  Categories: Press Release, 2012

📄 45856881 - "Dust off" at CEMEX South Ferriby cement plant
   🏷️  Categories: Press Release, 2012

📄 45856888 - CEMEX UK works with SITA UK to develop waste recycling plants for the production of Climafuel
   🏷️  Categories: Press Release, 2012

📄 45856895 - Fastest bird in the world nests on top of an old clinker silo
   🏷️  Categories: Press Release, 2012

📄 45856902 - The latest addition to a CEMEX Quarry in Wales is a pair of Little Owls
   🏷️  Categories: Press Release, 2012

📄 45856909 - CEMEX UK wins major health and safety awards
   🏷️  Categories: Press Release, 2012

📄 45856923 - CEMEX UK Cement Logistics has added 10 new Volvo Tractor Units to its fleet
   🏷️  Categories: Press Release, 2012

📄 45856930 - CEMEX Volunteers plant over 400 trees at RSPB Baron's Haugh
   🏷️  Categories: Press Release, 2012

📄 45856937 - CEMEX UK and RSPB cement their relationship for a further 5 years
   🏷️  Categories: Press Release, 2012

📄 45856945 - UK cement plant sets new record
   🏷️  Categories: Press Release, 2011

📄 45856952 - CEMEX launches new concrete in UK
   🏷️  Categories: Press Release, 2011

📄 45856959 - It's all bagged up at the new CEMEX plant
   🏷️  Categories: Press Release, 2011

📄 45856966 - The sound of buzzzzzzzzzzzzz at CEMEX Taffs Well Quarry
   🏷️  Categories: Press Release, 2011

📄 45856973 - CEMEX UK wins top industry health & safety awards
   🏷️  Categories: Press Release, 2011

📄 45856980 - CEMEX Rugeley site wins the first ever Natural England Biodiversity Award
   🏷️  Categories: Press Release, 2011

📄 45856987 - CEMEX UK restores Northumberland quarry into a nature conservation area
   🏷️  Categories: Press Release, 2011

📄 45856994 - Tough new flooring finishes salt store in a couple of shakes
   🏷️  Categories: Press Release, 2011

📄 45857001 - CEMEX invests in new Blackburn plant
   🏷️  Categories: Press Release, 2011

📄 45857008 - Restored sand and gravel quarry turned into latest CEMEX Angling site at Yateley
   🏷️  Categories: Press Release, 2011

📄 45857015 - CEMEX UK continues its support of cyclist safety during the 2011 Bike Week
   🏷️  Categories: Press Release, 2011

📄 45857022 - CEMEX Readymix achieves 1 year lti free
   🏷️  Categories: Press Release, 2011

📄 45857029 - CEMEX UK wins major road safety award for its cyclist safety programme
   🏷️  Categories: Press Release, 2011

📄 45857036 - New CEMEX Permatite is the choice for luxury leisure development
   🏷️  Categories: Press Release, 2011

📄 45857043 - CEMEX appoints new UK country president
   🏷️  Categories: Press Release, 2011

📄 45857050 - CEMEX UK drivers get on their bikes
   🏷️  Categories: Press Release, 2011

📄 45857057 - EPod advances into CEMEX UK
   🏷️  Categories: Press Release, 2011

📄 45857064 - CEMEX quarries achieve quality management ISO 9001 certification
   🏷️  Categories: Press Release, 2011

📄 45857071 - Use of more waste derived fuels at CEMEX’s Rugby cement plant shows further environmental gains
   🏷️  Categories: Press Release, 2011

📄 45857079 - Sports England mortars for new Warwickshire College Sports Complex
   🏷️  Categories: Press Release, 2010

📄 45857086 - New bridge to link the Trent Valley Greenway
   🏷️  Categories: Press Release, 2010

📄 45857093 - Innovative, COOL CEMEX CONCRETE for Heathrow Terminal 2
   🏷️  Categories: Press Release, 2010

📄 45857100 - CEMEX Surfacing starts £7million a year asphalt contract
   🏷️  Categories: Press Release, 2010

📄 45857107 - CEMEX Angling supports charity fish-in for MacMillan cancer
   🏷️  Categories: Press Release, 2010

📄 45857114 - CEMEX UK gains recognition for its actions on climate change
   🏷️  Categories: Press Release, 2010

📄 45857121 - CEMEX UK reports major improvements in sustainable development report
   🏷️  Categories: Press Release, 2010

📄 45857128 - CEMEX UK and RSPB launch national biodiversity strategy in Scotland to enrich nature
   🏷️  Categories: Press Release, 2010

📄 45857135 - 300th CEMEX vehicle to be fitted with sensors to keep vulnerable road users safe
   🏷️  Categories: Press Release, 2010

📄 45857142 - 40 new CEMEX trucks hit the road
   🏷️  Categories: Press Release, 2010

📄 45857149 - New conveyor bridge will aid release of valuable sand reserves for the South East
   🏷️  Categories: Press Release, 2010

📄 45857156 - £1.3 million and 1120 tonnes CO2 emissions saved on A45
   🏷️  Categories: Press Release, 2010

📄 45857163 - CEMEX UK and RSPB launch national biodiversity strategy at Attenborough to enrich nature
   🏷️  Categories: Press Release, 2010

📄 45857170 - CEMEX UK and RSPB launch national biodiversity strategy in Wales to enrich nature
   🏷️  Categories: Press Release, 2010

📄 45857177 - Demolition of chimney taller than St Paul's Cathedral marks end of an era at CEMEX plant
   🏷️  Categories: Press Release, 2010

📄 45857184 - New CEMEX volunteering programme launched in Scotland
   🏷️  Categories: Press Release, 2010

📄 45857191 - CEMEX donates 2000 year old artefacts
   🏷️  Categories: Press Release, 2010

📄 45857198 - CEMEX UK supporting 2010 Bike Week to promote cyclist safety
   🏷️  Categories: Press Release, 2010

📄 45857205 - CEMEX receives a Big Tick
   🏷️  Categories: Press Release, 2010

📄 45857212 - CEMEX UK completes responsible sourcing certification for its main business areas
   🏷️  Categories: Press Release, 2010

📄 45857219 - Major investment by CEMEX in York plant
   🏷️  Categories: Press Release, 2010

📄 45857226 - New sand production plant to boost efficiency
   🏷️  Categories: Press Release, 2010

📄 45857233 - CEMEX block factory, first to achieve Green Dragon
   🏷️  Categories: Press Release, 2010

📄 45857240 - CEMEX UK Appoints New Angling and Fisheries Manager
   🏷️  Categories: Press Release, 2010

📄 45857247 - CEMEX first to launch responsibly sourced, carbon labelled cement
   🏷️  Categories: Press Release, 2010

📄 45857254 - New CEMEX rail route between South Wales and North East
   🏷️  Categories: Press Release, 2010

📄 45857261 - CEMEX and IUCN present new book on ecosystem services for international year of biodiversity
   🏷️  Categories: Press Release, 2010

📄 45857268 - CEMEX supports latest Metropolitan Police cyclist safety event
   🏷️  Categories: Press Release, 2010

📄 45857275 - Extinct Shark’s Tooth Found At Barrington Quarry
   🏷️  Categories: Press Release, 2010

📄 45857283 - CEMEX applies for quarry extension with tunnel solution to protect woodland and wildlife
   🏷️  Categories: Press Release, 2009

📄 45857290 - New runway at MOD St Athan fully operational with the help of CEMEX UK
   🏷️  Categories: Press Release, 2009

📄 45857297 - CEMEX UK, the first company in sector to introduce an Epod system
   🏷️  Categories: Press Release, 2009

📄 45857304 - CEMEX cement plant sets alternative fuels record
   🏷️  Categories: Press Release, 2009

📄 45857318 - Pupils explore their local CEMEX quarry
   🏷️  Categories: Press Release, 2009

📄 45857325 - CEMEX dedicated RSPB advisor appointed to drive improvements
   🏷️  Categories: Press Release, 2009

📄 45857332 - Last section of River Erewash diversion in place
   🏷️  Categories: Press Release, 2009

📄 45857346 - 20% of pallets returned in first year of CEMEX’s pallet retrieval scheme
   🏷️  Categories: Press Release, 2009

📄 45857353 - EA grants permission for CEMEX to burn climafuel
   🏷️  Categories: Press Release, 2009

📄 45857360 - CEMEX Rail to provide switches and crossings for Singapore railways
   🏷️  Categories: Press Release, 2009

📄 45857367 - CEMEX UK awarded responsible sourcing certification
   🏷️  Categories: Press Release, 2009

📄 45857374 - CEMEX floors has record production month
   🏷️  Categories: Press Release, 2009

📄 45857381 - CEMEX opens new £49 million cement plant in the south east of England
   🏷️  Categories: Press Release, 2009

📄 45857388 - Restored sand and gravel quarry turned into angling site at Chertsey, Surrey
   🏷️  Categories: Press Release, 2009

📄 45857395 - Innovation Celebrated in Construction Products Industry
   🏷️  Categories: Press Release, 2009

📄 45857402 - Two new CEMEX Angling sites opening
   🏷️  Categories: Press Release, 2009

📄 45857409 - New electric crane at CEMEX’s Battersea Wharf, a ‘first’ in UK
   🏷️  Categories: Press Release, 2009

📄 45857416 - Restored sand and gravel quarry turned into latest CEMEX Angling site
   🏷️  Categories: Press Release, 2009

📄 45857423 - The impact of modern asphalt on motorcycle road safety
   🏷️  Categories: Press Release, 2009

📄 45857430 - The sustainable way to use aggregates
   🏷️  Categories: Press Release, 2009

📄 45857437 - CEMEX Sheffield rail siding to further increase rail transportation of aggregates
   🏷️  Categories: Press Release, 2009

📄 45857444 - CEMEX Sheffield rail siding to further increase rail transportation of aggregates
   🏷️  Categories: Press Release, 2009

📄 45857451 - CEMEX to help cyclists in York, Bristol, Cambridge and Manchester
   🏷️  Categories: Press Release, 2009

📄 45857458 - CEMEX officially opens new tunnel and processing plant at Taffs Well Quarry
   🏷️  Categories: Press Release, 2009

📄 45857465 - CEMEX partners with the royal society for the protection of birds
   🏷️  Categories: Press Release, 2009

📄 45857472 - New Russell roof tile has a European feel
   🏷️  Categories: Press Release, 2009

📄 45857479 - CEMEX aggregates delivered by helicopter to repair the Pennine Way
   🏷️  Categories: Press Release, 2009

📄 45857486 - CEMEX angling makes changes to 2 yateley sites
   🏷️  Categories: Press Release, 2009

📄 45857494 - New hoppers to increase rail transportation to over 10% for CEMEX UK
   🏷️  Categories: Press Release, 2008

📄 45857501 - CEMEX collects five top marketing awards
   🏷️  Categories: Press Release, 2008

📄 45857508 - New collaborative book uses power of pictures to put the spotlight climate change.
   🏷️  Categories: Press Release, 2008

📄 45857515 - CEMEX quarry manager honoured in queen’s new year list
   🏷️  Categories: Press Release, 2008

📄 45857522 - Underfloor heating – The importance of having the right base
   🏷️  Categories: Press Release, 2008

📄 45857529 - New urban concrete plants open for business
   🏷️  Categories: Press Release, 2008

📄 45857536 - Adding value for customers through Mortar advice
   🏷️  Categories: Press Release, 2008

📄 45857543 - New CEMEX mortar plant opens for business
   🏷️  Categories: Press Release, 2008

📄 45857550 - New Bronze Age Find’ At CEMEX’s Kingsmead Quarry
   🏷️  Categories: Press Release, 2008

📄 45857557 - CEMEX Launches New Online Location Finders To Help Customer Ordering
   🏷️  Categories: Press Release, 2008

📄 45857564 - CEMEX Promotes Cement Experts
   🏷️  Categories: Press Release, 2008

📄 45857571 - CEMEX UK Announces Plans For New Warwickshire Plant To Make Green Fuel From Local Waste
   🏷️  Categories: Press Release, 2008

📄 45857578 - CEMEX Presents Land At Ten Acre Lane To Thorpe Brownies
   🏷️  Categories: Press Release, 2008

📄 45857585 - Looking At Concrete In A New Light As A Sustainable Building Material
   🏷️  Categories: Press Release, 2008

📄 45857592 - Use Of Tyres Shows Further Environmental Gains For CEMEX’s Cement Plant In Rugby
   🏷️  Categories: Press Release, 2008

📄 45857599 - CEMEX UK PRESENTS TWO NEW DOMESTIC PERMEABLE PAVING RANGES
   🏷️  Categories: Press Release, 2008

📄 45857606 - THE NEW ‘GREEN’ PAVING FROM CEMEX UK
   🏷️  Categories: Press Release, 2008

📄 45857613 - CEMEX UK GRANTED PERMIT TO USE CLIMAFUEL PERMANENTLY AT BARRINGTON WORKS
   🏷️  Categories: Press Release, 2008

📄 45857620 - CEMEX UK launches the first pallet collection system in the cement business
   🏷️  Categories: Press Release, 2008

📄 45857627 - CEMEX Continues Ambitious UK Investment Programme With New, Strategic London Plant
   🏷️  Categories: Press Release, 2008

📄 45857634 - ReadyflowTM, A New Permeable Paving Solution With Green Credentials From CEMEX UK
   🏷️  Categories: Press Release, 2008

📄 45857641 - CEMEX's Barrington Plant Scoops Three Awards For Outstanding Health & Safety Record
   🏷️  Categories: Press Release, 2008

📄 45857648 - CEMEX Leads The Way With Training To Meet Future Skill Shortages
   🏷️  Categories: Press Release, 2008

📄 45857655 - New education centre sponsored by CEMEX UK gets royal seal of approval
   🏷️  Categories: Press Release, 2008

📄 45857662 - CEMEX UK Announces Record Performance In All Its Cement Plants In 2007
   🏷️  Categories: Press Release, 2008

📄 45857669 - CEMEX UK appoints new country president
   🏷️  Categories: Press Release, 2008

📄 45857676 - RUSSELL® presents a new concrete roof tile with the beauty of natural slate
   🏷️  Categories: Press Release, 2008

📄 45857684 - CEMEX UK To Double Use Of Tyres At Rugby Works
   🏷️  Categories: Press Release, 2007

📄 45857698 - CEMEX UK Opens New 'Cutting Edge' Concrete Factory At West Calder
   🏷️  Categories: Press Release, 2007

📄 45857705 - CEMEX UK Scoops Highways Magazine Excellence For Unique Recycling Achievement
   🏷️  Categories: Press Release, 2007

📄 45857712 - CEMEX Your Reliable Partner at the Thames Gateway Forum
   🏷️  Categories: Press Release, 2007

📄 45857719 - Potential Quarry Extension Could Treble Nature Reserve At Eversley
   🏷️  Categories: Press Release, 2007

📄 45857726 - CEMEX UK Granted Permit to Introduce Climafuel at Rugby Works
   🏷️  Categories: Press Release, 2007

📄 45857733 - CEMEX UK Supports stabilisation of UKs Largest Disused Mine Project in Bath
   🏷️  Categories: Press Release, 2007

📄 45857740 - HSC Chair, Sir Bill Callaghan visits Bramshill Quarry
   🏷️  Categories: Press Release, 2007

📄 45857747 - CEMEX UK Launches First RIBA Accredited Screed Training Programme
   🏷️  Categories: Press Release, 2007

📄 45857754 - CEMEX UK's Rugby Cement Plant Achieves Health and Safety Record
   🏷️  Categories: Press Release, 2007

📄 45857761 - Major Investment at CEMEX UK's Jarrow Wharf Benefits Local Construction Projects
   🏷️  Categories: Press Release, 2007

📄 45857768 - CEMEX National Investment Programme Improves Efficiency, Quality and Service for Customers
   🏷️  Categories: Press Release, 2007

📄 45857775 - Major Investment at CEMEXs Leamouth Wharf Benefits Construction Customers & Saints Football Fans
   🏷️  Categories: Press Release, 2007

📄 45857782 - CEMEX UK launches Save our Butterflies schools competition
   🏷️  Categories: Press Release, 2007

📄 45857789 - New Rail Contract to Promote Sustainable Solutions & Allow for Rail Expansion
   🏷️  Categories: Press Release, 2007

📄 45857796 - CEMEX UK Announces Performance Improvements in All its Cement Plants
   🏷️  Categories: Press Release, 2007

📄 45857803 - CEMEX UK Announces Butterfly Conservation Partnership to Flight Season Start
   🏷️  Categories: Press Release, 2007

📄 45857810 - CEMEX UK Appoints Vice President to Improve Cement and Building Product Quality, Service and Sales
   🏷️  Categories: Press Release, 2007

📄 45857817 - CEMEX Cuts Dust Emissions At Rugby Plant By More Than 80%
   🏷️  Categories: Press Release, 2007

📄 45857824 - CEMEX Angling Improves Online Experience
   🏷️  Categories: Press Release, 2007

📄 45857831 - CEMEX UK supplies concrete by air for key European wind farm in East Kilbride
   🏷️  Categories: Press Release, 2007

📄 45857838 - Nursery receives grant from Neighbouring Company, CEMEX UK
   🏷️  Categories: Press Release, 2007

📄 45857845 - CEMEX UK works on state of the art concrete block and paving plant in Scotland
   🏷️  Categories: Press Release, 2007

📄 45857852 - CEMEX UK provides clunch and grant to support art students at University of Hertfordshire
   🏷️  Categories: Press Release, 2007

📄 45857859 - CEMEX UK Gets approval for new grinding and blending facility at Tilbury
   🏷️  Categories: Press Release, 2007

📄 45857866 - CEMEX UK Granted permit to use tyres at Rugby Works
   🏷️  Categories: Press Release, 2007

📄 45857873 - CEMEX UK showcases thames gateway sustainable construction capabilities
   🏷️  Categories: Press Release, 2006

📄 45857880 - CEMEX UK launches update on sustainability achievements and outlines journey ahead
   🏷️  Categories: Press Release, 2006

📄 45857887 - European launch of collaborative book to preserve wilderness and biodiversity areas
   🏷️  Categories: Press Release, 2006

📄 45857894 - CEMEX marks 100th anniversary by planting 100 trees at kensworth
   🏷️  Categories: Press Release, 2006

📄 45857901 - CEMEX introduces first roadtech shuttle buggy in the UK
   🏷️  Categories: Press Release, 2006

📄 45857908 - CEMEX scoops top UK health & safety awards for reducing workplace injuries by 65%
   🏷️  Categories: Press Release, 2006

📄 45857915 - CEMEX launches New, light-coloured, blended bagged cement
   🏷️  Categories: Press Release, 2006

📄 45857922 - New firing system cuts key emissions at CEMEX cement works in Barrington
   🏷️  Categories: Press Release, 2006

📄 45857929 - Positive results from CEMEX tyre trial at Rugby works
   🏷️  Categories: Press Release, 2006

📄 45857936 - CEMEX scoops top award for restoration at the Attenborough nature reserve
   🏷️  Categories: Press Release, 2006

📄 45857943 - CEMEX announces plans to trial an additional alternative fuel at Rugby works
   🏷️  Categories: Press Release, 2006

📄 45858610 - CEMEX holds its first ever Hackathon in the UK
   🏷️  Categories: Press Release, 2018

📄 45853559 - CEMEX operates the first Econic tipper in the country, helping to save cyclists lives
   🏷️  Categories: Press Release, 2015

📄 45853552 - It’s looking all Twite! for the small bird close to extinction
   🏷️  Categories: Press Release, 2015

📄 45853545 - Job well done! Lee tunnel plant dismantled
   🏷️  Categories: Press Release, 2015

📄 45853523 - CEMEX expertise is helping engineers bridge the gap of the Mersey Gateway
   🏷️  Categories: Press Release, 2016

📄 45853566 - The first woman Master in UK Dredging Industry joins CEMEX
   🏷️  Categories: Press Release, 2015

📄 46009250 - More than good looking, the new cemex.co.uk website
   🏷️  Categories: Press Release, 2018

📄 45899535 - CEMEX UK delivers a new future for the industry with CEMEX Go
   🏷️  Categories: Press Release, 2018

📄 45853255 - CEMEX UK signs contract with Damen for first Marine Aggregate Dredger
   🏷️  Categories: Press Release, 2018

📄 45853573 - CEMEX’s 2nd cohort of apprentice drivers includes the first woman Logistics apprentice
   🏷️  Categories: Press Release, 2015

📄 46129411 - First new investment by PLA to be in partnership with CEMEX UK
   🏷️  Categories: Press Release, Home, Main Carousel, 2018

📄 46129425 - RoadPeace and CEMEX UK join forces to call on the construction industry to sign up to CLOCS
   🏷️  Categories: Press Release, Home, Main Carousel, 2018

📄 46203952 - The new CEMEX UK marine dredger is named
   🏷️  Categories: Press Release, Main Carousel, 2018

📄 46242348 - 10K Customers Embrace CEMEX Go
   🏷️  Categories: Press Release, 2018

📄 45853685 - CEMEX UK shortlisted at Construction News Specialists Awards for Materials Supplier of the Year
   🏷️  Categories: Press Release, 2015

📄 46361374 - Rugby to become CEMEX UK’s new HQ
   🏷️  Categories: Press Release, 2018

📄 45853735 - Quarrying and wildlife on the agenda at major Westminster conference
   🏷️  Categories: Press Release, 2014

📄 45856916 - CEMEX and Conservation International present Oceans
   🏷️  Categories: Press Release, 2012

📄 45856762 - New carbon labelling for CEMEX UK bagged cement
   🏷️  Categories: Press Release, 2012

📄 46476120 - BSO team lend a sandy hand…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45857311 - CEMEX UK reinstates innovative, sustainable transport solution, Iso-veyors
   🏷️  Categories: Press Release, 2009

📄 45857691 - CEMEX UK Hosts Exhibition To Present Development Plans At Swinderby Airfield
   🏷️  Categories: Press Release, 2007

📄 46533524 - Tracking twites for new insights
   🏷️  Categories: Press Release, 2018

📄 46565364 - Porofoam Foamed Concrete in Stonehouse Provided as an Infill
   🏷️  Categories: Press Release, 2006

📄 46384014 - CEMEX’s  largest RCC contract using a ‘first’, the  process of power floating
   🏷️  Categories: Press Release, 2018

📄 46936048 - 2nd kiln at South Ferriby cement plant brought back into production
   🏷️  Categories: Press Release, Home, Main Carousel, 2018

📄 47050346 - CEMEX Pedestrian safety campaign takes to the road
   🏷️  Categories: Press Release, 2018

📄 47195933 - CEMEX Go Reaches 20K Customers in 18 Countries Within First Year
   🏷️  Categories: Press Release, 2018

📄 47688476 - Cemex Permatite- watertight concrete system supplied in Hook
   🏷️  Categories: Press Release, 2006

📄 45857339 - Readymix2go, the new readymix concrete service from CEMEX UK
   🏷️  Categories: Press Release, 2009

📄 52804500 - Going FORS Gold!
   🏷️  Categories: Story

📄 45854098 - Safety Partners Award for Mayo
   🏷️  Categories: Voidfill, High Strength, Thermal Insulating, MEDIA-PressReleases

📄 45853241 - CEMEX UK provides concrete for Europe’s first ever strongfloor
   🏷️  Categories: MEDIA-PressReleases

📄 45854091 - Improving Safety for Drivers at our Hyndford Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854252 - Starry starry night
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854175 - Eddie Stobart wins contract to deliver CEMEX packed cement
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854182 - Archaeology In Action At Datchet
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854168 - Leyburn Coating Plant gets a Facelift
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854161 - Porofoam continues to fill the void in the market
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854133 - Sooty Box Volunteers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854140 - International Women’s Day 2018
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854154 - CEMEX Renews BirdLife Partnership
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854224 - School Safety Event – Sharing Our Roads Safely
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854231 - CEMEX Haulier Health &amp; Safety Awards 2017 – Q4 Winner
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854238 - Rugby Team Wears It Orange
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854245 - Walking for Health
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854210 - Congrats to Joel Srodon - winner of bulk Cement 2017 Customer Service Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854217 - Dignity Day to help those with Dementia
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854203 - Working As ONE CEMEX – Sheffield Joint Emergency At Height Rescue Drill
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854119 - Readybrick Emoji Impresses at Ecobuild
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854126 - Northfleet Block Blokes Lend a Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854112 - Mark Pawsey MP Visits CEMEX Apprentices during National Apprenticeship Week
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854189 - Five Lend-A-Hand At Monks Kirby Church Graveyard
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854196 - First CEMEX Hackathon Will Help Us Transform Our Innovation Model
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854105 - Always check you’re using the correct device charger!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854147 - CEMEX renews partnership with Continental.
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854259 - Name that fruit!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854266 - Technical Development Team visits Preston Brook
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854287 - January Joggers Health Kick
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854280 - Man, Machine &amp; Nature
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854301 - Leith Team Lends a Hand at Local Rugby Club
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854294 - Christmas trees recycled to support charity
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854315 - Preston Brook Planners Lend-a-Hand in Runcorn
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854322 - North West team Lends a Hand at Morecambe Allotments
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854308 - Europe’s Strongest Floor in Bristol
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854343 - Barratt Homes - Our Partner In Safety
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854329 - Beach Clean Up Lend-a-Hand in Norfolk
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854336 - Successful First Contract For Supaflo C Flowing Screed In North London
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854350 - You can "Bank" on CEMEX
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854357 - Bulk Planners Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854371 - Operation Christmas Child Lend-a-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854385 - Fantastic 13 years LTI-free at Hyndford Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854378 - The Keith Lacey Driver of the Year
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854392 - CEMEX Haulier Health &amp; Safety Awards 2017 – Q3 Winner
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854399 - Folks at Rugby Office Help Out with Food Bank
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854406 - Thanks for your Shoe Box Appeal
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854420 - 60 Seconds on Supaflo Summit
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854427 - Leave your phone alone
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854434 - Top Quality System Launched on World Quality Day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854448 - Rail Tonnages Steaming Ahead Again in October
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854455 - MPA Health &amp; Safety Award Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854462 - Eversley quarry restoration plan is runner up in MPA Quarries and Nature Awards
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854469 - Mineral Products Association Launches New Quarrywatch Initiative
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854476 - 1000 hectares restored helping nature and communities
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854483 - Well done Frank for Preserving Ancient Tree at Wickwar
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854504 - Rare Burying Beetle Spotted at our Molesey Site
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854490 - New Mersey Gateway Bridge Opens as Our Site Plant Closes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854497 - Breathing New Life Into Former Charles Nelson Cement Site
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854518 - Little Mix Delivers For CEMEX
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854511 - Manchester Airport Project Takes Off
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854525 - Somercotes takes a stand for hands
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854532 - Congrats to our Coffee Morning Charity Fundraisers at Stockton and Washwood Heath
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854539 - Our North East teams work as ONE CEMEX with customers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854546 - Stop Smoking with Stoptober
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854560 - Ilkley Triathlon Truck Safety
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854553 - Our Sand Fulmar Crew Get The Message
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854574 - Team Asphalt Pull Up Trees
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854567 - Cycle Safety in Lincolnshire
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854581 - Jumbo Train...Wagons Roll
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854588 - Take Care In The Autumnal Weather
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854595 - Improving Our Customer Phone Service
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854609 - Proudly Lending a Hand at Darwen
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854602 - Flixton is Having A Hoot
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854623 - Nine years LTI-free celebration at Tilbury plant
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854616 - More than 100 people visit Rugby plant during Heritage Open Day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854630 - Congrats to Our Children&#39;s Safety Poster Competition Winners
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854651 - Planning Team Lendahand at Crick Woodlands
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854637 - Greg and His Sales Team Lendahand to Primary School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854658 - Leyburn and Pallett Hill Task Force Lendahand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854644 - Ongoing Restoration at East Leake quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854665 - CCTV System Projects Workforce at Washwood Heath
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854672 - Pallett Hill Quarry Achieves PRIME Status
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854686 - Marketing and Bid Team Lend-A-Hand With The Dogs’ Trust
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854693 - Team Asphalt Lend-A-Hand At Selkirk Stable Life
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854679 - Building A Better Future For The Swifts At Rugby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854700 - New Hymix Readymix Truck in Action
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854707 - Teaching Our Children And Grandchildren About Health and Safety
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854721 - Wick Celebrates 11 Years LTI-Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854714 - Local school children help design logo for Wickwar quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854728 - Asphalt Teamwork Gets the Holiday Traffic Moving for Eurovia
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854735 - First Porofoam contract for Berkswell Goes Well
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854742 - New Aggregates Rail Service at Brandon, Cambridgeshire
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854756 - Logistics Team Gets FIT4LIFE with Epic 12 mile Walk
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854749 - Farewell to the Bee Eaters at East Leake as BBC Autumnwatch visits
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854770 - Stephen Fairley Haulage wins Q2 Haulier Health Safety Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854777 - CEO of the Year
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854784 - Superior Customer Service in Mortars
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854798 - Great Feedback for Our Smooth Operations
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854791 - Successful Javelin Park Pour for Energy from Waste Plant
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854805 - ROSPA Awards Success 2017
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854812 - Slips, Trips and Falls Awareness
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854819 - Vote for River and Sea Sense
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854826 - Dry Silo Mortar Team 11 years incident-free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854833 - Congrats to Tilbury Logistics - 10 years without any safety incident
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854847 - Lending a hand to Dig a Hole
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854840 - Rail Solutions Look after their Backs at Washwood Heath
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854854 - It&#39;s a Knockout again to help Bluebell Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854861 - Bee Eaters at East Leake
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854868 - David competes for Team GB in European Triathlon finals
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854875 - 50 Concrete Society visitors at our Leeds readymix plant
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854882 - CEMEX Supports Institute of Traffic Accident Investigators
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854889 - Beach Clean-Up Lendahand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854896 - New homes for badgers at CEMEX Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854903 - Enraptured by raptors
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854917 - Sharing truck and child safety with local school
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854910 - Lendahand is in our nature
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854924 - Clucktastic CEM-EGGS raising money for Stroke Association
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854931 - Congratulations to Taylor &amp; Morrison - Q1 Haulier Health &amp; Safety Award Winners
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854938 - New homes for badgers at Hyndford
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854945 - Saxmundham talk turtle doves
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854959 - Readymix Team tour their northern region on bikes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854973 - Hyndford Team Lends a Hand with Clydesdale Community
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854987 - FORS Gold for our prime haulier partner Kingman
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854994 - Tip-top for Tipper Safety
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855015 - Unexpected visitor to West Heath Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855022 - Coal Tits return to East Kilbride Cigarette Box
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855043 - Huge readymix project at Hartlepool
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855050 - Somercotes Breakfast Club is Underway
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855064 - Hope Street&#39;s new Swift Tower
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855057 - Community Cavern Visit at Taffs Well
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855071 - No Horsing Around with Geoff
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855078 - Boughton Leigh School gardening club hopes design will ‘cement’ RHS success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855092 - Focusing on nutrition and well-being at Washwood Heath
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855085 - Congratulations to the Paving Solutions Warriors
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855106 - New rail service for CEMEX UK and Colas
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855099 - New sand plant for Rugeley Quarry improves efficiency
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855113 - Wenvoe Quarry helps launch Welsh Baccalaureate water safety challenge
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855127 - CEMEX Shortlisted for SIX Motor Transport Awards
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855141 - Sand Heron to the Rescue
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855148 - Northern Line Extension Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855155 - FORS GOLD for CEMEX Logistics Champions
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855162 - The sun doesn&#39;t stop our Paving Solutions team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855183 - Lean yellow belt training at Rugby Cement Plant
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855176 - CEMEX are here to Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855197 - Start your day with a healthy breakfast
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855190 - Donkey field turned into flood field
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855204 - Leyburn quarry builds a pond for nature
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855211 - CEMEX UK The Waste Eaters…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855225 - Millington Quarry team LendaHand to Leicester charity
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855218 - Seeing safety from a haulier&#39;s point of view
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855232 - Paving Solutions Lendahand in Shirebrook Valley
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855239 - Middleton Quarry Lendahand at High Force
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855253 - High Viz and Higher Viz
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855246 - Market-leading Whiteness
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855260 - A successful kiln shutdown for Rugby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855267 - The first system of its kind - 007&#39;s Q would be jealous
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855274 - Rare flies found at Rugeley
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855281 - Tyne Dock biomass silos continue to grow
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855288 - Thank you Debbie
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855295 - Cambusmore colleagues rescue Black Throated Diver
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855302 - CEMEX Rail Solutions collaboration wins award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855309 - The Evolution of Customer Service
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855316 - Driver Apprentice scheme Nov 2017 - now open
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855323 - Stourton join the big weighbrdge weigh-in
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855330 - New weighbridge for Leamouth Wharf
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855337 - Tilbury celebrates 3 million tonnes of cement sold since 2008
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855344 - Lending a Hand to Barnton FC in Cheshire
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855351 - Customer J N Bentley Wins Cluster 6 Partners In Safety Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855358 - Safer entrance for Cromwell quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855372 - West Yorkshire team slipform
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855365 - Grand design homes for hedgehogs, bugs and birds
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855379 - Team Salford weigh-in
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855386 - CEMEX Supports Charity, River And Sea Sense, To Take Water Safety Message National
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855393 - Our Technical Development Programme members learn about asphalt
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855400 - Investing in our Dagenham Wharf
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855407 - Our Smooth Operators in Sheffield
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855414 - Helping out with some local pensioners at Woolston
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855421 - Lending a Hand with the Christmas Lunches
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855428 - Keith Iley was our Eco Driver in November-December 2016
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855442 - 20 is plenty says Dove Holes Primary School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855449 - Home time for cattle grazing on CEMEX sites
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855463 - Final pour in a smooth project with Linden at Denby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855470 - Gold Medal For Salford Coating Plant
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855477 - Wangford and Hyndford Quarries Celebrate 20 years and 12 years LTI free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855484 - Super soup receives warm welcome at Cambusmore
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855491 - Central Readymix Team Lend-A-Hand at RSPB HQ
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855505 - Sir Robert McAlpine thanks CEMEX for a great job at Lynemouth
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855498 - Operation Christmas Child Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855512 - Congratulations to A &amp; R Burnett for Q3 Contract Haulier Recognition Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855519 - Doveholes team Lendahand at allotments for disabled people
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855526 - New dugouts for Buxton RUFC thanks to Dove Holes Lendahand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855540 - Teams from Freemans Quarry and Avonmouth Lendahand for Animal Sanctuary
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855547 - New concrete innovation Porofoam arrives in London
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855561 - East Aggregates Team Lends a Hand to create sensory garden
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855554 - Logisitcs Apprentices Graduate
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855568 - CEMEX Rocks at Extractive Industry Conference
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855582 - Cementing community relationships in Southam
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855575 - Dunblane students visit Cambusmore quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855589 - London Cycling Campaign visits our trucks at Angerstein
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855596 - Matthew&#39;s climbing Mount Toubkal for Type 1 Diabetes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855603 - Cementitious Paving Demonstration For Fox Contracting
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855617 - Peter Head awarded CEMEX 2016 “Lorenzo H. Zambrano” Lifetime Achievement Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855610 - Lending A Hand at Pontllanfraith School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855624 - First station for Crossrail 2 almost complete
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855631 - National Reserves Lend-A-Hand With The RSPB
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855638 - Lending a Hand for LOROS
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855645 - Cement drivers Lend a Hand with Winteringham shelter
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855652 - Porofoam launched - lightweight foamed concrete
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855680 - New sand and gravel quarry at Cromwell, Lincs
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855666 - We&#39;re Wearing It Pink for Breast Cancer Now
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855687 - Cycling around Silverstone supporting Operation Smile
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855673 - David completes world duathlon and triathlon finals in Mexico
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855694 - Aquawall Resilience Award Nomination
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855701 - State Of Nature 2016 - RSPB Publishes Its Report
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855708 - Asphalt Spread it Thin
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855715 - Dog Day - the Planning Team Lends A Paw
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855764 - Daisy Chain Lend-A-Hand at Stockton
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855750 - CEMEX Haulier Health &amp; Safety Awards 2016 - Q2 Winner
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855757 - An Impressive View For Rugby Heritage Day Visitors
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855771 - Taffs Well’s Eco-Pond Lend a Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855778 - Aggregates Commercial Barrow Girls and Boys
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855785 - Wildlife watch at Longdell Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855792 - Stuart’s scaling the Three Peaks in aid of the St Giles Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855799 - Cluster 12 plants 4,000 reeds at RSPB Nature Reserve
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855806 - Kevin Hollinrake MP impressed with our truck safety
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855813 - Team Scotland taking the Health and Wellbeing Challenge on Ben Ledi
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855827 - Susan Gets Muddy For Cancer Research UK
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855820 - Exchanging Places in Feltham for Cycle Safety
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855834 - Triathlon update from Dove Holes&#39; David Heathcote
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855848 - Tilbury Lends a Hand to save water on local allotments
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855841 - Marine Team Lend-a-Hand To Local Sea Cadets
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855862 - Washwood Heath Welcomes Public Works Visitors From Qatar
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855855 - Cluster 16 Team Leaders Skydive For The Stroke Society
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855876 - Bedale bypass opened by Roads Minister
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855883 - Pro Ash Lend-A-Hand At Debdale Park
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855904 - Rugby Cement Plant ISO50001 Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855897 - West Burton Ash Technical Team Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855911 - Better Solutions for our customers working on Thames Tideway Tunnel
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855918 - Andy’s War On Waste
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855932 - Cluster 16 Lends-A-Hand With Some Olde Worlde Concrete
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855925 - Legal Lend-A-Hand At Thames Valley Adventure Playground
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855946 - Readybase Helps Give Clear Views From New Brighton Tower
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855939 - Half Million Tonne Record Smashed At Dove Holes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855967 - A small pour with a large thank you
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855960 - Wangford Quarry Barn Owl Update
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855974 - It’s all about the bricks…..and mortar
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856002 - Respect the water this summer - follow RNLI advice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856009 - David Qualifies For The World Aquathon And Triathlon Finals
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856023 - Stone For The Vikings in York
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856030 - Rugby Tower’s Very Own Ravens
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856016 - Martlets Hospice Lend-A-Hand, East Sussex
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856037 - New Readymix Plant For Moreton Valence, Gloucestershire
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856044 - TJ Transport Ltd Our Safe Haulier Prize Winner for Q1
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856051 - Traffic Accident Investigators Day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856065 - Congratulations To The Snowbrainers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856100 - CEMEX Celebrates Panama Canal Expansion
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856093 - Bletchley Gets Creative With The Birds And The Bees
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856107 - Twite All Right At Dove Holes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856114 - CEMEX Snowbrainers take on Snowdon trek for charity
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856121 - Paving Solution South Lends-A-Hand for Meningitis UK
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856128 - CEMEX features in Institute Of Quarrying “Skills Wheel” At Hillhead 2016
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856135 - New Viashield product roll-out for Lincoln
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856142 - CEMEX at the Suffolk Show
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856149 - Our employees Lending a Hand to charities across the UK
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856163 - CEMEX UK wins tipper safety award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856177 - CEMEX Rail Solutions Raise &#163;1,250 For The John Taylor Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854273 - Cambusmore Double Celebrations!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854364 - Xmas Santas Dashing Through The Snow...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854413 - Wangford Quarry reaches 21 years LTI Free!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854441 - Sheffield Local Asphalt &quot;Thumbs Up for Hands Stand-Down&quot;
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854763 - South Ferriby Team Wins the Worlaby Soapbox Challenge Again!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854952 - Asphalt Team &quot;love where they live…&quot;
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854966 - I will walk 179 million steps...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45854980 - Tony Lowes Eco-driver winner…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855001 - Dave from Datchet goes the Extra 14.7 miles!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855036 - Sheffield’s Biggest Train Delivery So Far.....
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855120 - Bigger Box Wagons Railing In!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855134 - Washwood Heath Team Lends a Lot of Hands!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855169 - Let&#39;s see what the Grangemouth team have been up to...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855435 - Not a new Carry On film, but a healthy way to start the day!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855456 - Technical Development Team learn about running a wharf and opening a new quarry…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855533 - Abbey Surfacing - delighted with our asphalt customer service!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855659 - Letting the trains take the strain!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855722 - I Love It When A Plan Comes Together…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855729 - Bradby Boys Club Watertight At Last!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855736 - CEMEX Dragon Boaters Make A Splash!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855743 - Ahoy There! CEMEX Team Win Thames Race...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855869 - CEMEX Pumpmix launches in South Wales - better solutions for our customers!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855890 - Cottam Ash Team Tackle Wayward Garden!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855953 - Amy completes the Mud Run!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855981 - Up The ‘Boro!!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855995 - ROSPA Awards Success!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45855988 - All’s Well That ‘Angled Ends’ Well…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856058 - Are You Sitting Too Much?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856072 - Want To Support The Big Butterfly Count?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856079 - It’s A Knockout Returns...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856086 - A New Owl Family For Wangford!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856156 - Callander Nursery kids get on their bikes!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856170 - Rail Solutions Get Curves In All The Right Places…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856184 - Leyburns Very Own Lend-A-‘Stonehenge’-Hand...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856198 - Road And Cycle Safety Lend-A-Hand with Milton Keynes Orchard Academy
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856205 - Checking Our Site Boundaries
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856219 - Thanks For Your Effort Jason Storey
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856226 - The RSPB urges public not to rescue ‘lost’ young birds
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856233 - FORS Target smashed in April
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856247 - CEMEX Proud To Sponsor Pride Of Rugby Awards
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856240 - Walking in May..at the best times of day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856254 - Safety Meets Sustainability
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856261 - Contractors Vital To Our Safety Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856289 - Concrete Products Scotland Lend-a-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856317 - CEMEX helps to save the Small Blue in Warwickshire
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856324 - Record-breaking rail transport
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856331 - A1 Achievement for Paving Solutions
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856338 - Keeping our customers safe in Manchester
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856352 - North Yorkshire Readymix Lend-A-Forest Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856359 - Our Truck Safety Features Save A 10 Year Old Boy
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856366 - Constructing a Roller-Compacted Concrete Slab
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856373 - Our Driver Apprentices Visit DAF
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856387 - Kings Norton, Birmingham Readymix  Plant Supports the ‘Most Improved’ Academy In England
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856394 - New Warrington Aggregates Depot Starts Trading
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856408 - Spuggies at Dearn Valley
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856415 - Sand Martins in the UK
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856436 - Colleagues Lend a Caring-Hand to Halton Haven Trust
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856429 - Not quite the traditional library but definitely 21st century
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856443 - Colleagues Lend a Wild-hand at Seaton Sluice Middle School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856457 - Cannock Chicken Chase
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856471 - Promptis provides smooth landing for new Airbus at Birmingham airport
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856478 - A prickly visitor comes to CEMEX HQ
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856492 - Eversley Quarry hosts Oxford University Students
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856485 - Sand Fulmar in for a refit
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856499 - More solutions for customers in the South West
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856506 - Jas On Sabbatical To His Brother’s Memorial School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856520 - A58 Woodhouse Tunnel Phase 1 - Successfully Completed
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856534 - Driver and Vehicle Standards Agency Launch Day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856527 - Coweslinn Lend-A-Hand To Eddleston Out Of School Club
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856541 - CEMEX bosses &#39;Lendahand&#39; in South Ferriby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856555 - Hard Eggs For Easter! CEMEX help RSPB with unique method of protecting heron eggs
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856548 - The artistic side of cement
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856569 - CEMEX supply new Kilbryde Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856576 - News Stories
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856583 - CEMEX Stories from around the World
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856590 - BUTTERFLY survival blueprint unveiled at House of Commons
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856604 - Mint Hotel, Commendation at the 2012 Concrete Society Awards
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856597 - Another successful year for CEMEX Cyclist safety initiative
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856611 - CEMEX’s Moor Green Lakes Reserve sees the arrival of a Purple Emperor butterfly
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856618 - Lackford Lakes -an extraordinary place to visit
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856625 - New CEMEX Tyre Strategy Gives Economic and Sustainability Savings
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856632 - CEMEX Building Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856639 - CEMEX wins National Award for Cleanest Production in the Dominican Republic
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856646 - CEMEX provides unique solution to build colossal concrete foundations
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856653 - CEMEX recognized as a Leader in Corporate Social Responsibility and a Top Employer in Poland
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45872145 - We’re busy slip-forming in Cardiff!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856660 - CEMEX ready-mix concrete satisfies demanding requirements of water distillation facility in Israel
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45901160 - Successful logistics apprenticeship opens for 4th year
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45872160 - Improving security can look good too
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009430 - Asphalt Litter-Pickers Lend a Hand near Barnsley
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009479 - CLOCS Video Stars Two CEMEX Colleagues
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009498 - Contractor Kings And Barnhams Wins Health & Safety Recognition Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009449 - CEMEX proudly supporting launch of International Bomber Command Centre at Swinderby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009507 - Middleton Quarry Team Lend a Walking Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009542 - Packed and Concrete Products Team Lend a Helping Hand at RSPCA Coventry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46053485 - CEMEX Promotes ROSPA Family Safety Week
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46053547 - Lendahand in Birmingham for the Stroke Association
   🏷️  Categories: Home, Main Carousel, Story, MEDIA-PressReleases

📄 46053533 - Hallkyn Bowled Over
   🏷️  Categories: Home, Main Carousel, Story, MEDIA-PressReleases

📄 46090841 - Dale Completes the London Marathon
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46090855 - Local Team Lends a Hand at Middleton on the Wolds
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46090869 - Our driver Lee steps in to help after accident
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46116311 - Otter spotted at Attenborough Nature Reserve
   🏷️  Categories: Home, Main Carousel, Story, MEDIA-PressReleases

📄 46116373 - Readymix London team wins coveted CEMEX UK Safety Sword
   🏷️  Categories: Home, Main Carousel, Story, MEDIA-PressReleases

📄 46116522 - UK Quality Ash Association appoints Richard Boult as new technical chairman
   🏷️  Categories: Home, Main Carousel, Story, MEDIA-PressReleases

📄 46139469 - Beam & block floor systems benefit house builds in Driffield
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46158120 - Promptis Fast Setting Concrete Supplied to Kent Worx in Driffield
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46161077 - Don’t Chance It
   🏷️  Categories: Main Carousel, Story, MEDIA-PressReleases

📄 46161096 - Denge Lend-A-Hand At RNLI
   🏷️  Categories: Main Carousel, Story, MEDIA-PressReleases

📄 46212168 - CEMEX UK wins Apprentice of the Year Award and Tanker Safety Award
   🏷️  Categories: Main Carousel, Story, MEDIA-PressReleases

📄 46212197 - East Leake welcomes customers as it reopens for business
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46212310 - Collessie Quarry Team Lends A ‘Seaside’ Hand
   🏷️  Categories: Main Carousel, Story, MEDIA-PressReleases

📄 46212324 - May Health Month – week four – Addictions Awareness
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46243343 - Porofoam Foamed Concrete Supplied For Sheffield Student Accomodation
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46358477 - Taffs Well team Lend a Hand with local school
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46358496 - We’re supporting our colleagues in Guatemala
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46359194 - Roller Compacted Concrete Supplied in Killingholme for BMW Car Storage Area
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46243830 - Porofoam Foamed Concrete Supplied in Ashton Under Lyne Bridge Replacement
   🏷️  Categories: MEDIA-PressReleases

📄 46359818 - Rare Whin Grassland Habitat at Divert Hill Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46359832 - Somercotes Team goes back to school
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46393056 - Thriving frog population at Willington quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46393093 - Supply Chain and Logistics Lendahand at White Lodge Centre
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46393119 - Cambusmore team gets down at Doune
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46453310 - Addthis Social Sharing
   🏷️  Categories: MEDIA-PressReleases

📄 46453366 - Keep healthy and stay hydrated in the hot weather
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46453379 - Farewell to Thorpe and Welcome to Rugby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46453519 - Scarborough Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46453533 - Top Ammonite find at Newbridge
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46453546 - Pedestrian Safety Readymix Truck Out On The Roads
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461749 - Life's a neogem Beach
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461767 - Mr Blue Sky
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461789 - Cowieslinn Lend a Festival Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461812 - Keeping year 6 kids safe
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461776 - Mr Blue Sky
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461841 - RoSPA Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46461860 - Partners in Safety Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46476149 - At the car wash
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46543766 - South Ferriby Team Lends a hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46533100 - It’s A Knockout
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46545103 - Be UVA Aware – especially if you work outdoors
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46476159 - Bridlington - Pump Readymix Concrete Supplied For Gypsey Park Regeneration Scheme
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46565038 - Slipform Concrete In Cardiff Supplied for Project in City Centre
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46547978 - Road Safety Day At Winterton Junior School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46565269 - Concrete in Tetbury & Witcombe Provided for Housing Development
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46565320 - Waterproof Concrete in Stonehouse Gloucestershire Provided for a Waste Processing Site
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46671077 - Calcareous grassland course hosted at Dove Holes Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46671098 - Helping to Build Better Schools In Loughborough
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46672431 - More Butterfly Species at CEMEX Sites
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46683345 - Congratulations To Denge Quarry Team 20 Years LTI Free Milestone
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46683359 - Opposition Leader Jeremy Corbyn Visits Dove Holes Quarry With Local MP Ruth George
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46683372 - “Doune Your Way” for a Lend a Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46705888 - Foamed Concrete in Pershore Supplied for Arch Infill
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46706002 - Foamed Concrete in Pershore Supplied for Arch Infill
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46706081 - Foamed Concrete in Marlborough Supplied for Low Density, Technical Fill
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46706189 - Foamed Concrete in Kirkfieldbank supplied for void fill
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46706332 - Foamed Concrete in Barking Supplied for TBM Extraction
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46706392 - Foamed Concrete in Bristol Supplied for Nightclub Basement Infill
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46706822 - Langley Quarry Shows More Neolithic Remains From 3000 Years Ago
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46706832 - Langley Quarry Shows More Neolithic Remains From 3000 Years Ago
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46706858 - Frank’s Mighty Wickwar Oak Nominated For Tree Of The Year
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46707012 - CEMEX Works With RSPB To Respond To Government On Brexit Planning
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46737189 - Tracking Twites at Doveholes Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46737175 - CEMEX UK Achieves CEMEX Go 500 Customers Milestone
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46737198 - Tracking Twites at Doveholes Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46737211 - Washwood Heath Rail Team Lend-A-Hand At Local Nursery
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46737225 - A Different Kind Of Step Challenge For Somercotes Rail Solutions Teams
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46737238 - Adam’s Readymix Team Help Out Eastbourne Sea Cadets
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46814859 - Batman protecting the wildlife at Leyburn Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46814868 - Batman protecting the wildlife at Leyburn Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46814881 - School’s Out for Summer, but not at Oakfield Primary in Rugby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46814895 - Congratulations Emma Dzyga – South Ferriby Apprentice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46815142 - CEMEX ReadyBlock Donated For Burns Charity Founder's Garden
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46824177 - Another Innovative Power Floated Roller-Compacted Concrete Project In Basingstoke
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46824192 - Willington Quarry Team Work With Parish Volunteers On Footpath Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46824425 - South Coast Readymix Team Lend-A-Hand At Hove Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46824444 - Family Fun Day in Rugby for Readymix Customer Service Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46873325 - Go back to school safely
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46873407 - Big Trucks At Little Manor
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46873428 - Lend a scouting hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46873467 - Mad Max Revs It Up For Super Evo Motocross
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46938977 - CEMEX Go now Serving 1000 UK Customers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46939324 - Clevedon Beach Clean Up Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46946961 - Foamed Concrete Supplied in Maidstone for Sink Hole Fill
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 46939343 - Wick Floors team Earn Their Lend-a-hand badges
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47036644 - 20 Years Lost Time Incident Free For Norton Subcourse Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46995700 - CEMEX transports aggregates more sustainably by river to Fulham with Thames Shipping
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47036690 - Dying to Help Out
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47075946 - Keel-Laying Ceremony for Good Luck with CEMEX Go Innovation
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47036677 - A Pitstop for Santa’s Reindeer
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47075955 - Winter Wildlife Wonderland in Your Garden
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47076128 - Lend A Paw Day near Rugby
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47076110 - Middleton Quarry Takes Road Safety to School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47105103 - Supplying Innovative Concrete For Grand Housing Project
   🏷️  Categories: MEDIA-PressReleases

📄 47130257 - Keith Lacey Driver Of The Year Award 2018
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47130293 - 100% Renewable Energy For CEMEX UK
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47130325 - Clear Your Dashboard
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47130339 - Lending a Sporting Hand in Prestwich
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47168088 - 215 Million Years Ago In A Galaxy Not So Far Away
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47168203 - Clear Your Dashboard – See The Difference
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47168407 - Keeping Healthy and Lending a Hand Too
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47168272 - 13 Years LTI Free For Northfleet Wharf
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47197123 - Readymix Concrete Hungate York Supplied For Area Development Project
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47221434 - Our “Safety Savvy” Drive to Survive Continues
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47221420 - Forgotten Wrecks Of WW1
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47253283 - ​​​​​​​Stay Wider of the Rider
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47253325 - Northwest Readymix Team Lend a Leafy Hand at Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47253897 - Mersey Gateway wins CEMEX Building Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47253833 - 21 years with no Lost Time Incidents at South Ferriby Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47269716 - Ronnie Teaches Road Safety at Cotherstone
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47270628 - CEMEX Busy Supplying Foamed Concrete
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47301932 - CEMEX Projects Applauded By The Industry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310817 - Fencing to Lend an Equestrian Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310844 - Lendahand Days are Good for Our Mental Health
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310830 - Drivers of the Future
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310863 - Falls From Height Can Be Fatal
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310910 - New Safety Support For Our Lone Night Drivers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310934 - Hyndford Quarry 14 years Lost Time Incident Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47310967 - Team at Taffs Well Wearing Xmas Jumpers for Charity
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47442960 - ENGIE supplies CEMEX with 100% renewable electricity
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47483993 - 22 Years LTI Free at Wangford Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47446890 - CEMEX UK agrees primary authority partner
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47483979 - CEMEX Partners with Lincoln University to develop CSR strategies
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47484221 - Food Bank Bonanza for Rugby Aggregates Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47484261 - Bulk Cement Planning Team Lend a Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47484642 - New Year, New Pedestrian Safety trucks
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47568197 - Crawley and Southampton RMX plants up and running
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47568183 - In a tight spot – training for area 7
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47568260 - Lowest density Porofoam ever supplied
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47620375 - Concrete in Darlington Provided for New Aldi Store
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47685336 - Concrete Supplied to Luton Dart Project
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47688404 - Beam & block floor systems benefit house builds in Basingstoke
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47689052 - Readymix Concrete Supplied for Southampton Solent University Sports Centre
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47689335 - Early Strength Screed Supplied for Southampton Solent University Sports Centre
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47807430 - Ladders Are Gone On The Latest CEMEX Readymix Truck
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47811632 - Flowing Screed In Scarborough Supplied For New Build
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47811662 - First spade in the ground signals the start of new flood defences
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47811699 - Concrete supplied In Kirby Misperton For Flamingo Land
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47812135 - CLOCS Educational Engagement Programme
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47812159 - Inspiring Young Engineers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47812194 - Hatfield Quarry Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47812303 - Wangford Quarry Coming Along Nicely
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47849258 - CEMEX-TEC Award 2019 Launched With Two New Categories
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47854886 - PLA INVESTMENT AT CEMEX NORTHFLEET WHARF SECURES RIVER TRAFFIC
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47865760 - Earth Day 2019 CEMEX educates local students how to give waste second life
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47880509 - Advanced Concrete Scarborough Supplied To Brambles Construction
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47887107 - Concrete In Bristol Supplied For New Wind Turbine
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47913279 - CEMEX will contribute to reconstruction of Notre-Dame Cathedral
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47913556 - Self Levelling Screed Supplied In Kelfield York
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 47916527 - 13 CEMEX UK Sites Record Over 100 Wildlife Species
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47960857 - FINAL CALL TO ENTER  2019 CEMEX-TEC AWARD
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 47983708 - CEMEX Go Digital Platform Facilitates 660m³ Pour in 11 Hours
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48025813 - CEMEX Ventures invests in Energy Vault to support rapid deployment of energy storage technology using concrete blocks
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48043953 - Success of Blackline Safety System Leads to Expansion Across CEMEX Business
   🏷️  Categories: Press Release, Home, Main Carousel, 2019, MEDIA-PressReleases

📄 48072446 - Airbus Wing Team Shortlisted for the Concrete Society Awards 2019
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48072465 - Kensworth Quarry Reach 10 years LTI & TRI Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48072487 - Collessie Quarry celebrate 10 years LTI free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48072644 - CEMEX strengthens its commitment to the UN Sustainable Development Goals
   🏷️  Categories: Press Release, Home, Main Carousel, 2019, MEDIA-PressReleases

📄 48074618 - CEMEX Completes Deployment Of CEMEX Go With Customers Worldwide
   🏷️  Categories: Press Release, Home, Main Carousel, 2019, MEDIA-PressReleases

📄 48105523 - Farmpave Concrete In Ganton Supplied To Dairy Farm
   🏷️  Categories: Projects Blog, MEDIA-PressReleases

📄 48107682 - Keeping our Readymix Truck Drivers Safe and Healthy
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48107806 - Gorse Bushes Keeping Our Sites Buzzing
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48121560 - CEMEX and GB Railfreight Launch New Branded Locomotive at Official Naming Ceremony
   🏷️  Categories: Press Release, Home, Main Carousel, 2019, MEDIA-PressReleases

📄 48129906 - Graduation Day for the 2018/19 Class of Apprentices
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48194403 - Little Mix Raises Money For The Bluebell Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48194440 - Celebrating 50 Years At Attenborough
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48194454 - CEMEX Driver Apprentice Onboarding Event For New Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48194499 - A Special Thank You for Malino
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48239965 - neogem Helps Cowdray Park Get Gold Cup Ready with High Quality Sports Sand
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48274150 - Safety Day at London School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48265233 - CEMEX-Tec Award doubles number of projects registered in 2019
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48274193 - Customer Safety Award for Kier
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48274209 - Vive Le Tour…de Cemex
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48274224 - Rugby Plant Lend a Hand at Local School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48385498 - CEMEX Invests in New Readymix Plant at Bramshill Quarry
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48388161 - Time To Walk The Talk With Business Fights Poverty
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48388118 - School Safety Day Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48451291 - Traditional Launching Ceremony Takes Place  for Industry Leading Marine Aggregate Dredger
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48500763 - Successful Butterfly Conservation At CEMEX
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48541808 - Neogem Goes For Gold
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48541836 - Dove Holes Supports Whaley Dam Efforts
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48541857 - CEMEX Supports Rugby School Children
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48584862 - Taking The Best From Other Organisations
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48604356 - Bringing The Desert To Broxbourne
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48604385 - Marine Division Recognises Merchant Navy Day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48655303 - CEMEX Partners with BMD Transport to Introduce Non-Tipping Trailers for Clay Supply
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48624531 - CEMEX Employees Raise Over £8,000 for Stroke Association
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48727079 - CEMEX is included for the third consecutive year in the Dow Jones Sustainability MILA Pacific Alliance Index
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48752898 - 2019 CEMEX-Tec Award Recognises High-Impact Projects In Sustainable Development
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48687636 - CEMEX Rail Team Win Customer Care Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48678916 - CEMEX will recognise world class works
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48838016 - CEMEX Ventures listed as most relevant investor in construction ecosystem for second straight year
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48843036 - CEMEX Supplies Concrete For Renovation  Of Tunel De La Risa In Madrid
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48890278 - CEMEX Ventures Invests in X3 Builders, a Vertically Integrated General Contractor
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48890769 - Mayor launches scheme to revolutionise London lorry safety at CEMEX’s Stepney Concrete Plant
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48915001 - Driver Of The Year Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48914487 - Divethill Restoration Plan Wins at MPA Awards
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48934253 - Milestone Tonnage Delivered at CEMEX Railhead in Attercliffe
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48963885 - CEMEX Launches Road Safety Campaign to Target Mobile Phone Use
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49022422 - CEMEX And RSPB Celebrate 10 Years Of Biodiversity Partnership
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49045872 - CEMEX Go Haulier Open Day
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856191 - A Nice Lend-A-Hand Cuppa…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856212 - A Nest Box With A Difference…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856268 - Customer Service Centre And Friends Go For A Walk…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49030085 - CEMEX Ventures paves the road to enter Chinese market
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 45856275 - Could you do the Hamer Warren ‘5 A Day’ Challenge?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856296 - Forget Leicester City...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856282 - Mike Wellsbury - retired but not out !!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856303 - Taxi!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856310 - Pedometer Challenge Kicks Off !
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856345 - Could you see this truck operating on London roads?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856380 - We Need Your Europe Vote By 8th May (Birdlife Not Brexit)
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856401 - Better Solutions for Our Customer In Dover Get Back On Track!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856422 - New customer, new mix design, new material supplier -  a recipe for disaster?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856450 - The tram stops here...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856464 - Croydon is Advancing....
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856513 - One quarry, a crisp winter morning and a good eye....
   🏷️  Categories: Story, MEDIA-PressReleases

📄 45856562 - Evolving Birmingham&#39;s tunnels...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46009566 - We Want More Young Drivers….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46116397 - Our Proud Graduates!
   🏷️  Categories: Home, Main Carousel, Story, MEDIA-PressReleases

📄 46393029 - Keeping well in the Trossachs!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46453505 - World Cup 2018 Survival Guide...
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46873454 - Everyone loves to dress up…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 46939311 - CEMEX Presents 26th Volume Of Nature And Conservation Book Series: “Islands”
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47036664 - Walking in the Rain!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47221099 - Keep Go-ing!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47270679 - Keep Staying Wider of the Rider!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47270705 - Blooming Brilliant Biodiversity!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47484206 - Startling Starlings Go Global!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 47686734 - CEMEX VENTURES LAUNCHES CONSTRUCTION STARTUP COMPETITION 2019:  “APPLY. GROW. MAKE YOUR MARK.”
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 48107826 - Small but perfectly formed lend a hand…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48194158 - Well Done To The Doncaster Runners….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48229118 - Stay safe on your bikes…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48388176 - Dove Holes Attempt To Cycle The Distance….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 48727093 - Forbes Recognises CEMEX As One Of The “World’s Best Regarded Companies”
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49046017 - Pupils Positive Experience Of Quarrying
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49045890 - 32 International Projects Participated In The CEMEX Building Award 2019
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49063348 - CEMEX Announces Its Objective To Expand  Its Volunteering Commitments For 2020
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49046031 - School Safety Sessions in Birmingham
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49101431 - CEMEX Ventures, BCG, and Tracxn launch list of the 50 most promising startups in the construction ecosystem of 2019
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49100767 - CEMEX Recognises Safe and Efficient Driving with Celebratory Event
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49121732 - CEMEX Sponsors Soccer School
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49128236 - CEMEX supplies concrete for Guitar Hotel in Florida
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49170920 - CEMEX Upgrades Facilities at Salford to Improve Rail Depot Capability
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49178902 - CEMEX Announces Divestment Of Certain Assets In The UK
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49229307 - CEMEX And Turners Distribution Commence Bulk Cement Partnership
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49275489 - 16 Years LTI Free at Cambusmore
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49329654 - CEMEX and PLA Officially Open New Dry Discharge System at Northfleet Wharf
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49388462 - CEMEX improves employability capabilities of approximately 45,000 young people
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49313443 - CDP Raises CEMEX Rating For Leadership On Climate Change Transparency And Action
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49388928 - CEMEX plays key role in the development of the On Vine project in Los Angeles
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49404072 - CEMEX Launches Call For Building Award 2020
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49406520 - CEMEX Reports Fourth Quarter And Full-Year 2019 Results
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49486015 - CEMEX announces ambitious strategy to address climate change
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49497776 - CEMEX Launches UK’s First Net Zero Ready Mixed Concrete Product
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49515639 - CEMEX-Tec Award Launches Global Call and Celebrates 10th Anniversary
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49529456 - Concreting The Fun For Half Term
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49529273 - Helping The Next Generation
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49529512 - Readymix Midlands Team Lend-A-Hand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49670592 - CEMEX signs UN Women's Empowerment Principles
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49675925 - Covid-19 - CEMEX UK Response
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49712529 - CEMEX Continues Addressing Climate Change And Fostering Innovation
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49712391 - CEMEX Announces Organisational Changes
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49722225 - CEMEX Supplies 25,000 Tonnes Of Asphalt To RAF Coningsby Without Halting Operations
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49750235 - M23 Smart Motorway Pour Complete
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49750287 - Confined space rescue drill at Braintree DSM
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49832478 - CEMEX Suspends Building Award 2020
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49776310 - Dove Holes’ Blooming Biodiversity
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49834174 - Cement Logistics Scoops Safety Sword 2020
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49834193 - Bird's Eye View of New Northfleet Dry Discharge System
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49838760 - Thank You Message On The Tower
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49838773 - Urban Birds at Salford Site
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49876196 - CEMEX Joins the Fight Against the COVID-19 Pandemic to Help Employees, Communities and Hospitals
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49875445 - Helping Protect Native Trees at Our Quarries
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49889864 - Supply Chain Materials Team at Dove Holes Celebrate 14 Years LTI and TRI Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49889886 - Old and new - a journey through underground history
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49927028 - CEMEX UK National Technical Centre in Southam Produces Hand Sanitiser to Support Effort Against Coronavirus
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 49964031 - CEMEX Announces Proposed Mothballing of South Ferriby Cement Plant
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50009374 - Five Industry Leaders Launch 2020 Construction Startup Competition
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50046872 - CEMEX-Tec Award Extends Call Due to COVID-19
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50051710 - New ward for Royal Surrey Hospital
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50051731 - Cambridge Science Centre interview
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50064922 - Warwick Uni Opts for Vertua
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50064979 - Rail hits the 1 million mark
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50065201 - Heathland at Rugeley
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50079246 - Leading international companies launch Restarting Together: an initiative to boost recovery after COVID-19
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50085284 - CEMEX Highlights Products & Services that Help Meet Challenge of Site Working Requirements
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50167255 - Low Carbon Projects are a Key Solution to Jobs, Inequality and Resilience Concerns
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50226279 - Donations Of Sanitiser And Face Masks
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50226655 - Sand Falcon Supports Coastguard Drill
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50226721 - CEMEX Supports Veterans through COVID-19 Appeal
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50259836 - CEMEX Launches Construction Materials Testing Service: LabExperts
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50246551 - CEMEX Launches New Fast Laying, Eco-friendly Asphalt For Cycle Lanes & Footpaths
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50264157 - CEMEX Ventures Will Recycle Plastic To Produce Concrete And Aggregates Through Its Investment In Arqlite
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50323302 - Decision on Proposed Mothballing of South Ferriby Cement Plant
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50331123 - CEMEX-Tec award closes its global 2020 call with record number of entries
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 50342806 - CEMEX UK Pledges Support to The Myton Hospices
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50373873 - CEMEX Moving Forward on its Ambition to Deliver Net-Zero CO2 Concrete Globally
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51142842 - CEMEX Closes Divestment Of Certain Assets In The UK
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51143342 - 400 Hands Say Thank You
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51143410 - 1,500 Facemask Costs Donated
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51143485 - 18 Years Dedication to Health & Safety at Berkswell
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51143670 - CEMEX UK Supports Pan Intercultural Arts’ Fortune Project
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51149469 - CEMEX launches first carbon neutral concrete
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51149977 - A Sustainable Asphalt Solution for Trench Reinstatement
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51229479 - CEMEX Informs Proposed Redundancies of South Ferriby Cement Logistics
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51234830 - CEMEX Broadens Product Range to Include Dry Bagged Mortar
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51303848 - 1,000 Gloves Donated to Hospice
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51334080 - COVID-19 Branded Truck Comes to London
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51332656 - CEMEX Partners with Kier and RO Donaghey to Provide CarbonNeutral® Concrete Product for Cryfield Residences at the University of Warwick
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51334094 - A Busy Week for LabExperts
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51334308 - CEMEX partners with the Cambridge Science Centre to engage STEM learning to young people
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51338024 - Rare Wall Brown Butterfly Spotted
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51338048 - CEMEX Helps Local Food Project
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51382916 - Top M27 Night Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51382931 - CEMEX Invests US$280 Million To Improve Air Quality Around The World
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51383029 - Operation Resilience paves road to a better future
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51383075 - Violets are blue…rare butterflies are Dark Green
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51401561 - HS2 uses new pioneering low carbon concrete to reduce carbon emissions in construction
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51404397 - Fortune recognizes CEMEX again as a company that changes the world
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51585945 - CEMEX and Carbon Clean to develop low-cost carbon capture technology
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51585979 - CEMEX’S Operations In Europe Announce A CO2 Reduction Target Of At Least 55% By 2030
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51585998 - CEMEX’S 2030 CO2 Emissions Reduction Target And Implementation Roadmap Validated By The Carbon Trust
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51586217 - CEMEX Looks To Use The Sun To Decarbonize Cement
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51586226 - CEMEX-Tec Award 2020 Recognizes Projects That Seek To Transform The World
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51659764 - CEMEX Announces Highest Quarterly Ebitda, Ebitda Margin And Free Cash Flow Since 2016
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51659777 - CEMEX To Offer Vertua® Net-Zero CO2 Concrete Worldwide
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51769304 - CEMEX Transports Two Million Tonnes By Rail And Saves 100,000 Road Movements
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51907303 - CEMEX Launches iCollect, an Industry-Leading App for  Asphalt Customers
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51674461 - CEMEX Invests Over £600,000 Into Improvements on its Rail Network During 2020
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 51926547 - In Memory of Brent Peppard
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51926576 - Advanced customer service for an advanced product
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51936775 - CEMEX Presents ISOFINES Drying Solution to Safely and Sustainably Absorb Waste Water from Construction
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 52004563 - CEMEX Invests to expand in Mortar Solutions in Main EMEAA Markets
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 52010106 - CEMEX Finalises Sale of Attenborough Nature Reserve to Nottinghamshire Wildlife Trust
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 52005040 - CEMEX Ventures Launch The 50 Most Promising Startups In The 2020 Construction Ecosystem And The Cities Of The Future
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases

📄 52116068 - CEMEX Supports Citu Climate Innovation District with Vertua Classic Concrete
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52086892 - CEMEX Prepares Major Investment to Packed Cement Packing Line at Rugby Plant
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52121603 - CEMEX Ventures promotes the redefinition of how houses are designed and built through its investment in Modulous
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52149739 - CEMEX Supplies Over 40,000 Tonnes of Primary Sprayed Concrete to London’s ‘Super Sewer’ Project
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52216194 - Affordable and Sustainable Solutions for Bradford University
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216207 - Over 12,000 out of hour deliveries
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216176 - Early strength helps ASDA deliver
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216220 - 5 Million Tonnes for Dove Holes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216242 - Christmas meals for those in need
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216256 - Great CO2 Savings from the Rail Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216402 - Sea Freight 2020 Success
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52259095 - CEMEX committed to participate in LEILAC 2 project, which aims to decarbonize cement production
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52259425 - CEMEX partners with CARBS – concrete kinetics
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52275234 - CEMEX awarded grant from U.S. Department of Energy to develop pioneering carbon capture technology
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52293025 - CEMEX Leads in Climate Action by Switching to More Sustainable Energy Sources
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52294191 - CEMEX Presents Engineered Asphalt Concrete for Housing Estate Roads
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52319593 - CEMEX starts operations of seven sustainable growth investments in Europe in January
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52332360 - CEMEX successfully deploys hydrogen-based ground-breaking technology
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52391715 - CEMEX Launches New Supaflo® Rapide Screed With Significant Drying Time, Site Productivity & Sustainability Benefits
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52433928 - CEMEX launches call for the CEMEX Building Award 2021
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52433914 - CEMEX executive appointed to Sustainability Board in the federal State of Brandenburg, Germany
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52433974 - CEMEX participates in Via Baltica, one of the largest infrastructure projects in Europe
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52434558 - CEMEX participates in Santolea Dam, one of the most relevant hydraulic projects in Spain
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52434571 - CEMEX Invests US$25 Million To Phase Out Fossil Fuels At Rugby Cement Plant In The UK
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52441018 - UK Readymix Wins Safety Sword
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52440921 - Using Water Wisely at Our Sites
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52442953 - Supporting Local Schools During COVID
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52462915 - CEMEX Introduces New ReadyPave® Camden With More  Sustainable Manufacturing Process
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52711459 - CEMEX joins OpenBuilt to accelerate digital transformation of the construction industry
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52552364 - CEMEX Paves The Road For A More Sustainable Future
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52711473 - Construction startup competition 2021 opens call for entrepreneurs building the new legends of construction
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52711495 - CEMEX files annual report on form 20-f for fiscal year 2020
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52718899 - CEMEX Invests for Growth at Selby Depot with Partners Bowker Group and Potter Space
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52792511 - CEMEX Launches "VIALOW" Asphalt - A CarbonNeutral®️ Product
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 57279293 - Going FORS Gold
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804556 - Building homes for Birmingham
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804515 - 15 years LTI free for Dove Holes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804569 - Putting lockdown to good use
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804703 - First Vertua® Ultra Zero Project for the Capital
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804730 - Biodiversity Spotlight – Denge Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804874 - Bowkers Win Health & Safety Contractor Q1 Award
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804901 - Biodiversity Spotlight on West Heath
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52831637 - bp and CEMEX team up on net-zero emissions
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52831657 - bp and CEMEX team up on net-zero emissions
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52930769 - CEMEX drives climate action by renewing three-year partnership with ENGIE for 100% UK renewable electricity supply
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52957912 - CEMEX’s low carbon concrete Vertua® range ideal for key infrastructure projects with sustainability requirements
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52988582 - CEMEX presents next generation Vertua® admixtures range  for sustainable urbanisation
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53001077 - Walk it out, Talk it out
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53005037 - Vertua net-zero concrete conquers the world
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53115907 - CEMEX inaugurates new multi-service & multi-modal circular economy platform at Gennevilliers, France
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53160970 - CEMEX pledges implementation of mp connect driver card by end of 2021
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53188910 - CEMEX launches new RIBA-accredited sustainability CPD course to help clients with Climate Action
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53288600 - Somewhere under the rainbow….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53322216 - CEMEX Commits To Lead The Industry In Climate Action
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 52967533 - CEMEX Joins Ground-Breaking Consortium to Generate Electricity Using Supercritical CO2 Technology
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53322405 - CEMEX contributes low carbon solutions to the spectacular architecture of the Paris Duo Towers
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53322231 - CEMEX achieves investment-grade capital structure and accelerates growth strategy
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53322433 - CEMEX moving to a hybrid and electric company car fleet in EMEA region
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53355125 - CEMEX joins two world-leading initiatives to achieve carbon neutrality
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53355163 - CEMEX Ventures invests in carbon capture tech of the future
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53356011 - Summer of sport sand
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53408094 - Dragon boat race for Alder Hay
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53504447 - CEMEX extends its commitment to waste reduction and circular economy with nationwide merchant pallet recovery service
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53563976 - CEMEX Further Enhances Sustainable Rail Operation with Summer Investment Programme
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53745756 - CEMEX Introduces ‘Buildings Made Better’ - Complete Renovation Solutions For Energy Efficient Building Improvement
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53909420 - CEMEX invests in renewable solar energy in Poland as part of ‘Future in Action’ strategy
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53927577 - No More Deer in the Headlights….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53927704 - And the winner is….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53927777 - Fun With Buxton Water…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53927851 - A Winning Supply Chain Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 53937794 - CEMEX strengthens footprint in key metropolitan areas in Spain
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53937894 - CEMEX ambitious 2030 climate targets validated to be in line with the latest science
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54193333 - CEMEX Provides Sprayed Concrete for Bank Station
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54327179 - CEMEX and Carbon Clean work on carbon capture project in Germany
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54373505 - CEMEX provides Vertua lower carbon concrete for sustainable building in Poland
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54373457 - New Readymix Plant in Swindon
   🏷️  Categories: Story, MEDIA-PressReleases

📄 54403453 - CEMEX invests in pioneer solar technology
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54400697 - CEMEX Increases Use of Sustainable Transport Methods with Opening of New Birmingham Rail Depot
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 49101080 - CEMEX Presents 27th Edition Of Conservation Book Series: “Nature’s Solutions To Climate Change”
   🏷️  Categories: Press Release, 2019, MEDIA-PressReleases

📄 49121718 - Happy Christmas Benn Partnership!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49310162 - Have You Seen Any Of These Winter Visitors?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49417921 - Amy’s Fascinating Fossils….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49529579 - CEMEX Spring Watch!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 49750274 - First customer for Vertua!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50226118 - The South Coast Gets Pumping…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50226260 - CEMEX Leaders Join RSPB’s Wild Challenge – Why Don’t You?
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51338066 - Willow Tit at Willington – More of a ‘Status Quo’ Kind of Bird!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51400900 - Create Your Own CEMEX Truck – For Children Of All Talents!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 51658455 - Trucktastic designs!!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52216128 - A new twist on Christmas Lights…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52442793 - Blooming marvellous…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804480 - New customer for supaflo…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804717 - Educating the Specifiers of the Future….
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804786 - No travel restrictions for the Sand Martins!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804744 - Happy Mondays…
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52804887 - Neutra-Agg Ultra Officially ‘Fine Quality Limestone’
   🏷️  Categories: Story, MEDIA-PressReleases

📄 52832143 - CEMEX and Walsh River Freight Partnership to Reduce Transport CO2 by 75%
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 53288819 - A waiting game…for Hopwas 4 years on!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 54413203 - Divestment of Certain CEMEX UK Assets in Scotland
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54414945 - CEMEX Go helps redevelop Leicester
   🏷️  Categories: Story, MEDIA-PressReleases

📄 54414962 - CEMEX Supports Ground-Breaking New Concrete Project
   🏷️  Categories: Story, MEDIA-PressReleases

📄 54415110 - Landscape Scale Collaborations with RSPB Business Partnerships
   🏷️  Categories: Story, MEDIA-PressReleases

📄 54507598 - CEMEX partners with CASE Construction Equipment to introduce lower-carbon vehicles to European business
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 54448082 - CEMEX is founding member of World Economic Forum's "First Movers Coalition" to drive demand for zero carbon technologies
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55231476 - CEMEX further progresses carbon neutral plans for Rüdersdorf plant with waste heat recovery project
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55231712 - CDP awards CEMEX its highest rating for leadership in Climate Action
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55231739 - CEMEX Supports Lancashire County Council with CarbonNeutral®️  Asphalt Product
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55231833 - Public Invited To Consult on Extension to Ryall Quarry
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55231848 - CEMEX and Carbon8 Systems partner to develop low-carbon construction products
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55231865 - CEMEX joins the UN CFO Taskforce to promote sustainability goals
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55405874 - With new 3D printing technology, CEMEX and COBOD build a better future
   🏷️  Categories: Press Release, 2021, MEDIA-PressReleases

📄 55639912 - CEMEX’s restored quarries produce bountiful harvest
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56020206 - New Stadium for The Toffees
   🏷️  Categories: Story, MEDIA-PressReleases

📄 55827921 - CEMEX helps housebuilders meet the Future Homes Standard with the introduction of “ReadyBlock Zero” – the UK’s first zero carbon concrete block
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56020603 - View from the New Generation
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56020066 - Biodiversity Net Gain at Raynes Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56020662 - New Kit for Sudbury FC
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56020912 - Lewis is Top of the Class
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56207087 - CEMEX invests in breakthrough clean hydrogen technology
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56207341 - CEMEX and Synhelion achieve breakthrough in cement production with solar energy
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56513205 - CEMEX Reports Highest Ebitda Growth In A Decade, With Great Progress On Climate Action Agenda
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56513405 - CEMEX to introduce zero emissions electric ready-mix trucks
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56513271 - CEMEX recognized by CDP as global leader in supply chain carbon reduction efforts
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56775698 - CEMEX Building Products Business Reduces Plastic Packaging With Future In Action Programme
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56557899 - CEMEX joins CISL’s Corporate Leaders Group Europe to support progress towards net zero
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56847010 - CEMEX Sponsors Safe Drive Stay Alive Event
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56870916 - Impeccable Planning Pays Off
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56847265 - No Waste in the South West
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56873538 - Merry Christmas to Benn Partnership
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56873578 - Putting Customers Before Crackers
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56876496 - Happy Holidays for Wildlife
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56876726 - CEMEX Charity Partnerships 2021 Achievements – PAN Intercultural Arts
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56876749 - CEMEX Charity Partnerships 2021 Achievements – STOLL
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56900753 - Meeting with MP Greg Hands
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56876982 - High Standards for a Large Pour
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56900975 - 100 Days for Small Heath
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57114187 - CEMEX posts record operational and climate action achievements in 2021
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 57258681 - New CEMEX ONPOINT Mortar Injects Colour into Offsite Construction and Urban Building Design
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 57279096 - UK Marine Wins Safety Sword
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57279514 - Congratulations Philippa – a fantastic achievement
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57279563 - It’s a win for local youth teams
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57279540 - Woody Woodpecker stops by at Salford
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57379498 - CEMEX announces significant milestone in carbon capture project
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 57425842 - UK Marine Achieves 3 Years LTI Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57426133 - CEMEX Ladies Support Local Cause
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57673075 - Restoring a Listed Lodge
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57672921 - Public Invited To View Planning Application for  Minerals Extraction at Ripple East
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 57673201 - Site Spotlight - Jarrow Wharf
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57673235 - Ifty Walked All Over Cancer
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57673293 - Industry recognition for Julie and Carl
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57675144 - Berkswell team donate winnings
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57674446 - A very happy customer
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57675193 - New additions at Denge Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57675489 - CEMEX to turn CO2 into sustainable aviation fuel
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 57858425 - CEMEX reports double-digit growth in sales and increase in EBITDA
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 57881762 - Positive Visit from MP
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57881791 - Barry’s 50 Years at Halkyn Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57881906 - Technical Apprenticeship Programme
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58096888 - Innovative Solutions for Network Rail
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58097045 - Volunteering as One CEMEX
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58096679 - Innovative Solutions for Network Rail
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58097081 - Fantastic Fundraising Achievements by Matt and Reb
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58097432 - Remains of Old Ship found at Denge Quarry
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58097621 - CEMEX successfully turns CO2 into carbon nanomaterials
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 58097650 - VERTUA LOW-CARBON TO ACCOUNT FOR MAJORITY OF CEMENT AND CONCRETE SALES BY 2025
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 58314708 - Kensworth Celebrate 13 Years LTI Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58314747 - Berkswell Quarry Wins EXCEED’s Idea of the Month
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58314771 - One Million Tonnes from Dove Holes
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58314785 - Fayanne Passes HGV Test
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58314923 - Building Products Celebrate 1 Year LTI Free
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58314956 - Back to School for Dove Holes Night Shift Team
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58314990 - Tight Timelines for Dove Holes Investment Project
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58315114 - Fascinating Feldbinder Visit
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58322697 - CEMEX ramps up investment in carbon capture tech of the future
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 58542832 - CEMEX TO OPERATE FULLY ON ALTERNATIVE FUELS AT UK CEMENT PLANT
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 58547727 - CEMEX UK signs up to West Midlands Net Zero Business Pledge, strengthening further its “Future In Action – Committed to Net Zero CO2” strategy
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 58574913 - CEMEX AND PARTNERS INAUGURATE THE CARBON NEUTRAL ALLIANCE AT RÜDERSDORF CEMENT PLANT
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 58660411 - CEMEX launches educational program  to raise awareness of the Circular Economy
   🏷️  Categories: Press Release, 2022, MEDIA-PressReleases

📄 56876404 - Shed-Loads of Concrete!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 56901327 - Welcome to CEMEX Matthew!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57426117 - Charity of the Year – Results are in!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 57881563 - It’s a Game Changer!
   🏷️  Categories: Story, MEDIA-PressReleases

📄 58097292 - Supporting School Pupils ‘Reading for Pleasure’
   🏷️  Categories: Story, MEDIA-PressReleases

📄 50356578 - CEMEX Launches New Mortar Paving System
   🏷️  Categories: Press Release, 2020, MEDIA-PressReleases


✅ Category analysis completed!
============================================================


*/