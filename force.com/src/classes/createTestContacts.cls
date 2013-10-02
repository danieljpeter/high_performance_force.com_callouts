public class createTestContacts {

	public static String sDesc = 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.';




	//createTestContacts.createTestLeads();
	public static void createTestLeads() {
		List<Lead> leadList = new List<Lead>();
		for (Integer x=1; x<=100; x++){
			Lead l = new Lead(FirstName='Jane', LastName='Doe_'+x.format(), Company='North Bay DUG', Description=sDesc);
			leadList.add(l);	
		}
		insert leadList;
	}

	//createTestContacts.deleteTestLeads();
	public static void deleteTestLeads() {
		List<Lead> leadList = new List<Lead>();
		leadList = [SELECT Id FROM Lead WHERE Company='North Bay DUG'];	
		delete leadList;
	}


}