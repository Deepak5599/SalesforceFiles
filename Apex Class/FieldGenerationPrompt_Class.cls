public with sharing class FieldGenerationPrompt_Class {

    @InvocableMethod(label='Add Aepx data' description='Add Apex data into field generation prompt template'
                    CapabilityType='PromptTemplateType://einstein_gpt__fieldCompletion')
                    
    public static List<Response> userDefinedData(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if(requests.size() == 1){
            Set<Id> productIds = new Set<Id>();
            Account acc = requests[0].RelatedEntity;
            
            List<AggregateResult> results = [SELECT Product2Id
                                                FROM OpportunityLineItem
                                                WHERE Opportunity.AccountId =: acc.Id
                                                AND Opportunity.StageName = 'Closed Won'
                                                AND Opportunity.CloseDate >= LAST_N_MONTHS:12
                                                GROUP BY Product2Id
                                                HAVING COUNT_DISTINCT(OpportunityId) > 1
                                            ];
            
            for (AggregateResult result : results) {
                Id productId = (Id) result.get('Product2Id');

                if(productId != null){
                    productIds.add(productId);
                } 
            }

            List<OpportunityLineItem> oppLisGreateThan5 = [SELECT Product2.Name, Quantity, OpportunityCloseDate__c, UnitPrice, TotalPrice, Opportunity.Name 
                                                           FROM OpportunityLineItem 
                                                           WHERE Product2Id IN :productIds 
                                                           AND Opportunity.AccountId =: acc.Id 
                                                           AND Opportunity.CloseDate >= LAST_N_MONTHS:12 
                                                           AND Opportunity.StageName = 'Closed Won' 
                                                           ORDER BY OpportunityId];

            if(oppLisGreateThan5 != null && !oppLisGreateThan5.isEmpty()){
                String responseData = 'Provide insights on the products the user has purchased more than 5 times in the last 12 months. ';
                for(OpportunityLineItem oppLi : oppLisGreateThan5){
                    responseData += JSON.serializePretty(new OpportunityLineDataWrapper(oppLi), true);
                }
                responseData += 'Based on the above product data, identify the most profitable products for upsells and cross-sells.';
                system.debug(responseData);
                Response resp = new Response();
                resp.Prompt = responseData;
                responses.add(resp);
                return responses;
                
            }
        }
        return responses;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
    
    public class Request{
        @InvocableVariable(required=true)
        public Account RelatedEntity;
    }

    public class OpportunityLineDataWrapper{
        public String Name;
        public Integer Quantity;
        public Date OpportunityCloseDate;
        public Decimal UnitPrice;
        public Decimal TotalPrice;
        public String OpportunityName;

        public OpportunityLineDataWrapper(OpportunityLineItem opLi){

            this.Name = opLi.Product2.Name;
            this.Quantity = (Integer) opLi.Quantity;
            this.OpportunityCloseDate = opLi.OpportunityCloseDate__c;
            this.UnitPrice = opLi.UnitPrice;
            this.TotalPrice = opLi.TotalPrice;
            this.OpportunityName = opLi.Opportunity.Name;
        }
    }
}