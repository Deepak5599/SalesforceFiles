public class PricingMetadataUpdater {

    public static void updatePricingMetadata(String jsonResponse) {
        Map<String, Object> configMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        Integer discountDuration = (Integer) configMap.get('discount_duration');
        Datetime effectiveUntil = Datetime.now().addDays(discountDuration);
        
        // Prepare field-value map for custom metadata
        Map<String, Object> fieldValues = new Map<String, Object>{
            'discount_rate__c' => (Decimal) configMap.get('discount_rate'),
            'pricing_tier__c' => (String) configMap.get('pricing_tier')
        };
        
        // Define custom metadata record details
        String fullName = 'Pricing_Config__mdt.Standard_Pricing';
        String label = 'Standard_Pricing';
        
        MetadataUtils.createUpdateMetadata(fullName, label, fieldValues);
    }
}