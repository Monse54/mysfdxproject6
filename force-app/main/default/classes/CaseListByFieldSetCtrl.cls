public with sharing class CaseListByFieldSetCtrl {
@AuraEnabled(cacheable=true)
    public static List<case> fetchCaseFieldSetData(String OppID){
        String queryString = 'SELECT Id, Subject';
        List<case> conList = new List<case>();

        for(Schema.FieldSetMember fld :SObjectType.case.FieldSets.CaseListlwcFieldSet.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        String recordtypename = 'Programmatic Deal Request';
        queryString += ' FROM Case where Opportunity__c= :OppID and Record_Type_Name__c=: recordtypename';         
        conList = Database.query(queryString);
        return conList;
    }

    @AuraEnabled(cacheable=true)
    public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> fieldSetMap = d.fieldSets.getMap();

            if(fieldSetMap.containsKey(fieldSetName)){
                for(Schema.FieldSetMember f : fieldSetMap.get(fieldSetName).getFields()) {
                     
                    if(String.isNotBlank(result)){
                        result += ',';
                    }

                    String jsonPart = '{';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"label":"' + (f.getLabel()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
        }
        catch(Exception ex){
            result += ex.getLineNumber() + ' : ' + ex.getMessage();
        }
        return '['+result+']';
    }
}