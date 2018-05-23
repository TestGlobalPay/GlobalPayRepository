global class EmailServiceHandler implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        if(email.subject != null) {
            System.debug('subject======>'+email.subject);
        }
        return result;
    }
}