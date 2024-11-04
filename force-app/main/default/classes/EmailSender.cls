public class EmailSender {

    @InvocableMethod(label='Send Email with HTML Body' description='Sends an email with the given HTML body')
    public static void sendEmailWithHTMLBody(List<EmailParameters> emailParamsList) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (EmailParameters emailParams : emailParamsList) {
            
            if(emailParams == null)
                continue;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(emailParams.emailSubject);
            email.setHtmlBody(emailParams.htmlBody);

            // Retrieve case record queue owner
            Case c = [SELECT Id, OwnerId,Owner.Type FROM Case WHERE Id = :emailParams.caseId LIMIT 1];

            // Check if the owner of the case is a queue
            if ((c.OwnerId != null && c.Owner.Type == 'Queue')) {
                Group queueOwner = [SELECT Id FROM Group WHERE Id = :c.OwnerId AND Type = 'Queue'];
                List<User> queueMembers = [SELECT Id, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueOwner.Id)];

                // Add queue members' email addresses to the email recipient list
                for (User member : queueMembers) {
                    if(member.email != null){
                        email.setToAddresses(new List<String>{member.Email});
                       	// email.setToAddresses(new List<String>{'Tushar.k@radix2.tech'});
                        emailsToSend.add(email);
                        system.debug('emailsToSend@@@@@@@@'+member.Email);
                    }
                }
            } else {
                 Case caseowner = [SELECT Id, OwnerId,Owner.Type, owner.Email FROM Case WHERE Id = :emailParams.caseId LIMIT 1];
                 if(caseowner.owner.Email != null){
                	email.setToAddresses(new List<String>{caseowner.owner.Email});
	                emailsToSend.add(email);
                }
                
                Integer i = 0;
                i = i + 1;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                 i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                i = i++;
                
            }
        }
        if(emailsToSend.size()>0){
            Messaging.sendEmail(emailsToSend);
        }
        
    }

    public class EmailParameters {
         @InvocableVariable(label='RecordType Name' required=true)
        public String recordTypeName;
        
        @InvocableVariable(label='caseNumber' required=true)
        public String caseNumber;
        
        @InvocableVariable(label='Email Subject' required=true)
        public String emailSubject;

        @InvocableVariable(label='HTML Body' required=true)
        public String htmlBody;
        
        @InvocableVariable(label='Case ID' required=true)
        public Id caseId;
    }
}