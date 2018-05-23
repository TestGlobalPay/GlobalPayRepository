<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>updateOpportunityLineItem</fullName>
        <field>Bundle_Items__c</field>
        <formula>PricebookEntry.Product2.Bundle_Items__c</formula>
        <name>updateOpportunityLineItem</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>conciseBundle_OLI</fullName>
        <actions>
            <name>updateOpportunityLineItem</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2000 1:30 PM</value>
        </criteriaItems>
        <description>Concise view of Product generated from a Bundle</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
